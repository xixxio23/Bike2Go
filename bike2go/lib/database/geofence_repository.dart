import 'database_helper.dart';

class GeofenceRepository {
  final DatabaseHelper _databaseHelper;

  GeofenceRepository(this._databaseHelper);

  Future<int> insertGeofenceEvent({
    required double latitude,
    required double longitude,
    required String eventType,
    required DateTime timestamp,
    double? radius,
  }) async {
    final db = await _databaseHelper.database;

    return await db.insert('geofence_events', {
      'latitude': latitude,
      'longitude': longitude,
      'event_type': eventType,
      'timestamp': timestamp.toIso8601String(),
      'radius': radius,
    });
  }

  Future<List<Map<String, dynamic>>> getGeofenceEvents({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _databaseHelper.database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (startDate != null && endDate != null) {
      whereClause = 'timestamp BETWEEN ? AND ?';
      whereArgs = [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ];
    }

    return await db.query(
      'geofence_events',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'timestamp DESC',
    );
  }
}