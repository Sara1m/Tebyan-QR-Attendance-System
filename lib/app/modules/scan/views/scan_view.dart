import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../src/colors.dart';
import '../../../src/widgets.dart';
import '../controllers/scan_controller.dart';

class ScanView extends GetView<ScanController> {
  const ScanView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              controller: c.camera,
              onDetect: c.onDetect,
              errorBuilder: (context, error) => _cameraError(error),
            ),
          ),
          // Darkened frame with a clear square in the middle
          const Positioned.fill(child: _ScannerOverlay()),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      HeaderButton(
                          icon: Icons.arrow_back, onTap: () => Get.back()),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Scan attendance'.tr,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            if (c.lectureName.isNotEmpty)
                              Text(c.lectureName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(.75),
                                      fontSize: 13)),
                          ],
                        ),
                      ),
                      HeaderButton(
                          icon: Icons.flash_on,
                          tooltip: 'Flash'.tr,
                          onTap: () => c.camera.toggleTorch()),
                      HeaderButton(
                          icon: Icons.cameraswitch_outlined,
                          tooltip: 'Switch camera'.tr,
                          onTap: () => c.camera.switchCamera()),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 520),
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Obx(() => c.processing.value
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SpinKitThreeBounce(
                                color: AppColors.color1, size: 20),
                            const SizedBox(width: 12),
                            Text(c.status.value.tr),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(children: [
                              const IconBubble(icon: Icons.qr_code_2),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                    'Point the camera at the QR code on the lecturer\'s screen'
                                        .tr,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        height: 1.4)),
                              ),
                            ]),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: TextButton.icon(
                                style: TextButton.styleFrom(
                                    backgroundColor: AppColors.color4,
                                    foregroundColor: AppColors.primaryColor),
                                onPressed: c.enterCodeManually,
                                icon: const Icon(Icons.keyboard_alt_outlined),
                                label: Text('Enter code instead'.tr),
                              ),
                            ),
                          ],
                        )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cameraError(MobileScannerException error) {
    String title = 'Camera is not available';
    String hint =
        'Make sure no other app is using the camera, then try again.';
    if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
      title = 'Camera permission denied';
      hint =
          'Allow camera access for this site from the browser settings (the lock icon next to the address), then reload the page.';
    } else if (error.errorCode == MobileScannerErrorCode.unsupported) {
      title = 'This browser does not support the camera';
      hint =
          'Open the site in Chrome or Safari, and make sure the address starts with https://';
    }
    return Container(
      color: AppColors.primaryColor,
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.no_photography_outlined,
              color: Colors.white, size: 64),
          const SizedBox(height: 16),
          Text(title.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(hint.tr,
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.white.withOpacity(.8), height: 1.5)),
        ],
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(builder: (context, box) {
        final side = (box.maxWidth < box.maxHeight ? box.maxWidth : box.maxHeight) * .62;
        return Stack(
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(.55), BlendMode.srcOut),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                        color: Colors.black,
                        backgroundBlendMode: BlendMode.dstOut),
                  ),
                  Center(
                    child: Container(
                      width: side,
                      height: side,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Container(
                width: side,
                height: side,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.accent, width: 3),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
