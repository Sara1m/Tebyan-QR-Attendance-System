import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../src/alert.dart';
import '../../../src/attendance_service.dart';
import '../../../src/errors.dart';
import '../../../src/session.dart';

/// A student row in the attendance list.
class StudentRow {
  StudentRow(
      {required this.id,
      required this.name,
      required this.email,
      this.time,
      this.method,
      this.distance});
  final String id;
  final String name;
  final String email;
  final DateTime? time;
  final String? method;

  /// Metres from the classroom when the student checked in (if measured).
  final int? distance;
}

class AttendanceListController extends GetxController {
  String courseId = '';
  String lectureId = '';
  String lectureName = '';
  String courseName = '';

  final RxMap<String, Map<String, dynamic>> attendance =
      <String, Map<String, dynamic>>{}.obs;
  final RxList<Map<String, dynamic>> enrolled = <Map<String, dynamic>>[].obs;
  final RxBool loading = true.obs;
  final RxInt tab = 0.obs; // 0 = present, 1 = absent

  StreamSubscription? _attSub;
  StreamSubscription? _usersSub;

  bool get ready => courseId.isNotEmpty && lectureId.isNotEmpty;

  List<StudentRow> get presentRows {
    final rows = attendance.entries.map((e) {
      final t = e.value['time'];
      return StudentRow(
        id: e.key,
        name: '${e.value['name'] ?? ''}',
        email: '${e.value['email'] ?? ''}',
        time: t is Timestamp ? t.toDate() : null,
        method: '${e.value['method'] ?? 'qr'}',
        distance: (e.value['distance'] as num?)?.toInt(),
      );
    }).toList()
      ..sort((a, b) => (a.time ?? DateTime(3000)).compareTo(b.time ?? DateTime(3000)));
    return rows;
  }

  List<StudentRow> get absentRows => enrolled
      .where((u) => !attendance.containsKey('${u['id']}'))
      .map((u) => StudentRow(
          id: '${u['id']}',
          name: '${u['name'] ?? ''}',
          email: '${u['email'] ?? ''}'))
      .toList()
    ..sort((a, b) => a.name.compareTo(b.name));

  int get enrolledCount {
    final ids = enrolled.map((u) => '${u['id']}').toSet()
      ..addAll(attendance.keys);
    return ids.length;
  }

  int get percent => enrolledCount == 0
      ? 0
      : ((attendance.length / enrolledCount) * 100).round();

  String timeText(DateTime? t) =>
      t == null ? '…' : DateFormat('hh:mm a', 'en_US').format(t);

  @override
  void onInit() {
    super.onInit();
    final a = Get.arguments;
    if (a is Map) {
      courseId = '${a['courseId'] ?? ''}';
      lectureId = '${a['lectureId'] ?? ''}';
      lectureName = '${a['lectureName'] ?? ''}';
      courseName = '${a['courseName'] ?? ''}';
    }
    if (!ready) {
      Future.microtask(() => Get.offAllNamed(Session.homeRoute));
      return;
    }
    _attSub = AttendanceService.attendanceCol(courseId, lectureId)
        .snapshots()
        .listen((qs) {
      attendance.value = {for (final d in qs.docs) d.id: d.data()};
      loading.value = false;
    }, onError: (e) {
      loading.value = false;
      AppErrors.show(e);
    });
    _usersSub = FirebaseFirestore.instance
        .collection('Users')
        .where('courses', arrayContains: courseId)
        .snapshots()
        .listen((qs) {
      enrolled.value = qs.docs
          .map((d) => {...d.data(), 'id': d.id})
          .where((u) => u['type'] == Session.studentType)
          .toList();
    }, onError: (e) => AppErrors.show(e));
  }

  @override
  void onClose() {
    _attSub?.cancel();
    _usersSub?.cancel();
    super.onClose();
  }

  Future<void> markPresent(StudentRow s) async {
    try {
      await AttendanceService.markPresent(
          courseId: courseId,
          lectureId: lectureId,
          studentId: s.id,
          name: s.name,
          email: s.email);
      Ui.success('@name marked present'.trParams({'name': s.name}));
    } catch (e) {
      AppErrors.show(e);
    }
  }

  Future<void> unmark(StudentRow s) async {
    try {
      await AttendanceService.unmark(
          courseId: courseId, lectureId: lectureId, studentId: s.id);
      Ui.info('@name marked absent'.trParams({'name': s.name}));
    } catch (e) {
      AppErrors.show(e);
    }
  }
}
