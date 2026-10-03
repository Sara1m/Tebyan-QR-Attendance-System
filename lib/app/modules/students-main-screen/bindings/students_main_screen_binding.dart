import 'package:get/get.dart';

import '../controllers/students_main_screen_controller.dart';

class StudentsMainScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentsMainScreenController>(() => StudentsMainScreenController());
  }
}
