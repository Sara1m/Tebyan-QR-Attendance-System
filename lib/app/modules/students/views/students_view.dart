import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../src/user_admin.dart';
import '../controllers/students_controller.dart';

class StudentsView extends StatelessWidget {
  const StudentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.isRegistered<StudentsController>()
        ? Get.find<StudentsController>()
        : Get.put(StudentsController());
    return UsersAdminPage(c: c);
  }
}
