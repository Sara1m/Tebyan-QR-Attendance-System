import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../src/alert.dart';
import '../../../src/bottom_sheet.dart';
import '../../../src/errors.dart';
import '../../../src/session.dart';
import '../../../src/widgets.dart';

class ProfileController extends GetxController {
  final RxMap<String, dynamic> user = <String, dynamic>{}.obs;
  final RxList<String> courseCodes = <String>[].obs;
  final RxBool loading = true.obs;

  final TextEditingController current = TextEditingController();
  final TextEditingController newPassword = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  final RxBool obscure = true.obs;

  bool get isArabic => Get.locale?.languageCode == 'ar';

  String get typeLabel {
    if (Session.isStudent) return 'Student';
    if (Session.isLecturer) return 'Lecturer';
    return 'Admin';
  }

  @override
  void onInit() {
    super.onInit();
    getProfile();
  }

  Future<void> getProfile() async {
    final uid = Session.userId;
    if (uid == null) return;
    try {
      final db = FirebaseFirestore.instance;
      final ds = await db.collection('Users').doc(uid).get();
      user.value = ds.data() ?? <String, dynamic>{};
      final ids = List<String>.from(user['courses'] ?? []);
      final codes = <String>[];
      for (var i = 0; i < ids.length; i += 30) {
        final chunk = ids.sublist(i, i + 30 > ids.length ? ids.length : i + 30);
        final qs = await db
            .collection('Courses')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        codes.addAll(qs.docs.map((d) => '${d.data()['code']}'));
      }
      codes.sort();
      courseCodes.value = codes;
    } catch (e) {
      AppErrors.show(e);
    } finally {
      loading.value = false;
    }
  }

  void toggleLanguage() {
    final next = isArabic ? 'en' : 'ar';
    GetStorage().write('lang', next);
    Get.updateLocale(Locale(next));
  }

  void openChangePassword() {
    current.clear();
    newPassword.clear();
    confirmPassword.clear();
    obscure.value = true;
    AppBottomSheet(
      buttonText: 'Save'.tr,
      function: _changePassword,
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),
              Row(children: [
                const IconBubble(icon: Icons.password),
                const SizedBox(width: 12),
                Text('Change password'.tr,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  onPressed: () => obscure.value = !obscure.value,
                  icon: Icon(obscure.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                ),
              ]),
              FieldLabel('Current password'.tr),
              TextField(
                controller: current,
                obscureText: obscure.value,
                decoration:
                    const InputDecoration(prefixIcon: Icon(Icons.lock_outline)),
              ),
              FieldLabel('New password'.tr),
              TextField(
                controller: newPassword,
                obscureText: obscure.value,
                decoration: InputDecoration(
                    hintText: 'At least 6 characters'.tr,
                    prefixIcon: const Icon(Icons.lock_reset)),
              ),
              FieldLabel('Confirm new password'.tr),
              TextField(
                controller: confirmPassword,
                obscureText: obscure.value,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.check_circle_outline)),
              ),
            ],
          )),
    ).bottomSheet();
  }

  Future<void> _changePassword() async {
    if (current.text.isEmpty) {
      Ui.info('Please enter your current password');
      return;
    }
    if (newPassword.text.length < 6) {
      Ui.info('Password must be at least 6 characters long');
      return;
    }
    if (newPassword.text != confirmPassword.text) {
      Ui.info('The two passwords do not match');
      return;
    }
    final u = FirebaseAuth.instance.currentUser;
    if (u == null || u.email == null) {
      Ui.error('Please sign in again and retry');
      return;
    }
    try {
      final cred =
          EmailAuthProvider.credential(email: u.email!, password: current.text);
      await u.reauthenticateWithCredential(cred);
      await u.updatePassword(newPassword.text);
      Get.back();
      Ui.success('Your password has been changed');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        Ui.error('The current password is wrong');
      } else {
        AppErrors.show(e);
      }
    } catch (e) {
      AppErrors.show(e);
    }
  }
}
