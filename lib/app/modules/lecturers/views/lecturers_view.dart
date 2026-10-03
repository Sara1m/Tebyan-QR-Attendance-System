import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../src/user_admin.dart';
import '../controllers/lecturers_controller.dart';

class LecturersView extends StatelessWidget {
  const LecturersView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.isRegistered<LecturersController>()
        ? Get.find<LecturersController>()
        : Get.put(LecturersController());
    return UsersAdminPage(c: c);
  }
}
