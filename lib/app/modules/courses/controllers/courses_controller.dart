import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

import '../../../src/alert.dart';
import '../../../src/bottom_sheet.dart';
import '../../../src/dialogs.dart';
import '../../../src/errors.dart';
import '../../../src/widgets.dart';

typedef CourseDoc = QueryDocumentSnapshot<Map<String, dynamic>>;

class CoursesController extends GetxController {
  final RxList<CourseDoc> courses = <CourseDoc>[].obs;
  final RxBool loading = true.obs;
  final RxString search = ''.obs;

  final TextEditingController name = TextEditingController();
  final TextEditingController code = TextEditingController();
  final TextEditingController hours = TextEditingController();

  StreamSubscription? _sub;
  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('Courses');

  List<CourseDoc> get filtered {
    final q = search.value.trim().toLowerCase();
    if (q.isEmpty) return courses;
    return courses
        .where((c) =>
            '${c.data()['name']}'.toLowerCase().contains(q) ||
            '${c.data()['code']}'.toLowerCase().contains(q))
        .toList();
  }

  int get totalHours => courses.fold<int>(
      0, (sum, c) => sum + (int.tryParse('${c.data()['hours']}') ?? 0));

  @override
  void onInit() {
    super.onInit();
    _sub = _col.snapshots().listen((qs) {
      final list = qs.docs.toList()
        ..sort((a, b) =>
            '${a.data()['code']}'.compareTo('${b.data()['code']}'));
      courses.value = list;
      loading.value = false;
    }, onError: (e) {
      loading.value = false;
      AppErrors.show(e);
    });
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  void openForm({CourseDoc? course}) {
    final create = course == null;
    final data = course?.data() ?? <String, dynamic>{};
    name.text = '${data['name'] ?? ''}';
    code.text = '${data['code'] ?? ''}';
    hours.text = '${data['hours'] ?? ''}';
    final id = course?.id ?? '';
    AppBottomSheet(
      buttonText: (create ? 'Create' : 'Save').tr,
      function: () => create ? _create() : _edit(id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),
          Row(children: [
            IconBubble(icon: LineIcons.book),
            const SizedBox(width: 12),
            Text((create ? 'Add Course' : 'Edit Course').tr,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ]),
          FieldLabel('Course Name'.tr),
          TextField(
            controller: name,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
                hintText: 'e.g. Data Structures'.tr,
                prefixIcon: const Icon(Icons.menu_book_outlined)),
          ),
          FieldLabel('Course Code'.tr),
          TextField(
            controller: code,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
                hintText: 'CS210', prefixIcon: Icon(Icons.tag)),
          ),
          FieldLabel('Course Hours'.tr),
          TextField(
            controller: hours,
            maxLength: 1,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
                hintText: '3',
                counterText: '',
                prefixIcon: Icon(Icons.schedule)),
          ),
        ],
      ),
    ).bottomSheet();
  }

  bool _validate() {
    if (name.text.trim().isEmpty) {
      Ui.info('Please enter the course name');
      return false;
    }
    if (code.text.trim().isEmpty) {
      Ui.info('Please enter the course code');
      return false;
    }
    if (hours.text.trim().isEmpty || hours.text.trim() == '0') {
      Ui.info('Please enter the course hours');
      return false;
    }
    return true;
  }

  bool _codeTaken(String codeText, {String? exceptId}) => courses.any((c) =>
      c.id != exceptId &&
      '${c.data()['code']}'.toUpperCase() == codeText.toUpperCase());

  Future<void> _create() async {
    if (!_validate()) return;
    final codeText = code.text.trim().toUpperCase();
    if (_codeTaken(codeText)) {
      Ui.info('A course with this code already exists');
      return;
    }
    try {
      final ref = _col.doc();
      await ref.set({
        'id': ref.id,
        'name': name.text.trim(),
        'code': codeText,
        'hours': hours.text.trim(),
      });
      Get.back();
      Ui.success('Course added');
    } catch (e) {
      AppErrors.show(e);
    }
  }

  Future<void> _edit(String id) async {
    if (!_validate()) return;
    final codeText = code.text.trim().toUpperCase();
    if (_codeTaken(codeText, exceptId: id)) {
      Ui.info('A course with this code already exists');
      return;
    }
    try {
      await _col.doc(id).update({
        'name': name.text.trim(),
        'code': codeText,
        'hours': hours.text.trim(),
      });
      Get.back();
      Ui.success('Changes saved');
    } catch (e) {
      AppErrors.show(e);
    }
  }

  void confirmDelete(CourseDoc course) {
    AppDialogs.confirm(
      title: 'Delete Course',
      message:
          'Are you sure you want to delete @name? Its lectures will no longer appear.'
              .trParams({'name': '${course.data()['name']}'}),
      onConfirm: () async {
        await _col.doc(course.id).delete();
        Ui.success('Course deleted');
      },
    );
  }
}
