import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../src/attendance_service.dart';
import '../../../src/errors.dart';
import '../../../src/location_service.dart';
import '../../../src/session.dart';

class AttendanceQrController extends GetxController {
  String courseId = '';
  String lectureId = '';
  String lectureName = '';
  String courseName = '';
  int minutes = 5;
  bool requireLocation = false;
  int radius = 100;

  final Rxn<AttendanceSessionInfo> session = Rxn<AttendanceSessionInfo>();
  final Rxn<GeoArea> area = Rxn<GeoArea>();
  final RxInt remaining = 0.obs;
  final RxInt total = 1.obs;
  final RxInt nextChange = AttendanceService.rotateSeconds.obs;
  final RxBool starting = true.obs;
  final RxString step = ''.obs;
  final RxString error = ''.obs;
  final RxList<Map<String, dynamic>> present = <Map<String, dynamic>>[].obs;

  Timer? _timer;
  StreamSubscription? _sub;
  bool _rotating = false;

  bool get ready => courseId.isNotEmpty && lectureId.isNotEmpty;
  bool get expired => session.value != null && remaining.value <= 0;

  String get code => session.value?.code ?? '';
  String get prettyCode =>
      code.length == 8 ? '${code.substring(0, 4)}-${code.substring(4)}' : code;

  String get payload => session.value == null
      ? ''
      : AttendanceService.payload(courseId, lectureId, session.value!);

  String get clock {
    final r = remaining.value;
    final m = (r ~/ 60).toString().padLeft(2, '0');
    final s = (r % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get progress => total.value <= 0
      ? 0
      : (remaining.value / total.value).clamp(0, 1).toDouble();

  @override
  void onInit() {
    super.onInit();
    final a = Get.arguments;
    if (a is Map) {
      courseId = '${a['courseId'] ?? ''}';
      lectureId = '${a['lectureId'] ?? ''}';
      lectureName = '${a['lectureName'] ?? ''}';
      courseName = '${a['courseName'] ?? ''}';
      minutes = (a['minutes'] is int) ? a['minutes'] as int : 5;
      requireLocation = a['requireLocation'] == true;
      radius = (a['radius'] is int) ? a['radius'] as int : 100;
    }
    if (!ready) {
      Future.microtask(() => Get.offAllNamed(Session.homeRoute));
      return;
    }
    _sub = AttendanceService.attendanceCol(courseId, lectureId)
        .snapshots()
        .listen((qs) {
      final list = qs.docs.map((d) => d.data()).toList()
        ..sort((a, b) {
          final ta = a['time'], tb = b['time'];
          if (ta is Timestamp && tb is Timestamp) return tb.compareTo(ta);
          return ta is Timestamp ? 1 : -1;
        });
      present.value = list;
    }, onError: (e) => AppErrors.show(e));
    start();
  }

  Future<void> start([int? newMinutes]) async {
    if (newMinutes != null) minutes = newMinutes;
    _timer?.cancel();
    starting.value = true;
    error.value = '';
    try {
      GeoArea? geo;
      if (requireLocation) {
        step.value = 'Getting your location…';
        final pos = await LocationService.current();
        // Allow extra metres when the lecturer's own location is not precise.
        final tolerance = pos.accuracy.clamp(30, 150).round();
        geo = GeoArea(
          lat: pos.latitude,
          lng: pos.longitude,
          radius: radius,
          tolerance: tolerance,
          accuracy: pos.accuracy,
        );
        area.value = geo;
      }
      step.value = 'Creating the code…';
      session.value = await AttendanceService.start(
          courseId, lectureId, minutes,
          area: geo);
      total.value = minutes * 60;
      nextChange.value = AttendanceService.rotateSeconds;
      _tick();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    } catch (e) {
      error.value = AppErrors.text(e);
    } finally {
      starting.value = false;
      step.value = '';
    }
  }

  void _tick() {
    final s = session.value;
    if (s == null) return;
    final left = s.expiresAt.difference(DateTime.now()).inSeconds;
    remaining.value = left < 0 ? 0 : left;
    if (remaining.value == 0) {
      _timer?.cancel();
      return;
    }
    nextChange.value = nextChange.value - 1;
    if (nextChange.value <= 0) {
      nextChange.value = AttendanceService.rotateSeconds;
      _rotate();
    }
  }

  Future<void> _rotate() async {
    final s = session.value;
    if (s == null || _rotating) return;
    _rotating = true;
    try {
      session.value = await AttendanceService.rotate(
          courseId, lectureId, s.code, s.expiresAt);
    } catch (e) {
      AppErrors.show(e);
    } finally {
      _rotating = false;
    }
  }

  Future<void> endNow() async {
    try {
      await AttendanceService.stop(courseId, lectureId);
      _timer?.cancel();
      remaining.value = 0;
    } catch (e) {
      AppErrors.show(e);
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    _sub?.cancel();
    super.onClose();
  }
}
