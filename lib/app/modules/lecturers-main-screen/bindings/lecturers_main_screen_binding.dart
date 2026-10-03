import 'package:get/get.dart';

import '../controllers/lecturers_main_screen_controller.dart';

class LecturersMainScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LecturersMainScreenController>(() => LecturersMainScreenController());
  }
}
