import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';

import 'attendance_service.dart';
import 'demo_data_list.dart';
import 'session.dart';

/// Summary of what the demo data generator did.
class DemoResult {
  int coursesCreated = 0;
  int accountsCreated = 0;
  int accountsExisting = 0;
  int lecturesCreated = 0;
  int attendanceCreated = 0;
  bool stoppedByLimit = false;

  /// The new accounts and their passwords. Shown once to the admin and never
  /// saved anywhere by the app.
  final List<Map<String, String>> newAccounts = [];

  String get accountsCsv {
    final b = StringBuffer('Type,Name,Email,Password,Courses\n');
    for (final a in newAccounts) {
      b.writeln(
          '${a['type']},${a['name']},${a['email']},${a['password']},${a['courses']}');
    }
    return b.toString();
  }
}

/// Fills the database with realistic demo courses, lecturers, students,
/// lectures and attendance — so the app looks real for screenshots and demos.
/// Running it again is safe: anything that already exists is reused.
class DemoDataService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const List<String> _topics = [
    'Introduction and course overview',
    'Core concepts',
    'Hands-on lab',
    'Problem solving session',
    'Case study',
    'Review and practice',
  ];

  /// Days from today for each demo lecture (negative = in the past).
  static const List<int> _offsets = [-28, -21, -14, -7, 7, 14];

  /// A random 12-character password with upper/lower case, digits and symbols.
  static String _password() {
    const lower = 'abcdefghijkmnpqrstuvwxyz';
    const upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
    const digits = '23456789';
    const symbols = '!@#%&*?';
    const all = lower + upper + digits + symbols;
    final r = Random.secure();
    final chars = [
      lower[r.nextInt(lower.length)],
      upper[r.nextInt(upper.length)],
      digits[r.nextInt(digits.length)],
      symbols[r.nextInt(symbols.length)],
      for (var i = 0; i < 8; i++) all[r.nextInt(all.length)],
    ]..shuffle(r);
    return chars.join();
  }

  static Future<FirebaseAuth> _secondaryAuth() async {
    FirebaseApp app;
    try {
      app = Firebase.app('secondary');
    } catch (_) {
      app = await Firebase.initializeApp(
          name: 'secondary', options: Firebase.app().options);
    }
    return FirebaseAuth.instanceFor(app: app);
  }

  static Future<DemoResult> generate(
      void Function(String key, [Map<String, String>? params]) onStep) async {
    final result = DemoResult();
    final random = Random(42);

    // ---------- 1. Courses ----------
    onStep('Creating courses…');
    final courseSnap = await _db.collection('Courses').get();
    final idByCode = <String, String>{};
    final dataByCode = <String, Map<String, dynamic>>{};
    for (final d in courseSnap.docs) {
      final code = '${d.data()['code']}'.toUpperCase();
      idByCode[code] = d.id;
      dataByCode[code] = d.data();
    }
    for (final c in DemoData.courses) {
      if (idByCode.containsKey(c.code)) continue;
      final ref = _db.collection('Courses').doc();
      final data = {
        'id': ref.id,
        'name': c.name,
        'code': c.code,
        'hours': '${c.hours}',
      };
      await ref.set(data);
      idByCode[c.code] = ref.id;
      dataByCode[c.code] = data;
      result.coursesCreated++;
    }

    // ---------- 2. Accounts ----------
    final userSnap = await _db.collection('Users').get();
    final uidByEmail = <String, String>{
      for (final d in userSnap.docs)
        '${d.data()['email']}'.toLowerCase(): d.id,
    };
    final auth = await _secondaryAuth();
    final studentsByCourse = <String, List<Map<String, String>>>{};

    final people = [
      ...DemoData.lecturers.map((p) => (p, Session.lecturerType)),
      ...DemoData.students.map((p) => (p, Session.studentType)),
    ];
    var n = 0;
    for (final (person, type) in people) {
      n++;
      onStep('Creating accounts… @n/@total',
          {'n': '$n', 'total': '${people.length}'});
      final courseIds = person.courses
          .map((code) => idByCode[code])
          .whereType<String>()
          .toList();
      var uid = uidByEmail[person.email.toLowerCase()];

      if (uid == null && !result.stoppedByLimit) {
        try {
          final password = _password();
          final cred = await auth.createUserWithEmailAndPassword(
              email: person.email, password: password);
          uid = cred.user!.uid;
          await auth.signOut();
          await _db.collection('Users').doc(uid).set({
            'id': uid,
            'name': person.name,
            'email': person.email,
            'courses': courseIds,
            'type': type,
            'demo': true,
            'createdAt': FieldValue.serverTimestamp(),
          });
          result.accountsCreated++;
          result.newAccounts.add({
            'type': type == Session.studentType ? 'Student' : 'Lecturer',
            'name': person.name,
            'email': person.email,
            'password': password,
            'courses': person.courses.join(' '),
          });
        } on FirebaseAuthException catch (e) {
          if (e.code == 'too-many-requests') {
            // Firebase limits how many accounts one device can create per hour.
            result.stoppedByLimit = true;
          } else if (e.code != 'email-already-in-use') {
            rethrow;
          }
          uid = null;
        }
      } else if (uid != null) {
        await _db
            .collection('Users')
            .doc(uid)
            .update({'courses': FieldValue.arrayUnion(courseIds)});
        result.accountsExisting++;
      }

      if (uid != null && type == Session.studentType) {
        for (final id in courseIds) {
          studentsByCourse.putIfAbsent(id, () => []).add(
              {'id': uid, 'name': person.name, 'email': person.email});
        }
      }
    }

    // ---------- 3. Lectures and attendance ----------
    final today = DateTime.now();
    final day = DateTime(today.year, today.month, today.day);
    final fmt = DateFormat('yyyy-MM-dd', 'en_US');
    var c = 0;
    for (final course in DemoData.courses) {
      c++;
      onStep('Creating lectures and attendance… @n/@total',
          {'n': '$c', 'total': '${DemoData.courses.length}'});
      final courseId = idByCode[course.code];
      if (courseId == null) continue;

      // Skip courses that already have demo lectures.
      final lectures =
          _db.collection('Courses').doc(courseId).collection('Lectures');
      final already = await lectures
          .where('demo', isEqualTo: true)
          .limit(1)
          .get();
      if (already.docs.isNotEmpty) continue;

      final timeParts = RegExp(r'(\d+):(\d+)\s*(AM|PM)').firstMatch(course.time);
      var hour = int.parse(timeParts!.group(1)!);
      final minute = int.parse(timeParts.group(2)!);
      if (timeParts.group(3) == 'PM' && hour < 12) hour += 12;

      for (var i = 0; i < _offsets.length; i++) {
        final date = day.add(Duration(days: _offsets[i] + course.day));
        final lectureRef = lectures.doc();
        final batch = _db.batch();
        batch.set(lectureRef, {
          'name': _topics[i],
          'date': fmt.format(date),
          'time': course.time,
          'course': dataByCode[course.code],
          'createdBy': 'demo',
          'demo': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
        result.lecturesCreated++;

        if (date.isBefore(day)) {
          final start = DateTime(date.year, date.month, date.day, hour, minute);
          final enrolled =
              studentsByCourse[courseId] ?? <Map<String, String>>[];
          for (final s in enrolled) {
            if (random.nextDouble() > 0.82) continue; // absent
            batch.set(lectureRef.collection('Attendance').doc(s['id']!), {
              'studentId': s['id'],
              'name': s['name'],
              'email': s['email'],
              'time': Timestamp.fromDate(
                  start.add(Duration(minutes: random.nextInt(12)))),
              'token': 'demo',
              'method': random.nextDouble() < 0.85 ? 'qr' : 'code',
              'distance': 5 + random.nextInt(60),
              'demo': true,
            });
            result.attendanceCreated++;
          }
        }
        await batch.commit();
      }
    }
    return result;
  }

  /// Deletes the demo lectures and their attendance (accounts and courses stay).
  static Future<int> removeDemoLectures(
      void Function(String key, [Map<String, String>? params]) onStep) async {
    final courses = await _db.collection('Courses').get();
    var removed = 0;
    for (final course in courses.docs) {
      onStep('Deleting demo lectures…');
      final qs = await _db
          .collection('Courses')
          .doc(course.id)
          .collection('Lectures')
          .where('demo', isEqualTo: true)
          .get();
      for (final l in qs.docs) {
        await AttendanceService.deleteLecture(course.id, l.id);
        removed++;
      }
    }
    return removed;
  }
}
