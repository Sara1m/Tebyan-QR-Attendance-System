import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

import '../../../src/nav_bar.dart';
import '../../courses/views/courses_view.dart';
import '../../lecturers/views/lecturers_view.dart';
import '../../students/views/students_view.dart';
import '../controllers/admin_controller.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({super.key});

  static const _pages = [LecturersView(), StudentsView(), CoursesView()];

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
              NavItem(LineIcons.userTie, 'Lecturers'.tr),
              NavItem(Icons.school_outlined, 'Students'.tr),
              NavItem(LineIcons.book, 'Courses'.tr),
            ],
          ),
        ));
  }
}
