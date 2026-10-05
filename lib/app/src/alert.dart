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

  static void success(String message) =>
      _show(message, AppColors.success, Icons.check_circle_outline);

  static void error(String message) =>
      _show(message, AppColors.danger, Icons.error_outline);

  static void info(String message) =>
      _show(message, AppColors.primaryColor, Icons.info_outline);

  static OverlayEntry? _current;

  /// Shows a message at the top of the screen, above every page and sheet.
  /// It draws straight on the navigator's overlay, so it does not depend on
  /// the GetX snackbar (which could crash and leave the screen stuck).
  static void _show(String message, Color color, IconData icon) {
    final overlay = Get.key.currentState?.overlay;
    if (overlay == null) {
      _showWithMessenger(message, color, icon);
      return;
    }
    _hideCurrent();
    late final OverlayEntry entry;
    void remove() {
      if (entry.mounted) entry.remove();
      if (identical(_current, entry)) _current = null;
    }

    entry = OverlayEntry(
      builder: (context) => _Toast(
        message: message.tr,
        color: color,
        icon: icon,
        onTap: remove,
      ),
    );
    _current = entry;
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 4), remove);
  }

  static void _hideCurrent() {
    final entry = _current;
    _current = null;
    if (entry != null && entry.mounted) entry.remove();
  }

  /// Last resort if the overlay is not ready yet.
  static void _showWithMessenger(String message, Color color, IconData icon) {
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

/// The coloured message card shown by [Ui].
class _Toast extends StatelessWidget {
  const _Toast({
    required this.message,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String message;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 250),
              builder: (context, t, child) => Opacity(
                opacity: t,
                child: Transform.translate(
                    offset: Offset(0, -20 * (1 - t)), child: child),
              ),
              child: Material(
                color: color,
                elevation: 6,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 28, color: Colors.white),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(message,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1.4)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
