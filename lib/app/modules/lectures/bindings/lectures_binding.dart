import 'package:get/get.dart';

import '../controllers/lectures_controller.dart';

class LecturesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LecturesController>(() => LecturesController());
  }
}
