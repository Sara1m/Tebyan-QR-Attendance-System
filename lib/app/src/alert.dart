// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'colors.dart';

/// Small coloured messages shown at the top of the screen.
class Ui {
  static GetSnackBar _bar({
    required String message,
    required Color color,
    required IconData icon,
    Color textColor = Colors.white,
  }) {
    return GetSnackBar(
      messageText: Text(message.tr,
          style: TextStyle(color: textColor, fontSize: 14, height: 1.4)),
      snackPosition: SnackPosition.TOP,
      maxWidth: 560,
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
      backgroundColor: color,
      icon: Icon(icon, size: 28, color: textColor),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      borderRadius: 16,
      boxShadows: [
        BoxShadow(
            color: Colors.black.withOpacity(.15),
            blurRadius: 18,
            offset: const Offset(0, 6))
      ],
      dismissDirection: DismissDirection.horizontal,
      duration: const Duration(seconds: 4),
    );
  }

  static GetSnackBar SuccessSnackBar({required String message}) => _bar(
      message: message,
      color: AppColors.success,
      icon: Icons.check_circle_outline);

  static GetSnackBar ErrorSnackBar({required String message}) => _bar(
      message: message,
      color: AppColors.danger,
      icon: Icons.error_outline);

  static GetSnackBar DefaultSnackBar({required String message}) => _bar(
      message: message,
      color: AppColors.primaryColor,
      icon: Icons.info_outline);

  static void success(String message) {
    Get.closeAllSnackbars();
    Get.showSnackbar(SuccessSnackBar(message: message));
  }

  static void error(String message) {
    Get.closeAllSnackbars();
    Get.showSnackbar(ErrorSnackBar(message: message));
  }

  static void info(String message) {
    Get.closeAllSnackbars();
    Get.showSnackbar(DefaultSnackBar(message: message));
  }
}
