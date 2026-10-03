import 'dart:async';
import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';

import 'errors.dart';

/// The classroom area set by the lecturer when attendance is opened.
class GeoArea {
  GeoArea({
    required this.lat,
    required this.lng,
    required this.radius,
    required this.tolerance,
    required this.accuracy,
  });

  final double lat;
  final double lng;

  /// Allowed distance in metres chosen by the lecturer.
  final int radius;

  /// Extra metres allowed because phone locations are not exact.
  final int tolerance;

  /// How precise the lecturer's own location was (metres).
  final double accuracy;

  double get lngScale => LocationService.lngScale(lat);
}

class LocationService {
  /// Gets the device location, asking for permission if needed.
  static Future<Position> current() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const AppException(
            'Turn on location services on your device, then try again');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw const AppException(
            'Location permission is needed to confirm you are in the classroom. Allow it from the browser settings, then try again.');
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 25),
        ),
      );
    } on AppException {
      rethrow;
    } on PermissionDeniedException {
      throw const AppException(
          'Location permission is needed to confirm you are in the classroom. Allow it from the browser settings, then try again.');
    } on TimeoutException {
      throw const AppException(
          'Could not get your location. Turn on Wi-Fi or move near a window, then try again.');
    } catch (_) {
      throw const AppException(
          'Could not get your location. Turn on Wi-Fi or move near a window, then try again.');
    }
  }

  /// Metres per degree of longitude at this latitude.
  static double lngScale(double lat) => 111320 * math.cos(lat * math.pi / 180);

  /// Distance in metres. Uses the same simple formula as the database rules,
  /// so the app and the database always agree.
  static double distance({
    required double lat,
    required double lng,
    required double centerLat,
    required double centerLng,
    required double scale,
  }) {
    final dy = (lat - centerLat) * 110574;
    final dx = (lng - centerLng) * scale;
    return math.sqrt(dx * dx + dy * dy);
  }
}
