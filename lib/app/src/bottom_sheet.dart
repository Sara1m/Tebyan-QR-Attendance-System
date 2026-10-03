import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import 'colors.dart';

/// Sheet that slides up from the bottom with a form and two buttons.
class AppBottomSheet {
  AppBottomSheet({
    required this.child,
    required this.function,
    required this.buttonText,
  });

  final Widget child;
  final Future<void> Function() function;
  final String buttonText;
  final RxBool loading = false.obs;

  Future<void> bottomSheet() => Get.bottomSheet(
        Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: 640, maxHeight: Get.height * .92),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Get.focusScope?.unfocus(),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28)),
                ),
                child: SafeArea(
                  top: false,
                  child: Builder(builder: (ctx) => SingleChildScrollView(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(ctx).viewInsets.bottom),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),
                        Center(
                          child: Container(
                            height: 5,
                            width: 60,
                            decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(.3),
                                borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                          child: child,
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 52,
                                  child: Obx(() => TextButton(
                                        onPressed: () async {
                                          if (loading.value) return;
                                          loading.value = true;
                                          try {
                                            await function();
                                          } finally {
                                            loading.value = false;
                                          }
                                        },
                                        child: loading.value
                                            ? const SpinKitThreeBounce(
                                                color: Colors.white, size: 22)
                                            : Text(buttonText,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16)),
                                      )),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 52,
                                  child: TextButton(
                                    onPressed: () => Get.back(),
                                    style: TextButton.styleFrom(
                                        backgroundColor: AppColors.color4),
                                    child: Text("Cancel".tr,
                                        style: TextStyle(
                                            color: AppColors.primaryColor,
                                            fontSize: 16)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  )),
                ),
              ),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
      );
}
