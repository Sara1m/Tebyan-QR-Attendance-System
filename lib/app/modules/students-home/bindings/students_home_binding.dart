import 'package:get/get.dart';

import '../controllers/students_home_controller.dart';

class StudentsHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentsHomeController>(() => StudentsHomeController());
  }
}
