import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../models/gps_log_model.dart';
import '../database/repositories/gps_log_repository.dart';

class GpsService {
  final GpsLogRepository _gpsLogRepository;

  StreamSubscription<Position>? _positionStream;
  bool _isTracking = false;

  GpsService(this._gpsLogRepository);

  bool get isTracking => _isTracking;

  Future<void> startTracking(int tripId) async {
    final permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception("Location permission denied");
    }

    // Evita di creare più stream contemporaneamente.
    if (_isTracking) {
      return;
    }

    _isTracking = true;

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) async {
      if (!_isTracking) return;

      final timestamp = DateTime.now();

      final log = GpsLog(
        tripId: tripId,
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: timestamp,
      );

      await _gpsLogRepository.insertGpsLog(log);
    });
  }

  Future<void> stopTracking() async {
    _isTracking = false;

    await _positionStream?.cancel();
    _positionStream = null;
  }
}