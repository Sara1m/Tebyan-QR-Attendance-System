import 'package:get/get.dart';

import '../controllers/attendance_qr_controller.dart';

class AttendanceQrBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AttendanceQrController>(() => AttendanceQrController());
  }
}
