import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../src/session.dart';

import '../../../src/my_courses.dart';
import '../controllers/lecturers_home_controller.dart';

class LecturersHomeView extends StatelessWidget {
  const LecturersHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // One controller per signed-in user, so data never leaks between accounts.
    final tag = Session.userId ?? '';
    final c = Get.isRegistered<LecturersHomeController>(tag: tag)
        ? Get.find<LecturersHomeController>(tag: tag)
        : Get.put(LecturersHomeController(), tag: tag);
    return MyCoursesPage(c: c, isStudent: false);
  }
}
