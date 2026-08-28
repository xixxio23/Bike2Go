import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'database_migrations.dart';
import 'database_schema.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'trips.db');

    return openDatabase(
      path,
      version: 4,
      onCreate: DatabaseSchema.create,
      onUpgrade: DatabaseMigrations.upgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> clearAllData() async {
    final db = await database;

    await db.delete('geofence_events');
    await db.delete('route_points');
    await db.delete('moments');
    await db.delete('gps_logs');
    await db.delete('trips');
  }

  Future<Map<String, dynamic>> getDatabaseStats() async {
    final db = await database;

    final tripCount = await db.rawQuery(
      'SELECT COUNT(*) as count FROM trips',
    );

    final momentCount = await db.rawQuery(
      'SELECT COUNT(*) as count FROM moments',
    );

    final gpsLogCount = await db.rawQuery(
      'SELECT COUNT(*) as count FROM gps_logs',
    );

    final routePointCount = await db.rawQuery(
      'SELECT COUNT(*) as count FROM route_points',
    );

    final geofenceCount = await db.rawQuery(
      'SELECT COUNT(*) as count FROM geofence_events',
    );

    return {
      'trips': tripCount.first['count'],
      'moments': momentCount.first['count'],
      'gps_logs': gpsLogCount.first['count'],
      'route_points': routePointCount.first['count'],
      'geofence_events': geofenceCount.first['count'],
    };
  }

  Future<void> close() async {
    if (_database == null) {
      return;
    }

    await _database!.close();
    _database = null;
  }
}