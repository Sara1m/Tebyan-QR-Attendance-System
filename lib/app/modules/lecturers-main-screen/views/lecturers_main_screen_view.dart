import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

import '../../../src/nav_bar.dart';
import '../../lecturers-home/views/lecturers_home_view.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/lecturers_main_screen_controller.dart';

class LecturersMainScreenView extends GetView<LecturersMainScreenController> {
  const LecturersMainScreenView({super.key});

  static const _pages = [LecturersHomeView(), ProfileView()];

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
