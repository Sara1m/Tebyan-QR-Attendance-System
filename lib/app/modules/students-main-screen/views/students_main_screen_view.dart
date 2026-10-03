import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

import '../../../src/nav_bar.dart';
import '../../students-home/views/students_home_view.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/students_main_screen_controller.dart';

class StudentsMainScreenView extends GetView<StudentsMainScreenController> {
  const StudentsMainScreenView({super.key});

  static const _pages = [StudentsHomeView(), ProfileView()];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: KeyedSubtree(
              key: ValueKey(controller.index.value),
              child: _pages[controller.index.value],
            ),
          ),
          bottomNavigationBar: AppNavBar(
            selectedIndex: controller.index.value,
            onTabChange: (i) => controller.index.value = i,
            items: [
              NavItem(LineIcons.home, 'Home'.tr),
              NavItem(LineIcons.alternateUser, 'Profile'.tr),
            ],
          ),
        ));
  }
}
