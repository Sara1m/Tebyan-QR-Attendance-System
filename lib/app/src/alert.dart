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

  /// Key of the app's ScaffoldMessenger, used when GetX cannot show a snackbar.
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void success(String message) => _show(SuccessSnackBar(
      message: message), message, AppColors.success, Icons.check_circle_outline);

  static void error(String message) => _show(ErrorSnackBar(message: message),
      message, AppColors.danger, Icons.error_outline);

  static void info(String message) => _show(DefaultSnackBar(message: message),
      message, AppColors.primaryColor, Icons.info_outline);

  /// Shows the GetX snackbar when the app's overlay is ready. Otherwise it
  /// falls back to Flutter's own snackbar, so an error message can never
  /// crash the app and leave the screen stuck.
  static void _show(
      GetSnackBar bar, String message, Color color, IconData icon) {
    if (Get.overlayContext != null) {
      try {
        Get.closeAllSnackbars();
        Get.showSnackbar(bar);
        return;
      } catch (_) {
        // Fall through to the Flutter snackbar below.
      }
    }
    final messenger = messengerKey.currentState;
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Row(
          children: [
            Icon(icon, size: 24, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message.tr,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 14, height: 1.4)),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 4),
      ));
  }
}
