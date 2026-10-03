// ignore_for_file: constant_identifier_names
import 'package:get/get.dart';

import '../modules/admin/bindings/admin_binding.dart';
import '../modules/admin/views/admin_view.dart';
import '../modules/attendance-list/bindings/attendance_list_binding.dart';
import '../modules/attendance-list/views/attendance_list_view.dart';
import '../modules/attendance-qr/bindings/attendance_qr_binding.dart';
import '../modules/attendance-qr/views/attendance_qr_view.dart';
import '../modules/courses/bindings/courses_binding.dart';
import '../modules/courses/views/courses_view.dart';
import '../modules/lecturers-home/bindings/lecturers_home_binding.dart';
import '../modules/lecturers-home/views/lecturers_home_view.dart';
import '../modules/lecturers-main-screen/bindings/lecturers_main_screen_binding.dart';
import '../modules/lecturers-main-screen/views/lecturers_main_screen_view.dart';
import '../modules/lecturers/bindings/lecturers_binding.dart';
import '../modules/lecturers/views/lecturers_view.dart';
import '../modules/lectures/bindings/lectures_binding.dart';
import '../modules/lectures/views/lectures_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/scan/bindings/scan_binding.dart';
import '../modules/scan/views/scan_view.dart';
import '../modules/students-home/bindings/students_home_binding.dart';
import '../modules/students-home/views/students_home_view.dart';
import '../modules/students-main-screen/bindings/students_main_screen_binding.dart';
import '../modules/students-main-screen/views/students_main_screen_view.dart';
import '../modules/students/bindings/students_binding.dart';
import '../modules/students/views/students_view.dart';
import '../src/middleware.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final _admin = [AuthMiddleware(allow: ['Admin'])];
  static final _lecturer = [AuthMiddleware(allow: ['Lecturer'])];
  static final _student = [AuthMiddleware(allow: ['Student'])];
  static final _teachOrLearn = [
    AuthMiddleware(allow: ['Lecturer', 'Student'])
  ];

  static final routes = [
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
      middlewares: [GuestMiddleware()],
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      middlewares: _teachOrLearn,
    ),
    GetPage(
      name: _Paths.ADMIN,
      page: () => const AdminView(),
      binding: AdminBinding(),
      middlewares: _admin,
    ),
    GetPage(
      name: _Paths.COURSES,
      page: () => const CoursesView(),
      binding: CoursesBinding(),
      middlewares: _admin,
    ),
    GetPage(
      name: _Paths.STUDENTS,
      page: () => const StudentsView(),
      binding: StudentsBinding(),
      middlewares: _admin,
    ),
    GetPage(
      name: _Paths.LECTURERS,
      page: () => const LecturersView(),
      binding: LecturersBinding(),
      middlewares: _admin,
    ),
    GetPage(
      name: _Paths.STUDENTS_MAIN_SCREEN,
      page: () => const StudentsMainScreenView(),
      binding: StudentsMainScreenBinding(),
      middlewares: _student,
    ),
    GetPage(
      name: _Paths.LECTURERS_MAIN_SCREEN,
      page: () => const LecturersMainScreenView(),
      binding: LecturersMainScreenBinding(),
      middlewares: _lecturer,
    ),
    GetPage(
      name: _Paths.LECTURERS_HOME,
      page: () => const LecturersHomeView(),
      binding: LecturersHomeBinding(),
      middlewares: _lecturer,
    ),
    GetPage(
      name: _Paths.STUDENTS_HOME,
      page: () => const StudentsHomeView(),
      binding: StudentsHomeBinding(),
      middlewares: _student,
    ),
    GetPage(
      name: _Paths.LECTURES,
      page: () => const LecturesView(),
      binding: LecturesBinding(),
      middlewares: _teachOrLearn,
    ),
    GetPage(
      name: _Paths.ATTENDANCE_QR,
      page: () => const AttendanceQrView(),
      binding: AttendanceQrBinding(),
      middlewares: _lecturer,
    ),
    GetPage(
      name: _Paths.ATTENDANCE_LIST,
      page: () => const AttendanceListView(),
      binding: AttendanceListBinding(),
      middlewares: _lecturer,
    ),
    GetPage(
      name: _Paths.SCAN,
      page: () => const ScanView(),
      binding: ScanBinding(),
      middlewares: _student,
    ),
  ];
}
