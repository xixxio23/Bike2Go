import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../database/database_helper.dart';
import '../models/geofence_model.dart';
import 'geofence/native_geofence_service.dart';
import 'geofence/geofence_notification_service.dart';

class GeofenceService {
  static final GeofenceService _instance =
      GeofenceService._internal();

  factory GeofenceService() => _instance;

  GeofenceService._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  late final NativeGeofenceService _nativeGeofenceService;
  late final GeofenceNotificationService _notificationService;

  List<GeofenceRegion> _geofences = [];

  bool _initialized = false;
  bool _isRunning = false;

  final List<GeofenceRegion> _defaultGeofences = [];

  Future<void> initialize() async {
    if (_initialized) return;

    _notificationService =
        GeofenceNotificationService();

    await _notificationService.initialize();

    _nativeGeofenceService =
        NativeGeofenceService(
      onGeofenceEvent: _handleNativeGeofenceEvent,
    );

    await _nativeGeofenceService.initialize();

    _geofences = List.from(_defaultGeofences);

    _initialized = true;

    debugPrint('GeofenceService initialized');
  }

  Future<void> startMonitoring() async {
    await initialize();

    if (_isRunning) {
      return;
    }

    final hasPermission =
        await _checkLocationPermission();

    if (!hasPermission) {
      debugPrint(
        'Geofence monitoring not started: '
        'location permission unavailable',
      );
      return;
    }

    await _nativeGeofenceService.registerGeofences(
      _geofences,
    );

    _isRunning = true;

    debugPrint(
      'Native geofence monitoring started',
    );
  }

  Future<void> stopMonitoring() async {
    await initialize();

    await _nativeGeofenceService
        .removeAllGeofences();

    _isRunning = false;

    debugPrint(
      'Native geofence monitoring stopped',
    );
  }

  Future<bool> _checkLocationPermission() async {
    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    if (permission ==
            LocationPermission.denied ||
        permission ==
            LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<void> _handleNativeGeofenceEvent({
    required GeofenceRegion region,
    required String eventType,
    required double latitude,
    required double longitude,
  }) async {
    final event = GeofenceEvent(
      id: DateTime.now()
          .microsecondsSinceEpoch
          .toString(),
      type: eventType,
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      description:
          eventType == 'enter'
              ? 'Entered ${region.name}'
              : 'Exited ${region.name}',
    );

    await _saveGeofenceEvent(event);

    await _notificationService.showGeofenceEvent(
      geofenceName: region.name,
      eventType: eventType,
    );

    debugPrint(
      'Geofence event: '
      '${region.name} -> $eventType',
    );
  }

  Future<void> _saveGeofenceEvent(
    GeofenceEvent event,
  ) async {
    try {
      final db =
          await _databaseHelper.database;

      await db.insert(
        'geofence_events',
        event.toMap(),
      );
    } catch (e) {
      debugPrint(
        'Error saving geofence event: $e',
      );
    }
  }

  Future<List<GeofenceEvent>>
      getGeofenceEvents() async {
    try {
      final db =
          await _databaseHelper.database;

      final maps = await db.query(
        'geofence_events',
        orderBy: 'timestamp DESC',
      );

      return maps
          .map(
            (map) =>
                GeofenceEvent.fromMap(map),
          )
          .toList();
    } catch (e) {
      debugPrint(
        'Error fetching geofence events: $e',
      );

      return [];
    }
  }

  void addCustomGeofence(
    GeofenceRegion geofence,
  ) {
    _geofences.add(geofence);

    if (_isRunning && geofence.isActive) {
      _nativeGeofenceService
          .registerGeofence(geofence);
    }
  }

  Future<void> removeGeofence(
    String geofenceId,
  ) async {
    _geofences.removeWhere(
      (geofence) =>
          geofence.id == geofenceId,
    );

    if (_isRunning) {
      await _nativeGeofenceService
          .removeGeofence(geofenceId);
    }
  }

  List<GeofenceRegion> get geofences =>
      List.unmodifiable(_geofences);

  bool get isRunning => _isRunning;

  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(
      lat1,
      lon1,
      lat2,
      lon2,
    );
  }

  GeofenceRegion? getGeofenceForLocation(
    double latitude,
    double longitude,
  ) {
    for (final geofence in _geofences) {
      final distance =
          calculateDistance(
        latitude,
        longitude,
        geofence.latitude,
        geofence.longitude,
      );

      if (distance <= geofence.radius) {
        return geofence;
      }
    }

    return null;
  }

  Future<Map<String, dynamic>>
      getGeofenceStatistics() async {
    try {
      final events =
          await getGeofenceEvents();

      final enterEvents =
          events.where(
        (event) => event.type == 'enter',
      );

      final exitEvents =
          events.where(
        (event) => event.type == 'exit',
      );

      final uniqueLocations =
          events
              .map(
                (event) => event.description,
              )
              .toSet()
              .length;

      return {
        'totalEvents': events.length,
        'enterEvents': enterEvents.length,
        'exitEvents': exitEvents.length,
        'uniqueLocations': uniqueLocations,
      };
    } catch (e) {
      debugPrint(
        'Error calculating geofence statistics: $e',
      );

      return {
        'totalEvents': 0,
        'enterEvents': 0,
        'exitEvents': 0,
        'uniqueLocations': 0,
      };
    }
  }
}