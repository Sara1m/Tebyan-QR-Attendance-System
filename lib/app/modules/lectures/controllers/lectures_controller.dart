import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../routes/app_pages.dart';
import '../../../src/alert.dart';
import '../../../src/attendance_service.dart';
import '../../../src/bottom_sheet.dart';
import '../../../src/colors.dart';
import '../../../src/dialogs.dart';
import '../../../src/errors.dart';
import '../../../src/session.dart';
import '../../../src/widgets.dart';

typedef LectureDoc = QueryDocumentSnapshot<Map<String, dynamic>>;

class LecturesController extends GetxController {
  String courseId = '';
  Map<String, dynamic> courseData = <String, dynamic>{};
  bool get ready => courseId.isNotEmpty;

  final RxList<LectureDoc> lectures = <LectureDoc>[].obs;
  final RxSet<String> attended = <String>{}.obs;
  final RxBool loading = true.obs;
  final RxInt tick = 0.obs; // refreshes "attendance open" badges

  final TextEditingController name = TextEditingController();
  final TextEditingController date = TextEditingController();
  final TextEditingController time = TextEditingController();
  final TextEditingController manualCode = TextEditingController();
  final RxInt minutes = 5.obs;
  final RxBool requireLocation = true.obs;
  final RxInt radius = 100.obs;

  StreamSubscription? _sub;
  Timer? _timer;

