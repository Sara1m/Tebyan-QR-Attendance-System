import 'package:get/get.dart';

import '../controllers/lecturers_controller.dart';

class LecturersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LecturersController>(() => LecturersController());
  }
}
