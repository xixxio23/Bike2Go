import '../models/gps_log_model.dart';
import 'database_helper.dart';

class GpsLogRepository {
  final DatabaseHelper _databaseHelper;

  GpsLogRepository(this._databaseHelper);

  Future<int> insertGpsLog(GpsLog log) async {
    final db = await _databaseHelper.database;
    return await db.insert('gps_logs', log.toMap());
  }

  Future<List<GpsLog>> getGpsLogsForTrip(int tripId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'gps_logs',
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'timestamp ASC',
    );

    return maps.map((map) => GpsLog.fromMap(map)).toList();
  }

  Future<int> deleteGpsLogsForTrip(int tripId) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'gps_logs',
      where: 'trip_id = ?',
      whereArgs: [tripId],
    );
  }
}