import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import '../../../src/colors.dart';
import '../../../src/images.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Gradient background on the top part of the screen
          Container(
            height: MediaQuery.of(context).size.height * .48,
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(48),
                  bottomRight: Radius.circular(48)),
            ),
          ),
          PositionedDirectional(
            top: -60,
            end: -50,
            child: _circle(220, Colors.white.withOpacity(.05)),
          ),
          PositionedDirectional(
            top: 140,
            start: -70,
            child: _circle(160, AppColors.accent.withOpacity(.12)),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(.12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8)),
                      onPressed: controller.toggleLanguage,
                      icon: const Icon(Icons.translate,
                          size: 18, color: Colors.white),
                      label: Text(controller.isArabic ? 'English' : 'عربي',
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Column(
                          children: [
                            _logo(),
                            const SizedBox(height: 18),
                            Text('Welcome back 👋'.tr,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text('Smart attendance and course platform'.tr,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(.75))),
                            const SizedBox(height: 28),
                            _formCard(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _logo() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      builder: (_, v, child) => Opacity(
        opacity: v.clamp(0, 1).toDouble(),
        child: Transform.scale(scale: .8 + .2 * v, child: child),
      ),
      child: Image.asset(AppImages.logoWhite,
          width: 250, filterQuality: FilterQuality.medium),
    );
  }

  Widget _formCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: AppColors.primaryColor.withOpacity(.12),
              blurRadius: 30,
              offset: const Offset(0, 14))
        ],
      ),
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Sign in to your account'.tr,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor)),
            const SizedBox(height: 18),
            TextField(
              controller: controller.email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: InputDecoration(
                hintText: 'Email'.tr,
                prefixIcon: const Icon(Icons.alternate_email),
              ),
            ),
            const SizedBox(height: 14),
            Obx(() => TextField(
                  controller: controller.password,
                  obscureText: controller.obscureText.value,
                  textInputAction: TextInputAction.go,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                    hintText: 'Password'.tr,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                        onPressed: () => controller.obscureText.value =
                            !controller.obscureText.value,
                        icon: Icon(controller.obscureText.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined)),
                  ),
                  onSubmitted: (_) => controller.loginUser(),
                )),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: AppColors.color1),
                onPressed: controller.forgotPassword,
                child: Text('Forgot your password?'.tr),
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => _GradientButton(
                  onTap: controller.loading.value
                      ? null
                      : () => controller.loginUser(),
                  child: controller.loading.value
                      ? const SpinKitThreeBounce(color: Colors.white, size: 20)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('LOGIN'.tr,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward,
                                color: Colors.white, size: 20),
                          ],
                        ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: AppColors.primaryColor.withOpacity(.3),
              blurRadius: 16,
              offset: const Offset(0, 8))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Center(child: child),
        ),
      ),
    );
  }
}
