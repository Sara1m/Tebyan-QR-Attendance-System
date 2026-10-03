import 'package:get/get.dart';

import '../controllers/lecturers_home_controller.dart';

class LecturersHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LecturersHomeController>(() => LecturersHomeController());
  }
}
