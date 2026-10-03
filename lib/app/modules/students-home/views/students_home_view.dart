import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../src/session.dart';

import '../../../src/my_courses.dart';
import '../controllers/students_home_controller.dart';

class StudentsHomeView extends StatelessWidget {
  const StudentsHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // One controller per signed-in user, so data never leaks between accounts.
    final tag = Session.userId ?? '';
    final c = Get.isRegistered<StudentsHomeController>(tag: tag)
        ? Get.find<StudentsHomeController>(tag: tag)
        : Get.put(StudentsHomeController(), tag: tag);
    return MyCoursesPage(c: c, isStudent: true);
  }
}
