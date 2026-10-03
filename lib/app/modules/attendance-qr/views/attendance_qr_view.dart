import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../src/colors.dart';
import '../../../src/widgets.dart';
import '../controllers/attendance_qr_controller.dart';

class AttendanceQrView extends GetView<AttendanceQrController> {
  const AttendanceQrView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    if (!c.ready) return const Scaffold(body: LoadingView());
    final size = MediaQuery.of(context).size;
    final qrSize = math.min(360.0, math.min(size.width - 96, size.height * .42));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.heroGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    HeaderButton(
                        icon: Icons.arrow_back, onTap: () => Get.back()),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.lectureName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Text(c.courseName,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(.7),
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Obx(() => Column(
                            children: [
                              Text('Scan to record your attendance'.tr,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 18),
                              _qrCard(qrSize),
                              const SizedBox(height: 22),
                              if (c.session.value != null) _timerRow(),
                              if (c.session.value != null && !c.expired) ...[
                                const SizedBox(height: 14),
                                _securityChips(),
                              ],
                              const SizedBox(height: 18),
                              _presentCard(),
                              const SizedBox(height: 18),
                              _buttons(),
                            ],
                          )),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _qrCard(double qrSize) {
    final c = controller;
    Widget inner;
    if (c.starting.value) {
      inner = SizedBox(
          width: qrSize,
          height: qrSize,
          child: Center(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SpinKitPulse(color: AppColors.color1, size: 60),
              const SizedBox(height: 12),
              Text(c.step.value.tr,
                  style: TextStyle(color: Colors.grey[700])),
            ],
          )));
    } else if (c.error.value.isNotEmpty) {
      inner = SizedBox(
        width: qrSize,
        height: qrSize,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: AppColors.danger, size: 48),
              const SizedBox(height: 10),
              Text(c.error.value, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              TextButton(
                  onPressed: () => c.start(), child: Text('Try again'.tr)),
            ],
          ),
        ),
      );
    } else {
      inner = Stack(
        alignment: Alignment.center,
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: c.expired ? .08 : 1,
            child: QrImageView(
              data: c.payload,
              version: QrVersions.auto,
              size: qrSize,
              backgroundColor: Colors.white,
              eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square, color: AppColors.primaryColor),
              dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.circle,
                  color: AppColors.primaryColor),
            ),
          ),
          if (c.expired)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_off_outlined,
                    size: 56, color: AppColors.danger),
                const SizedBox(height: 8),
                Text('Code expired'.tr,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.danger)),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => c.start(),
                  icon: const Icon(Icons.refresh),
                  label: Text('New code'.tr),
                ),
              ],
            ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.3),
              blurRadius: 40,
              offset: const Offset(0, 16))
        ],
      ),
      child: Column(
        children: [
          inner,
          if (c.code.isNotEmpty && !c.expired) ...[
            const SizedBox(height: 12),
            Text('Or enter this code'.tr,
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 4),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(c.prettyCode,
                  style: TextStyle(
                      fontSize: 30,
                      letterSpacing: 4,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _timerRow() {
    final c = controller;
    final warn = c.remaining.value <= 30;
    final color = c.expired
        ? AppColors.danger
        : (warn ? AppColors.accent : Colors.white);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 86,
          height: 86,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 86,
                height: 86,
                child: CircularProgressIndicator(
                  value: c.progress,
                  strokeWidth: 7,
                  backgroundColor: Colors.white.withOpacity(.15),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      warn ? AppColors.accent : AppColors.color3),
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(c.clock,
                    style: TextStyle(
                        color: color,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.expired ? 'Attendance closed'.tr : 'Time left'.tr,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            Text(
                'Valid for @m min'.trParams({'m': '${c.minutes}'}),
                style: TextStyle(color: Colors.white.withOpacity(.7))),
          ],
        ),
      ],
    );
  }

  Widget _securityChips() {
    final c = controller;
    Widget chip(IconData icon, String text) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.accent),
              const SizedBox(width: 6),
              Flexible(
                child: Text(text,
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
        );
    final geo = c.area.value;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        chip(Icons.autorenew,
            'Code changes in @s s'.trParams({'s': '${c.nextChange.value}'})),
        if (geo != null)
          chip(
              Icons.location_on_outlined,
              'Within @r m of you (±@a m)'.trParams({
                'r': '${geo.radius}',
                'a': '${geo.accuracy.round()}',
              })),
      ],
    );
  }

  Widget _presentCard() {
    final c = controller;
    final names = c.present.take(6).toList();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.how_to_reg, color: AppColors.accent),
              const SizedBox(width: 8),
              Text('Present now'.tr,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              const Spacer(),
              TweenAnimationBuilder<double>(
                key: ValueKey(c.present.length),
                tween: Tween(begin: 1.4, end: 1),
                duration: const Duration(milliseconds: 400),
                builder: (_, v, child) =>
                    Transform.scale(scale: v, child: child),
                child: Text('${c.present.length}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (names.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: names
                  .map((p) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('${p['name'] ?? ''}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buttons() {
    final c = controller;
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryColor),
              onPressed: c.starting.value ? null : () => c.start(),
              icon: const Icon(Icons.refresh),
              label: Text('New code'.tr),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 52,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white),
              onPressed: c.expired || c.session.value == null ? null : c.endNow,
              icon: const Icon(Icons.stop_circle_outlined),
              label: Text('End now'.tr),
            ),
          ),
        ),
      ],
    );
  }
}
