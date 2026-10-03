import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'alert.dart';

/// A readable message the app can show for a known problem.
class AppException implements Exception {
  final String message;
  final Map<String, String>? params;
  const AppException(this.message, [this.params]);
  @override
  String toString() => message;
}

/// Turns any error into a clear, translated message for the user.
class AppErrors {
  static String message(Object e) {
    if (e is AppException) return e.message;
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-credential':
        case 'INVALID_LOGIN_CREDENTIALS':
        case 'wrong-password':
        case 'user-not-found':
          return 'Email address or password was wrong';
        case 'invalid-email':
          return 'Email address is invalid';
        case 'user-disabled':
          return 'This account has been disabled';
        case 'too-many-requests':
          return 'Too many requests, try again later';
        case 'email-already-in-use':
          return 'Email address already in use';
        case 'weak-password':
          return 'Password must be at least 6 characters long';
        case 'network-request-failed':
          return 'Check your internet connection';
        case 'requires-recent-login':
          return 'Please sign in again and retry';
        case 'missing-email':
          return 'Please enter the email';
        case 'missing-password':
          return 'Please enter the password';
        case 'operation-not-allowed':
          return 'Email sign-in is not enabled in Firebase';
      }
    }
    if (e is FirebaseException) {
      switch (e.code) {
        case 'permission-denied':
          return "You don't have permission to do this";
        case 'unavailable':
        case 'deadline-exceeded':
          return 'Check your internet connection';
        case 'not-found':
          return 'Item not found';
      }
    }
    return 'Something went wrong, please try again';
  }

  /// The message, translated and with its values filled in.
  static String text(Object e) {
    if (e is AppException && e.params != null) {
      return e.message.trParams(e.params!);
    }
    return message(e).tr;
  }

  static void show(Object e) {
    log('Tebyan error: $e');
    Ui.error(text(e));
  }
}
