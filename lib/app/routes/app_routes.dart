part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const LOGIN = _Paths.LOGIN;
  static const PROFILE = _Paths.PROFILE;
  static const ADMIN = _Paths.ADMIN;
  static const COURSES = _Paths.COURSES;
  static const STUDENTS = _Paths.STUDENTS;
  static const LECTURERS = _Paths.LECTURERS;
  static const STUDENTS_MAIN_SCREEN = _Paths.STUDENTS_MAIN_SCREEN;
  static const LECTURERS_MAIN_SCREEN = _Paths.LECTURERS_MAIN_SCREEN;
  static const LECTURERS_HOME = _Paths.LECTURERS_HOME;
  static const STUDENTS_HOME = _Paths.STUDENTS_HOME;
  static const LECTURES = _Paths.LECTURES;
  static const ATTENDANCE_QR = _Paths.ATTENDANCE_QR;
  static const ATTENDANCE_LIST = _Paths.ATTENDANCE_LIST;
  static const SCAN = _Paths.SCAN;
}

abstract class _Paths {
  _Paths._();
  static const LOGIN = '/login';
  static const PROFILE = '/profile';
  static const ADMIN = '/admin';
  static const COURSES = '/courses';
  static const STUDENTS = '/students';
  static const LECTURERS = '/lecturers';
  static const STUDENTS_MAIN_SCREEN = '/students-main-screen';
  static const LECTURERS_MAIN_SCREEN = '/lecturers-main-screen';
  static const LECTURERS_HOME = '/lecturers-home';
  static const STUDENTS_HOME = '/students-home';
  static const LECTURES = '/lectures';
  static const ATTENDANCE_QR = '/attendance-qr';
  static const ATTENDANCE_LIST = '/attendance-list';
  static const SCAN = '/scan';
}
