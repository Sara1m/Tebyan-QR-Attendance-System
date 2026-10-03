import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import 'colors.dart';
import 'errors.dart';

class AppDialogs {
  /// Asks "are you sure?" and runs [onConfirm] when the user agrees.
  static Future<void> confirm({
    required String title,
    required String message,
    required Future<void> Function() onConfirm,
    String confirmText = 'Delete',
    IconData icon = Icons.delete_outline,
    bool destructive = true,
  }) {
    final loading = false.obs;
    final color = destructive ? AppColors.danger : AppColors.color1;
    return Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                      color: color.withOpacity(.1), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 34),
                ),
                const SizedBox(height: 16),
                Text(title.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 19, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700], height: 1.5)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: AppColors.color4),
                          onPressed: () => Get.back(),
                          child: Text('Cancel'.tr,
                              style: TextStyle(color: AppColors.primaryColor)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: Obx(() => TextButton(
                              style:
                                  TextButton.styleFrom(backgroundColor: color),
                              onPressed: () async {
                                if (loading.value) return;
                                loading.value = true;
                                try {
                                  await onConfirm();
                                  if (Get.isDialogOpen ?? false) Get.back();
                                } catch (e) {
                                  AppErrors.show(e);
                                } finally {
                                  loading.value = false;
                                }
                              },
                              child: loading.value
                                  ? const SpinKitThreeBounce(
                                      color: Colors.white, size: 18)
                                  : Text(confirmText.tr),
                            )),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Big friendly result message (e.g. attendance recorded).
  static Future<void> result({
    required bool success,
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    final color = success ? AppColors.success : AppColors.danger;
    return Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: .4, end: 1),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (_, v, child) =>
                      Transform.scale(scale: v, child: child),
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                        color: color.withOpacity(.12), shape: BoxShape.circle),
                    child: Icon(
                        success ? Icons.check_rounded : Icons.close_rounded,
                        color: color,
                        size: 54),
                  ),
                ),
                const SizedBox(height: 18),
                Text(title.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700], height: 1.6)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: Text(buttonText.tr),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
