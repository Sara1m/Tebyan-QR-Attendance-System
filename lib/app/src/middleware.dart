import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_pages.dart';
import 'session.dart';

/// Sends visitors who are not signed in back to the login page, and keeps
/// every role on its own pages (e.g. a student cannot open the admin pages).
class AuthMiddleware extends GetMiddleware {
  AuthMiddleware({this.allow = const []});

  /// Allowed roles: 'Admin', 'Student', 'Lecturer'. Empty = any signed-in user.
  final List<String> allow;

  @override
  RouteSettings? redirect(String? route) {
    if (!Session.isSignedIn) return const RouteSettings(name: Routes.LOGIN);
    if (allow.isEmpty) return null;
    final ok = (allow.contains('Admin') && Session.isAdmin) ||
        (allow.contains('Student') && Session.isStudent) ||
        (allow.contains('Lecturer') && Session.isLecturer);
    return ok ? null : RouteSettings(name: Session.homeRoute);
  }
}

/// Signed-in users who open the login page go straight to their home page.
class GuestMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (Session.isSignedIn) return RouteSettings(name: Session.homeRoute);
    return null;
  }
}
