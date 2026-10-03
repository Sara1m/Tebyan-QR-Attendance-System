import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../src/colors.dart';
import '../../../src/session.dart';
import '../../../src/widgets.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // One controller per signed-in user, so data never leaks between accounts.
    final tag = Session.userId ?? '';
    final c = Get.isRegistered<ProfileController>(tag: tag)
        ? Get.find<ProfileController>(tag: tag)
        : Get.put(ProfileController(), tag: tag);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        final name = '${c.user['name'] ?? ''}';
        return ListView(
          padding: EdgeInsets.zero,
          children: [
            GradientHeader(
              title: '',
              bottom: Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.accent.withOpacity(.8), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.white,
                        child: Text(
                          name.isEmpty
                              ? '?'
                              : name.characters.first.toUpperCase(),
                          style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    StatusChip(
                        text: c.typeLabel.tr,
                        color: AppColors.accent,
                        icon: Icons.verified_outlined),
                  ],
                ),
              ),
            ),
            ResponsiveBody(
              child: c.loading.value
                  ? const Padding(
                      padding: EdgeInsets.all(40), child: LoadingView())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SectionTitle('Account'.tr),
                        AppCard(
                          child: Column(children: [
                            _info(Icons.person_outline, 'Name'.tr, name),
                            const Divider(height: 24),
                            _info(Icons.alternate_email, 'Email'.tr,
                                '${c.user['email'] ?? ''}'),
                            const Divider(height: 24),
                            _info(Icons.badge_outlined, 'Account Type'.tr,
                                c.typeLabel.tr),
                          ]),
                        ),
                        if (c.courseCodes.isNotEmpty) ...[
                          SectionTitle('My courses'.tr),
                          AppCard(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: c.courseCodes
                                  .map((code) => StatusChip(
                                      text: code,
                                      color: AppColors.courseColor(code)))
                                  .toList(),
                            ),
                          ),
                        ],
                        SectionTitle('Settings'.tr),
                        AppCard(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(children: [
                            _action(Icons.password, 'Change password'.tr,
                                c.openChangePassword),
                            const Divider(height: 1),
                            _action(
                                Icons.translate,
                                c.isArabic ? 'English' : 'عربي',
                                c.toggleLanguage),
                          ]),
                        ),
                        const SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            height: 54,
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                  backgroundColor:
                                      AppColors.danger.withOpacity(.1),
                                  foregroundColor: AppColors.danger),
                              onPressed: Session.logout,
                              icon: const Icon(Icons.logout),
                              label: Text('Sign Out'.tr),
                            ),
                          ),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _info(IconData icon, String label, String value) {
    return Row(
      children: [
        IconBubble(icon: icon, size: 40),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _action(IconData icon, String text, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: IconBubble(icon: icon, size: 40),
      title: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[500]),
    );
  }
}
