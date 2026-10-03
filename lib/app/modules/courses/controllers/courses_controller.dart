import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

import '../../../src/alert.dart';
import '../../../src/bottom_sheet.dart';
import '../../../src/colors.dart';
import '../../../src/demo_data.dart';
import '../../../src/demo_data_list.dart';
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
  final RxString demoStep = ''.obs;
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

  // ---------- Demo data ----------

  void _setStep(String key, [Map<String, String>? params]) =>
      demoStep.value = params == null ? key.tr : key.trParams(params);

  void openDemoSheet() {
    demoStep.value = '';
    AppBottomSheet(
      buttonText: 'Generate demo data'.tr,
      function: _generateDemo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),
          Row(children: [
            const IconBubble(icon: Icons.auto_awesome),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Demo data'.tr,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 10),
          Text(
              'Fills the app with @c courses, @l lecturers and @s students, with lectures and past attendance — ready for screenshots and demos. Anything that already exists is kept.'
                  .trParams({
                'c': '${DemoData.courses.length}',
                'l': '${DemoData.lecturers.length}',
                's': '${DemoData.students.length}',
              }),
              style: TextStyle(color: Colors.grey[700], height: 1.5)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(.1),
                borderRadius: BorderRadius.circular(14)),
            child: Text(
                'Every new account gets its own strong password. You will see them all once at the end, with a button to copy them.'
                    .tr,
                style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Obx(() => demoStep.value.isEmpty
              ? const SizedBox()
              : Row(children: [
                  SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.color1)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(demoStep.value)),
                ])),
          const SizedBox(height: 6),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppColors.danger),
              onPressed: _confirmRemoveDemo,
              icon: const Icon(Icons.delete_sweep_outlined),
              label: Text('Delete demo lectures'.tr),
            ),
          ),
        ],
      ),
    ).bottomSheet();
  }

  Future<void> _generateDemo() async {
    try {
      final r = await DemoDataService.generate(_setStep);
      demoStep.value = '';
      Get.back();
      Ui.success(
          'Done: @a new accounts, @l lectures and @t attendance records.'
              .trParams({
        'a': '${r.accountsCreated}',
        'l': '${r.lecturesCreated}',
        't': '${r.attendanceCreated}',
      }));
      if (r.newAccounts.isNotEmpty) _showAccounts(r);
      if (r.stoppedByLimit) {
        Future.delayed(const Duration(seconds: 4), () {
          Ui.info(
              'Firebase allows a limited number of new accounts per hour. Run it again in an hour to finish.');
        });
      }
    } catch (e) {
      demoStep.value = '';
      AppErrors.show(e);
    }
  }

  /// Shows the new accounts and passwords once, with a button to copy them.
  void _showAccounts(DemoResult r) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 560, maxHeight: Get.height * .85),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('New accounts'.tr,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AppColors.danger.withOpacity(.08),
                      borderRadius: BorderRadius.circular(14)),
                  child: Text(
                      'Copy these passwords now and keep them somewhere safe. They are shown only once and are not saved in the app.'
                          .tr,
                      style: TextStyle(color: AppColors.danger, height: 1.5)),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: r.newAccounts.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final a = r.newAccounts[i];
                      return ListTile(
                        dense: true,
                        title: Text('${a['name']} · ${a['type']}'),
                        subtitle: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text('${a['email']}   ${a['password']}'),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 50,
                  child: TextButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: r.accountsCsv));
                      Ui.success(
                          'Copied. Paste it into Excel or Notes and save it.');
                    },
                    icon: const Icon(Icons.copy_all_outlined),
                    label: Text('Copy all (for Excel)'.tr),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: AppColors.color4,
                      foregroundColor: AppColors.primaryColor),
                  onPressed: () => Get.back(),
                  child: Text('Close'.tr),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _confirmRemoveDemo() {
    AppDialogs.confirm(
      title: 'Delete demo lectures',
      message:
          'This deletes the demo lectures and their attendance. Courses and accounts stay.'
              .tr,
      onConfirm: () async {
        final n = await DemoDataService.removeDemoLectures(_setStep);
        demoStep.value = '';
        Ui.success('@n demo lectures deleted'.trParams({'n': '$n'}));
      },
    );
  }
}
