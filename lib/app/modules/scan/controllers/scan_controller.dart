import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../src/attendance_service.dart';
import '../../../src/bottom_sheet.dart';
import '../../../src/dialogs.dart';
import '../../../src/errors.dart';

class ScanController extends GetxController {
  /// When opened from a specific lecture, the scanned code must belong to it.
  String? expectedCourseId;
  String? expectedLectureId;
  String lectureName = '';

  final MobileScannerController camera = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  final RxBool processing = false.obs;
  final RxString status = ''.obs;
  final TextEditingController manualCode = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    final a = Get.arguments;
    if (a is Map) {
      expectedCourseId = a['courseId'] as String?;
      expectedLectureId = a['lectureId'] as String?;
      lectureName = '${a['lectureName'] ?? ''}';
    }
  }

  Future<void> onDetect(BarcodeCapture capture) async {
    if (processing.value) return;
    String? raw;
    for (final b in capture.barcodes) {
      if (b.rawValue != null && b.rawValue!.isNotEmpty) {
        raw = b.rawValue;
        break;
      }
    }
    if (raw == null) return;

    processing.value = true;
    status.value = 'Checking the code…';
    try {
      final data = AttendanceService.parse(raw);
      if (data == null) {
        throw const AppException('This is not a Tebyan attendance code');
      }
      if (expectedLectureId != null &&
          (data.lectureId != expectedLectureId ||
              data.courseId != expectedCourseId)) {
        throw const AppException('This code belongs to another lecture');
      }
      await camera.stop();
      final name = await AttendanceService.submit(
        courseId: data.courseId,
        lectureId: data.lectureId,
        code: data.code,
        expiresAt: data.expiresAt,
        issuedAt: data.issuedAt,
        onStep: (step) => status.value = step,
      );
      await AppDialogs.result(
        success: true,
        title: 'Attendance recorded',
        message: 'Your attendance for @lecture has been recorded.'
            .trParams({'lecture': name}),
      );
      Get.back(result: true);
    } catch (e) {
      await AppDialogs.result(
        success: false,
        title: 'Could not record attendance',
        message: AppErrors.text(e),
        buttonText: 'Try again',
      );
      status.value = '';
      processing.value = false;
      try {
        await camera.start();
      } catch (_) {}
    }
  }

  /// For devices without a camera: type the 8-character code instead.
  void enterCodeManually() {
    if (expectedCourseId == null || expectedLectureId == null) {
      AppDialogs.result(
        success: false,
        title: 'Choose the lecture first',
        message:
            'To type the code, open the course, then choose the lecture and tap "Enter code".'
                .tr,
      );
      return;
    }
    manualCode.clear();
    AppBottomSheet(
      buttonText: 'Confirm attendance'.tr,
      function: () async {
        try {
          final name = await AttendanceService.submit(
            courseId: expectedCourseId!,
            lectureId: expectedLectureId!,
            code: manualCode.text,
            method: 'code',
          );
          Get.back();
          await AppDialogs.result(
            success: true,
            title: 'Attendance recorded',
            message: 'Your attendance for @lecture has been recorded.'
                .trParams({'lecture': name}),
          );
          Get.back(result: true);
        } catch (e) {
          AppErrors.show(e);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),
          Text('Enter attendance code'.tr,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: manualCode,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            maxLength: 9,
            style: const TextStyle(
                fontSize: 24, letterSpacing: 6, fontWeight: FontWeight.bold),
            decoration:
                const InputDecoration(hintText: 'XXXX-XXXX', counterText: ''),
          ),
          const SizedBox(height: 4),
        ],
      ),
    ).bottomSheet();
  }

  @override
  void onClose() {
    camera.dispose();
    manualCode.dispose();
    super.onClose();
  }
}
