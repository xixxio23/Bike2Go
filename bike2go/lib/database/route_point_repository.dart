import 'package:geolocator/geolocator.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class RoutePointRepository {
  final DatabaseHelper _databaseHelper;

  RoutePointRepository(this._databaseHelper);

  Future<void> insertRoutePoint(
    int tripId,
    double lat,
    double lng,
    DateTime timestamp,
  ) async {
    final db = await _databaseHelper.database;

    await db.insert(
      'route_points',
      {
        'trip_id': tripId,
        'latitude': lat,
        'longitude': lng,
        'timestamp': timestamp.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getRoutePoints(int tripId) async {
    final db = await _databaseHelper.database;

    return await db.query(
      'route_points',
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'timestamp ASC',
    );
  }

  Future<int> deleteRoutePointsForTrip(int tripId) async {
    final db = await _databaseHelper.database;

    return await db.delete(
      'route_points',
      where: 'trip_id = ?',
      whereArgs: [tripId],
    );
  }

  Future<double> getTotalDistanceForTrip(int tripId) async {
    final routePoints = await getRoutePoints(tripId);

    if (routePoints.length < 2) {
      return 0;
    }

    double totalDistance = 0;

    for (int i = 1; i < routePoints.length; i++) {
      final previous = routePoints[i - 1];
      final current = routePoints[i];

      final previousLatitude =
          (previous['latitude'] as num).toDouble();
      final previousLongitude =
          (previous['longitude'] as num).toDouble();

      final currentLatitude =
          (current['latitude'] as num).toDouble();
      final currentLongitude =
          (current['longitude'] as num).toDouble();

      totalDistance += Geolocator.distanceBetween(
        previousLatitude,
        previousLongitude,
        currentLatitude,
        currentLongitude,
      );
    }

    return totalDistance;
  }
}