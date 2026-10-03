import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../routes/app_pages.dart';

/// Who is signed in, and helpers to sign in / out.
class Session {
  static const String adminEmail = 'tebyan@app.com';
  static const String adminType = 'Admin';
  static const String studentType = 'Student';

  /// Spelling kept from the original project so existing data keeps working.
  static const String lecturerType = 'Lecturere';

  static bool isLecturerType(dynamic type) =>
      type == 'Lecturere' || type == 'Lecturer';

  static String? get userId => GetStorage().read('id');
  static String? get type => GetStorage().read('type');

  static bool get isAdmin => type == adminType;
  static bool get isStudent => type == studentType;
  static bool get isLecturer => isLecturerType(type);

  static bool get isSignedIn =>
      FirebaseAuth.instance.currentUser != null &&
      userId != null &&
      (isAdmin || isStudent || isLecturer);

  static String get homeRoute {
    if (isAdmin) return Routes.ADMIN;
    if (isStudent) return Routes.STUDENTS_MAIN_SCREEN;
    return Routes.LECTURERS_MAIN_SCREEN;
  }

  static Future<void> save({required String id, required String type}) async {
    await GetStorage().write('id', id);
    await GetStorage().write('type', type);
  }

  static Future<void> clear() async {
    await GetStorage().remove('id');
    await GetStorage().remove('type');
  }

  static Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    await clear();
    Get.offAllNamed(Routes.LOGIN);
  }
}
