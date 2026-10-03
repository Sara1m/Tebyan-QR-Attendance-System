import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'errors.dart';
import 'location_service.dart';
import 'session.dart';

/// Data read from an attendance QR code.
class ScanData {
  ScanData({
    required this.courseId,
    required this.lectureId,
    required this.code,
    required this.expiresAt,
    this.issuedAt,
  });
  final String courseId;
  final String lectureId;
  final String code;
  final DateTime expiresAt;

  /// When this (rotating) code was shown on the lecturer's screen.
  final DateTime? issuedAt;
}

/// The attendance session the lecturer just opened.
class AttendanceSessionInfo {
  AttendanceSessionInfo(
      {required this.code, required this.expiresAt, required this.issuedAt});
  final String code;
  final DateTime expiresAt;
  final DateTime issuedAt;
}

/// Everything related to QR attendance.
///
/// Database layout:
///   Courses/{course}/Lectures/{lecture}                    qrExpiresAt
///   Courses/{course}/Lectures/{lecture}/Session/current
///       token, prevToken, tokenAt, expiresAt, radius, lat, lng, lngScale,
///       tolerance   (secret: only the lecturer can read it)
///
/// The code changes every [rotateSeconds] seconds, so a photo of the QR code
/// sent to someone outside the classroom stops working almost immediately.
///   Courses/{course}/Lectures/{lecture}/Attendance/{uid}   name, email, time
class AttendanceService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _prefix = 'TEBYAN';

  /// How often the code on the lecturer's screen changes.
  static const int rotateSeconds = 20;

  static DocumentReference<Map<String, dynamic>> lectureRef(
          String courseId, String lectureId) =>
      _db
          .collection('Courses')
          .doc(courseId)
          .collection('Lectures')
          .doc(lectureId);

  static DocumentReference<Map<String, dynamic>> sessionRef(
          String courseId, String lectureId) =>
      lectureRef(courseId, lectureId).collection('Session').doc('current');

  static CollectionReference<Map<String, dynamic>> attendanceCol(
          String courseId, String lectureId) =>
      lectureRef(courseId, lectureId).collection('Attendance');

  /// 8 characters that are easy to read (no 0/O or 1/I).
  static String newCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = Random.secure();
    return List.generate(8, (_) => chars[r.nextInt(chars.length)]).join();
  }

  /// Opens attendance for [minutes] minutes and returns the first code.
  /// When [area] is given, students must be inside it to check in.
  static Future<AttendanceSessionInfo> start(
      String courseId, String lectureId, int minutes,
      {GeoArea? area}) async {
    final code = newCode();
    final now = DateTime.now();
    final expiresAt = now.add(Duration(minutes: minutes));
    final batch = _db.batch();
    batch.set(sessionRef(courseId, lectureId), {
      'token': code,
      'prevToken': '',
      'tokenAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'minutes': minutes,
      'createdBy': Session.userId,
      'createdAt': FieldValue.serverTimestamp(),
      'radius': area?.radius ?? 0,
      'lat': area?.lat ?? 0.0,
      'lng': area?.lng ?? 0.0,
      'lngScale': area?.lngScale ?? 0.0,
      'tolerance': area?.tolerance ?? 0,
    });
    batch.update(lectureRef(courseId, lectureId), {
      'qrExpiresAt': Timestamp.fromDate(expiresAt),
      // Public copy of the area so the student's phone can check it first.
      'geoRadius': area?.radius ?? 0,
      'geoLat': area?.lat ?? 0.0,
      'geoLng': area?.lng ?? 0.0,
      'geoScale': area?.lngScale ?? 0.0,
      'geoTolerance': area?.tolerance ?? 0,
    });
    await batch.commit();
    return AttendanceSessionInfo(code: code, expiresAt: expiresAt, issuedAt: now);
  }

  /// Replaces the current code with a new one. The previous code keeps
  /// working for a few more seconds so students scanning right now are fine.
  static Future<AttendanceSessionInfo> rotate(String courseId,
      String lectureId, String previousCode, DateTime expiresAt) async {
    final code = newCode();
    await sessionRef(courseId, lectureId).update({
      'prevToken': previousCode,
      'token': code,
      'tokenAt': FieldValue.serverTimestamp(),
    });
    return AttendanceSessionInfo(
        code: code, expiresAt: expiresAt, issuedAt: DateTime.now());
  }

  /// Closes attendance immediately.
  static Future<void> stop(String courseId, String lectureId) async {
    final now = Timestamp.now();
    final batch = _db.batch();
    batch.set(sessionRef(courseId, lectureId), {'expiresAt': now},
        SetOptions(merge: true));
    batch.update(lectureRef(courseId, lectureId), {'qrExpiresAt': now});
    await batch.commit();
  }

  static String payload(String courseId, String lectureId,
          AttendanceSessionInfo info) =>
      '$_prefix|$courseId|$lectureId|${info.code}|'
      '${info.expiresAt.millisecondsSinceEpoch}|'
      '${info.issuedAt.millisecondsSinceEpoch}';

  static ScanData? parse(String? raw) {
    if (raw == null) return null;
    final parts = raw.trim().split('|');
    if ((parts.length != 5 && parts.length != 6) || parts[0] != _prefix) {
      return null;
    }
    final ms = int.tryParse(parts[4]);
    if (ms == null) return null;
    final issued = parts.length == 6 ? int.tryParse(parts[5]) : null;
    return ScanData(
      courseId: parts[1],
      lectureId: parts[2],
      code: parts[3],
      expiresAt: DateTime.fromMillisecondsSinceEpoch(ms),
      issuedAt:
          issued == null ? null : DateTime.fromMillisecondsSinceEpoch(issued),
    );
  }

  static String normalizeCode(String code) =>
      code.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

  /// Records the signed-in student's attendance.
  /// Returns the lecture name, or throws an [AppException] with the reason.
  static Future<String> submit({
    required String courseId,
    required String lectureId,
    required String code,
    DateTime? expiresAt,
    DateTime? issuedAt,
    String method = 'qr',
    void Function(String step)? onStep,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw const AppException('Please sign in again and retry');

    if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
      throw const AppException(
          'This code has expired, ask the lecturer for a new one');
    }

    // A screenshot of an old code (e.g. sent by a friend).
    if (issuedAt != null &&
        DateTime.now().difference(issuedAt).inSeconds > rotateSeconds * 4) {
      throw const AppException(
          "This code is old. Scan the code shown on the lecturer's screen right now.");
    }

    final cleanCode = normalizeCode(code);
    if (cleanCode.length != 8) throw const AppException('Invalid code');

    final me = await _db.collection('Users').doc(user.uid).get();
    final myCourses = List<dynamic>.from(me.data()?['courses'] ?? []);
    if (!myCourses.contains(courseId)) {
      throw const AppException('You are not registered in this course');
    }

    final lecture = await lectureRef(courseId, lectureId).get();
    if (!lecture.exists) throw const AppException('Invalid code');
    final lectureName = '${lecture.data()?['name'] ?? ''}';

    final qrExpires = lecture.data()?['qrExpiresAt'];
    if (qrExpires is Timestamp &&
        DateTime.now().isAfter(qrExpires.toDate().add(const Duration(seconds: 5)))) {
      throw const AppException(
          'This code has expired, ask the lecturer for a new one');
    }

    final myRecord = attendanceCol(courseId, lectureId).doc(user.uid);
    if ((await myRecord.get()).exists) {
      throw const AppException('Your attendance is already recorded');
    }

    // Classroom location check (when the lecturer turned it on).
    final data = lecture.data() ?? <String, dynamic>{};
    final radius = (data['geoRadius'] as num?)?.toInt() ?? 0;
    final location = <String, dynamic>{};
    if (radius > 0) {
      onStep?.call('Checking your location…');
      final pos = await LocationService.current();
      final tolerance = (data['geoTolerance'] as num?)?.toInt() ?? 0;
      final d = LocationService.distance(
        lat: pos.latitude,
        lng: pos.longitude,
        centerLat: (data['geoLat'] as num?)?.toDouble() ?? 0,
        centerLng: (data['geoLng'] as num?)?.toDouble() ?? 0,
        scale: (data['geoScale'] as num?)?.toDouble() ?? 0,
      );
      if (d > radius + tolerance) {
        throw AppException(
            'You are @d m away from the classroom. You must be within @r m to check in.',
            {'d': d.round().toString(), 'r': radius.toString()});
      }
      location.addAll({
        'lat': pos.latitude,
        'lng': pos.longitude,
        'distance': d.round(),
        'accuracy': pos.accuracy.round(),
      });
    }
    onStep?.call('Recording your attendance…');

    try {
      await myRecord.set({
        'studentId': user.uid,
        'name': me.data()?['name'] ?? '',
        'email': me.data()?['email'] ?? user.email ?? '',
        'time': FieldValue.serverTimestamp(),
        'token': cleanCode,
        'method': method,
        ...location,
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const AppException(
            'The code is invalid or has expired. Scan the code shown on the screen right now.');
      }
      rethrow;
    }
    return lectureName;
  }

  /// Lecturer marks a student present by hand.
  static Future<void> markPresent({
    required String courseId,
    required String lectureId,
    required String studentId,
    required String name,
    required String email,
  }) {
    return attendanceCol(courseId, lectureId).doc(studentId).set({
      'studentId': studentId,
      'name': name,
      'email': email,
      'time': FieldValue.serverTimestamp(),
      'token': 'manual',
      'method': 'manual',
      'markedBy': Session.userId,
    });
  }

  static Future<void> unmark(
          {required String courseId,
          required String lectureId,
          required String studentId}) =>
      attendanceCol(courseId, lectureId).doc(studentId).delete();

  /// Deletes a lecture together with its attendance records.
  static Future<void> deleteLecture(String courseId, String lectureId) async {
    final batch = _db.batch();
    final records = await attendanceCol(courseId, lectureId).get();
    for (final d in records.docs) {
      batch.delete(d.reference);
    }
    batch.delete(sessionRef(courseId, lectureId));
    batch.delete(lectureRef(courseId, lectureId));
    await batch.commit();
  }
}