  bool get isStudent => Session.isStudent;
  String get courseName => '${courseData['name'] ?? ''}';
  String get courseCode => '${courseData['code'] ?? ''}';

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance
          .collection('Courses')
          .doc(courseId)
          .collection('Lectures');

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    final course = args is Map ? args['course'] : null;
    if (course is DocumentSnapshot) {
      courseId = course.id;
      final d = course.data();
      if (d is Map<String, dynamic>) courseData = d;
    }
    if (!ready) {
      // Opened directly (e.g. page refresh) without a course: go home.
      Future.microtask(() => Get.offAllNamed(Session.homeRoute));
      return;
    }
    _sub = _col.snapshots().listen((qs) {
      final list = qs.docs.toList()..sort((a, b) => _key(a).compareTo(_key(b)));
      lectures.value = list;
      loading.value = false;
      if (isStudent) _loadMyAttendance();
    }, onError: (e) {
      loading.value = false;
      AppErrors.show(e);
    });
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => tick.value++);
  }

  @override
  void onClose() {
    _sub?.cancel();
    _timer?.cancel();
    super.onClose();
  }

  // ---------- helpers ----------

  static int _minutesOf(String t) {
    final m = RegExp(r'(\d{1,2}):(\d{1,2})\s*([aApP][mM])?').firstMatch(t);
    if (m == null) return 0;
    var h = int.parse(m.group(1)!);
    final min = int.parse(m.group(2)!);
    final p = (m.group(3) ?? '').toLowerCase();
    if (p == 'pm' && h < 12) h += 12;
    if (p == 'am' && h == 12) h = 0;
    return h * 60 + min;
  }

  static String _key(LectureDoc d) =>
      '${d.data()['date'] ?? ''} ${_minutesOf('${d.data()['time'] ?? ''}').toString().padLeft(4, '0')}';

  bool isOpen(LectureDoc l) {
    tick.value; // make Obx rebuild periodically
    final t = l.data()['qrExpiresAt'];
    return t is Timestamp && t.toDate().isAfter(DateTime.now());
  }

  bool isPast(LectureDoc l) {
    final d = '${l.data()['date'] ?? ''}';
    final today = DateFormat('yyyy-MM-dd', 'en_US').format(DateTime.now());
    return d.isNotEmpty && d.compareTo(today) < 0;
  }

  bool isToday(LectureDoc l) =>
      '${l.data()['date'] ?? ''}' ==
      DateFormat('yyyy-MM-dd', 'en_US').format(DateTime.now());

  String prettyDate(String raw) {
    final d = DateTime.tryParse(raw);
    if (d == null) return raw;
    final locale = Get.locale?.languageCode == 'ar' ? 'ar' : 'en_US';
    try {
      return DateFormat('EEE d MMM yyyy', locale).format(d);
    } catch (_) {
      return raw;
    }
  }

  Future<void> _loadMyAttendance() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final results = await Future.wait(lectures.map((l) =>
          AttendanceService.attendanceCol(courseId, l.id).doc(uid).get()));
      final set = <String>{};
      for (var i = 0; i < results.length && i < lectures.length; i++) {
        if (results[i].exists) set.add(lectures[i].id);
      }
      attended.value = set;
    } catch (_) {}
  }

  int get attendedCount => attended.length;
  int get pastOrTodayCount =>
      lectures.where((l) => isPast(l) || isToday(l)).length;

  // ---------- lecturer: add / edit / delete ----------

  void openForm(BuildContext context, {LectureDoc? lecture}) {
    final create = lecture == null;
    final data = lecture?.data() ?? <String, dynamic>{};
    name.text = '${data['name'] ?? ''}';
    date.text = '${data['date'] ?? ''}';
    time.text = '${data['time'] ?? ''}';
    final id = lecture?.id ?? '';
    AppBottomSheet(
      buttonText: (create ? 'Create' : 'Save').tr,
      function: () => create ? _create() : _edit(id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),
          Row(children: [
            const IconBubble(icon: Icons.co_present_outlined),
            const SizedBox(width: 12),
            Text((create ? 'Add Lecture' : 'Edit Lecture').tr,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ]),
          FieldLabel('Lecture Name'.tr),
          TextField(
            controller: name,
            decoration: InputDecoration(
                hintText: 'e.g. Introduction to Data Structures'.tr,
                prefixIcon: const Icon(Icons.title)),
          ),
          FieldLabel('Date'.tr),
          TextField(
            controller: date,
            readOnly: true,
            onTap: () => _pickDate(context),
            decoration: InputDecoration(
                hintText: 'Choose Date'.tr,
                prefixIcon: const Icon(Icons.calendar_today_outlined)),
          ),
          FieldLabel('Time'.tr),
          TextField(
            controller: time,
            readOnly: true,
            onTap: () => _pickTime(context),
            decoration: InputDecoration(
                hintText: 'Choose Time'.tr,
                prefixIcon: const Icon(Icons.access_time)),
          ),
        ],
      ),
    ).bottomSheet();
  }

  Future<void> _pickDate(BuildContext context) async {
    final current = DateTime.tryParse(date.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: Get.overlayContext ?? context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (picked != null) {
      date.text = DateFormat('yyyy-MM-dd', 'en_US').format(picked);
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final m = _minutesOf(time.text);
    final picked = await showTimePicker(
      context: Get.overlayContext ?? context,
      initialTime: time.text.isEmpty
          ? TimeOfDay.now()
          : TimeOfDay(hour: m ~/ 60, minute: m % 60),
    );
    if (picked != null) {
      time.text = DateFormat('hh:mm a', 'en_US')
          .format(DateTime(2000, 1, 1, picked.hour, picked.minute));
    }
  }

  bool _validate() {
    if (name.text.trim().isEmpty) {
      Ui.info('Please enter the lecture name');
      return false;
    }
    if (date.text.trim().isEmpty) {
      Ui.info('Please enter the lecture date');
      return false;
    }
    if (time.text.trim().isEmpty) {
      Ui.info('Please enter the lecture time');
      return false;
    }
    return true;
  }

  Future<void> _create() async {
    if (!_validate()) return;
    try {
      await _col.add({
        'name': name.text.trim(),
        'date': date.text.trim(),
        'time': time.text.trim(),
        'course': courseData,
        'createdBy': Session.userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      Get.back();
      Ui.success('Lecture added');
    } catch (e) {
      AppErrors.show(e);
    }
  }

  Future<void> _edit(String id) async {
    if (!_validate()) return;
    try {
      await _col.doc(id).update({
        'name': name.text.trim(),
        'date': date.text.trim(),
        'time': time.text.trim(),
      });
      Get.back();
      Ui.success('Changes saved');
    } catch (e) {
      AppErrors.show(e);
    }
  }

  void confirmDelete(LectureDoc lecture) {
    AppDialogs.confirm(
      title: 'Delete Lecture',
      message: 'Are you sure you want to delete @name and its attendance records?'
          .trParams({'name': '${lecture.data()['name']}'}),
      onConfirm: () async {
        await AttendanceService.deleteLecture(courseId, lecture.id);
        Ui.success('Lecture deleted');
      },
    );
  }

  // ---------- lecturer: attendance ----------

  void openAttendanceSheet(LectureDoc lecture) {
    minutes.value = 5;
    const options = [1, 2, 3, 5, 10, 15, 30];
    AppBottomSheet(
      buttonText: 'Show QR code'.tr,
      function: () async {
        Get.back();
        Get.toNamed(Routes.ATTENDANCE_QR, arguments: {
          'courseId': courseId,
          'lectureId': lecture.id,
          'lectureName': '${lecture.data()['name'] ?? ''}',
          'courseName': courseName,
          'minutes': minutes.value,
          'requireLocation': requireLocation.value,
          'radius': radius.value,
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),
          Row(children: [
            const IconBubble(icon: Icons.qr_code_2),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Take attendance'.tr,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(
              'Choose how long the code stays valid. Students scan it with their phone camera.'
                  .tr,
              style: TextStyle(color: Colors.grey[700], height: 1.5)),
          FieldLabel('Valid for'.tr),
          Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: options
                    .map((m) => ChoiceChip(
                          label: Text('@m min'.trParams({'m': '$m'})),
                          selected: minutes.value == m,
                          showCheckmark: false,
                          selectedColor: AppColors.color1,
                          labelStyle: TextStyle(
                              color: minutes.value == m
                                  ? Colors.white
                                  : AppColors.primaryColor,
                              fontWeight: FontWeight.bold),
                          onSelected: (_) => minutes.value = m,
                        ))
                    .toList(),
              )),
          const SizedBox(height: 14),
          Obx(() => Container(
                decoration: BoxDecoration(
                  color: AppColors.color4.withOpacity(.6),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: SwitchListTile(
                  value: requireLocation.value,
                  onChanged: (v) => requireLocation.value = v,
                  activeColor: AppColors.color1,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  secondary: Icon(Icons.location_on_outlined,
                      color: AppColors.color1),
                  title: Text('Students must be in the classroom'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'Your location is used as the classroom location.'.tr,
                      style: const TextStyle(fontSize: 12)),
                ),
              )),
          Obx(() => requireLocation.value
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel('Allowed distance'.tr),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [50, 100, 200, 500, 1000]
                          .map((r) => ChoiceChip(
                                label: Text(r == 1000
                                    ? '1 km (campus)'.tr
                                    : '@r m'.trParams({'r': '$r'})),
                                selected: radius.value == r,
                                showCheckmark: false,
                                selectedColor: AppColors.color1,
                                labelStyle: TextStyle(
                                    color: radius.value == r
                                        ? Colors.white
                                        : AppColors.primaryColor,
                                    fontWeight: FontWeight.bold),
                                onSelected: (_) => radius.value = r,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                        'Tip: indoors, phone locations can be off by 20–100 m. If students inside are rejected, choose a larger distance.'
                            .tr,
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: 12, height: 1.5)),
                  ],
                )
              : const SizedBox()),
        ],
      ),
    ).bottomSheet();
  }

  void openAttendanceList(LectureDoc lecture) {
    Get.toNamed(Routes.ATTENDANCE_LIST, arguments: {
      'courseId': courseId,
      'lectureId': lecture.id,
      'lectureName': '${lecture.data()['name'] ?? ''}',
      'courseName': courseName,
    });
  }

  // ---------- student: attendance ----------

  Future<void> scan(LectureDoc lecture) async {
    final result = await Get.toNamed(Routes.SCAN, arguments: {
      'courseId': courseId,
      'lectureId': lecture.id,
      'lectureName': '${lecture.data()['name'] ?? ''}',
    });
    if (result == true) attended.add(lecture.id);
  }

  void enterCode(LectureDoc lecture) {
    manualCode.clear();
    AppBottomSheet(
      buttonText: 'Confirm attendance'.tr,
      function: () async {
        try {
          final lectureName = await AttendanceService.submit(
            courseId: courseId,
            lectureId: lecture.id,
            code: manualCode.text,
            method: 'code',
          );
          Get.back();
          attended.add(lecture.id);
          AppDialogs.result(
            success: true,
            title: 'Attendance recorded',
            message: 'Your attendance for @lecture has been recorded.'
                .trParams({'lecture': lectureName}),
          );
        } catch (e) {
          AppErrors.show(e);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),
          Row(children: [
            const IconBubble(icon: Icons.keyboard_alt_outlined),
            const SizedBox(width: 12),
            Text('Enter attendance code'.tr,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 8),
          Text(
              'Type the 8-character code shown under the QR code on the lecturer\'s screen right now. It changes every 20 seconds.'
                  .tr,
              style: TextStyle(color: Colors.grey[700], height: 1.5)),
          const SizedBox(height: 16),
          TextField(
            controller: manualCode,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            maxLength: 9,
            style: const TextStyle(
                fontSize: 24, letterSpacing: 6, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
                hintText: 'XXXX-XXXX', counterText: ''),
          ),
        ],
      ),
    ).bottomSheet();
  }
}
