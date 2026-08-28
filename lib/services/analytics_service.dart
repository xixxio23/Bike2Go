import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';
import '../database/trip_repository.dart';
import '../database/moment_repository.dart';
import '../database/repositories/route_point_repository.dart';
import '../database/repositories/gps_log_repository.dart';
import '../database/repositories/geofence_repository.dart';

import '../services/geofence_service.dart';
import '../services/data_export_service.dart';

import '../models/analytics_data.dart';

class AnalyticsService {
  final DatabaseHelper _databaseHelper;

  final TripRepository _tripRepository;
  final MomentRepository _momentRepository;
  final RoutePointRepository _routePointRepository;

  final DataExportService _dataExportService;
  final GeofenceService _geofenceService;

  AnalyticsService({
    DatabaseHelper? databaseHelper,
    TripRepository? tripRepository,
    MomentRepository? momentRepository,
    RoutePointRepository? routePointRepository,
    GpsLogRepository? gpsLogRepository,
    GeofenceRepository? geofenceRepository,
    DataExportService? dataExportService,
    GeofenceService? geofenceService,
  })  : _databaseHelper = databaseHelper ?? DatabaseHelper(),
        _tripRepository = tripRepository ??
            TripRepository(
              databaseHelper ?? DatabaseHelper(),
            ),
        _momentRepository = momentRepository ??
            MomentRepository(
              databaseHelper ?? DatabaseHelper(),
            ),
        _routePointRepository = routePointRepository ??
            RoutePointRepository(
              databaseHelper ?? DatabaseHelper(),
            ),
        _dataExportService = dataExportService ??
            DataExportService(
              tripRepository: tripRepository ??
                  TripRepository(
                    databaseHelper ?? DatabaseHelper(),
                  ),
              momentRepository: momentRepository ??
                  MomentRepository(
                    databaseHelper ?? DatabaseHelper(),
                  ),
              routePointRepository: routePointRepository ??
                  RoutePointRepository(
                    databaseHelper ?? DatabaseHelper(),
                  ),
              gpsLogRepository: gpsLogRepository ??
                  GpsLogRepository(
                    databaseHelper ?? DatabaseHelper(),
                  ),
              geofenceRepository: geofenceRepository ??
                  GeofenceRepository(
                    databaseHelper ?? DatabaseHelper(),
                  ),
            ),
        _geofenceService =
            geofenceService ?? GeofenceService();

  Future<AnalyticsData> loadAnalyticsData() async {
    final trips = await _tripRepository.getTrips();

    final dbStats =
        await _databaseHelper.getDatabaseStats();

    Map<String, dynamic> exportStats = {};

    Map<String, dynamic> geofenceStats = {};

    try {
      exportStats =
          await _dataExportService.getExportStatistics();
    } catch (e) {
      debugPrint('Export stats error: $e');

      exportStats = {
        'totalExports': 0,
        'lastExportDate': null,
        'exportFormats': <String, int>{},
      };
    }

    try {
      geofenceStats =
          await _geofenceService.getGeofenceStatistics();
    } catch (e) {
      debugPrint('Geofence stats error: $e');

      geofenceStats = {
        'totalEvents': 0,
        'enterEvents': 0,
        'exitEvents': 0,
        'uniqueLocations': 0,
      };
    }

    final Map<String, double> monthlyDistance = {};
    final Map<String, int> monthlyTrips = {};
    final Map<String, int> activityBreakdown = {};
    final Map<String, int> destinationFrequency = {};

    double totalDistance = 0.0;
    int totalDuration = 0;
    int totalMoments = 0;

    for (final trip in trips) {
      final monthKey =
          '${trip.startDate.year}-${trip.startDate.month.toString().padLeft(2, '0')}';

      monthlyTrips[monthKey] =
          (monthlyTrips[monthKey] ?? 0) + 1;

      activityBreakdown[trip.type.name] =
          (activityBreakdown[trip.type.name] ?? 0) + 1;

      destinationFrequency[trip.destination] =
          (destinationFrequency[trip.destination] ?? 0) + 1;

      if (trip.id != null) {
        try {
          final distance =
              await _routePointRepository
                  .getTotalDistanceForTrip(trip.id!);

          totalDistance += distance;

          final tripDistanceKm =
              distance / 1000;

          monthlyDistance[monthKey] =
              (monthlyDistance[monthKey] ?? 0.0) +
                  tripDistanceKm;

          final moments =
              await _momentRepository
                  .getMomentsForTrip(trip.id!);

          totalMoments += moments.length;
        } catch (e) {
          debugPrint(
            'Error calculating metrics for trip ${trip.id}: $e',
          );
        }
      }

      totalDuration +=
          trip.endDate
              .difference(trip.startDate)
              .inMinutes;
    }

    final totalActivities =
        activityBreakdown.values.fold<int>(
      0,
      (sum, value) => sum + value,
    );

    return AnalyticsData(
      trips: trips,
      monthlyTrips: monthlyTrips,
      monthlyDistance: monthlyDistance,
      activityBreakdown: activityBreakdown,
      destinationFrequency: destinationFrequency,
      totalDistance: totalDistance,
      totalDuration: totalDuration,
      totalMoments: totalMoments,
      dbStats: dbStats,
      exportStats: exportStats,
      geofenceStats: geofenceStats,
      activityStats: {
        'totalActivities': totalActivities,
        'activityBreakdown': activityBreakdown,
      },
    );
  }
}