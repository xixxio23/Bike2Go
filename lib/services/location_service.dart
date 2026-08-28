import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  static const double _earthRadiusKm = 6371.0;
  static const double _earthRadiusMeters = 6371000.0;

  /// Calculate distance between two points using Haversine formula
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2, {
    bool inKilometers = false,
  }) {
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    final double lat1Rad = _toRadians(lat1);
    final double lat2Rad = _toRadians(lat2);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);

    final double c = 2 * asin(sqrt(a));

    return inKilometers ? _earthRadiusKm * c : _earthRadiusMeters * c;
  }

  /// Calculate total distance from a list of coordinates
  static double calculateTotalDistance(
    List<Map<String, double>> coordinates, {
    bool inKilometers = false,
  }) {
    if (coordinates.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 0; i < coordinates.length - 1; i++) {
      final current = coordinates[i];
      final next = coordinates[i + 1];

      totalDistance += calculateDistance(
        current['latitude']!,
        current['longitude']!,
        next['latitude']!,
        next['longitude']!,
        inKilometers: inKilometers,
      );
    }
    return totalDistance;
  }

  /// Check if current location is within a certain radius of target
  static bool isWithinRadius(
    double currentLat,
    double currentLon,
    double targetLat,
    double targetLon,
    double radiusMeters,
  ) {
    final distance = calculateDistance(
      currentLat,
      currentLon,
      targetLat,
      targetLon,
    );
    return distance <= radiusMeters;
  }

  /// Get current location with error handling
  static Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  /// Calculate speed between two points with timestamps
  static double calculateSpeed(
    double lat1,
    double lon1,
    DateTime time1,
    double lat2,
    double lon2,
    DateTime time2, {
    bool inKmh = true,
  }) {
    final distance = calculateDistance(lat1, lon1, lat2, lon2);
    final timeDifference = time2.difference(time1).inSeconds;

    if (timeDifference <= 0) return 0.0;

    final speedMps = distance / timeDifference; // meters per second

    return inKmh ? speedMps * 3.6 : speedMps; // Convert to km/h or keep as m/s
  }

  /// Format distance for display
  static String formatDistance(double distanceMeters) {
    if (distanceMeters < 1000) {
      return '${distanceMeters.toStringAsFixed(0)} m';
    } else {
      return '${(distanceMeters / 1000).toStringAsFixed(2)} km';
    }
  }

  /// Format duration for display
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  static double _toRadians(double degrees) {
    return degrees * (pi / 180);
  }
}
