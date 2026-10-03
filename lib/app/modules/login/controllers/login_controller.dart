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

class LoginController extends GetxController {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController forgotPasswordEmail = TextEditingController();
  final RxBool obscureText = true.obs;
  final RxBool loading = false.obs;

  bool get isArabic => Get.locale?.languageCode == 'ar';

  void toggleLanguage() {
    final next = isArabic ? 'en' : 'ar';
    GetStorage().write('lang', next);
    Get.updateLocale(Locale(next));
  }

  Future<void> loginUser() async {
    final mail = email.text.trim();
    if (mail.isEmpty) {
      Ui.info('Please enter the email');
      return;
    }
    if (!GetUtils.isEmail(mail)) {
      Ui.info('Email address is invalid');
      return;
    }
    if (password.text.isEmpty) {
      Ui.info('Please enter the password');
      return;
    }
    if (loading.value) return;
    loading.value = true;
    try {
      final cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: mail, password: password.text);
      final user = cred.user!;
      String type;
      if ((user.email ?? '').toLowerCase() == Session.adminEmail) {
        type = Session.adminType;
      } else {
        final ds = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();
        final t = ds.data()?['type'];
        if (!ds.exists || t == null) {
          await FirebaseAuth.instance.signOut();
          throw const AppException(
              'This account no longer exists. Contact the administrator.');
        }
        if (t == Session.adminType) {
          type = Session.adminType;
        } else if (t == Session.studentType) {
          type = Session.studentType;
        } else if (Session.isLecturerType(t)) {
          type = Session.lecturerType;
        } else {
          await FirebaseAuth.instance.signOut();
          throw const AppException('Unknown account type');
        }
      }
      await Session.save(id: user.uid, type: type);
      password.clear();
      Get.offAllNamed(Session.homeRoute);
    } catch (e) {
      AppErrors.show(e);
    } finally {
      loading.value = false;
    }
  }

  Future<void> _sendReset() async {
    final mail = forgotPasswordEmail.text.trim();
    if (!GetUtils.isEmail(mail)) {
      Ui.info('Email address is invalid');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: mail);
      Get.back();
      forgotPasswordEmail.clear();
      Ui.success('If this email is registered, a reset link has been sent to it. Check your inbox and spam folder.');
    } catch (e) {
      AppErrors.show(e);
    }
  }

  void forgotPassword() {
    forgotPasswordEmail.text = email.text.trim();
    AppBottomSheet(
      buttonText: 'Send link'.tr,
      function: _sendReset,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),
          const IconBubble(icon: Icons.lock_reset, size: 56),
          const SizedBox(height: 14),
          Text('Forgot your password?'.tr,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
              'Enter your email and we will send you a link to choose a new password.'
                  .tr,
              style: TextStyle(color: Colors.grey[700], height: 1.5)),
          const SizedBox(height: 16),
          TextField(
            controller: forgotPasswordEmail,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                prefixIcon: const Icon(Icons.alternate_email),
                hintText: 'Enter your email'.tr),
          ),
        ],
      ),
    ).bottomSheet();
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    forgotPasswordEmail.dispose();
    super.onClose();
  }
}
