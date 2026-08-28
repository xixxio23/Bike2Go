import 'package:flutter/foundation.dart';
import 'package:native_geofence/native_geofence.dart' as native;

import '../../models/geofence_model.dart';

typedef NativeGeofenceEventCallback = Future<void> Function({
  required GeofenceRegion region,
  required String eventType,
  required double latitude,
  required double longitude,
});

class NativeGeofenceService {
  NativeGeofenceService({
    this.onGeofenceEvent,
  });

  final NativeGeofenceEventCallback? onGeofenceEvent;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await native.NativeGeofenceManager.instance.initialize();

    _initialized = true;

    debugPrint('NativeGeofenceService initialized');
  }

  Future<void> registerGeofence(
    GeofenceRegion region,
  ) async {
    await initialize();

    if (!region.isActive) {
      return;
    }

    final geofence = native.Geofence(
      id: region.id,
      location: native.Location(
        latitude: region.latitude,
        longitude: region.longitude,
      ),
      radiusMeters: region.radius,
      triggers: {
        native.GeofenceEvent.enter,
        native.GeofenceEvent.exit,
      },
      iosSettings: const native.IosGeofenceSettings(
        initialTrigger: true,
      ),
      androidSettings: const native.AndroidGeofenceSettings(
        initialTriggers: {
          native.GeofenceEvent.enter,
        },
        notificationResponsiveness: Duration(minutes: 1),
      ),
    );

    await native.NativeGeofenceManager.instance.createGeofence(
      geofence,
      _handleNativeGeofenceEvent,
    );

    debugPrint(
      'Native geofence registered: ${region.id}',
    );
  }

  Future<void> registerGeofences(
    List<GeofenceRegion> regions,
  ) async {
    await initialize();

    for (final region in regions) {
      if (!region.isActive) {
        continue;
      }

      await registerGeofence(region);
    }
  }

  Future<void> removeGeofence(
    String geofenceId,
  ) async {
    await initialize();

    await native.NativeGeofenceManager.instance
        .removeGeofenceById(geofenceId);

    debugPrint(
      'Native geofence removed: $geofenceId',
    );
  }

  Future<void> removeAllGeofences() async {
    await initialize();

    await native.NativeGeofenceManager.instance
        .removeAllGeofences();

    debugPrint(
      'All native geofences removed',
    );
  }

  Future<List<native.ActiveGeofence>> getRegisteredGeofences() async {
    await initialize();

    return native.NativeGeofenceManager.instance
        .getRegisteredGeofences();
  }

  Future<void> _handleNativeGeofenceEvent(
    native.GeofenceCallbackParams params,
  ) async {
    final location = params.location;

    if (location == null) {
      debugPrint(
        'Native geofence event without location',
      );
      return;
    }

    final eventType = _eventTypeToString(params.event);

    for (final activeGeofence in params.geofences) {
      final region = GeofenceRegion(
        id: activeGeofence.id,
        name: activeGeofence.id,
        latitude: activeGeofence.location.latitude,
        longitude: activeGeofence.location.longitude,
        radius: activeGeofence.radiusMeters,
      );

      debugPrint(
        'Native geofence event: '
        '${region.id} -> $eventType '
        '(${location.latitude}, ${location.longitude})',
      );

      final callback = onGeofenceEvent;

      if (callback != null) {
        await callback(
          region: region,
          eventType: eventType,
          latitude: location.latitude,
          longitude: location.longitude,
        );
      }
    }
  }

  String _eventTypeToString(
    native.GeofenceEvent event,
  ) {
    switch (event) {
      case native.GeofenceEvent.enter:
        return 'enter';

      case native.GeofenceEvent.exit:
        return 'exit';

      case native.GeofenceEvent.dwell:
        return 'dwell';
    }
  }
}