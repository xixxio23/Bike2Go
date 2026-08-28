import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseMigrations {
  static Future<void> upgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE gps_logs RENAME TO gps_logs_old');

        await db.execute('''
          CREATE TABLE gps_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            trip_id INTEGER NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            timestamp TEXT NOT NULL,
            FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          INSERT INTO gps_logs (id, trip_id, latitude, longitude, timestamp)
          SELECT id, tripId, latitude, longitude, timestamp FROM gps_logs_old
        ''');

        await db.execute('DROP TABLE gps_logs_old');
      } catch (e) {
        debugPrint('Migration error (likely safe to ignore): $e');
      }

      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS moments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            trip_id INTEGER NOT NULL,
            latitude REAL,
            longitude REAL,
            photo_path TEXT,
            note TEXT,
            timestamp TEXT NOT NULL,
            FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE
          )
        ''');
      } catch (e) {
        debugPrint('Moments table creation error: $e');
      }

      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS route_points (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            trip_id INTEGER NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            timestamp TEXT NOT NULL,
            FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE
          )
        ''');
      } catch (e) {
        debugPrint('Route points table creation error: $e');
      }

      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS geofence_events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            event_type TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            radius REAL
          )
        ''');
      } catch (e) {
        debugPrint('Geofence table creation error (likely safe to ignore): $e');
      }
    }

    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE trips ADD COLUMN distance REAL');
      } catch (e) {
        debugPrint('Distance column addition error (likely safe to ignore): $e');
      }

      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS moments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            trip_id INTEGER NOT NULL,
            latitude REAL,
            longitude REAL,
            photo_path TEXT,
            note TEXT,
            timestamp TEXT NOT NULL,
            FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE
          )
        ''');
      } catch (e) {
        debugPrint('Moments table creation error: $e');
      }

      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS route_points (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            trip_id INTEGER NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            timestamp TEXT NOT NULL,
            FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE
          )
        ''');
      } catch (e) {
        debugPrint('Route points table creation error: $e');
      }

      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS geofence_events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            event_type TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            radius REAL
          )
        ''');
      } catch (e) {
        debugPrint('Geofence table creation error: $e');
      }
    }

    if (oldVersion < 4) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS moments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            trip_id INTEGER NOT NULL,
            latitude REAL,
            longitude REAL,
            photo_path TEXT,
            note TEXT,
            timestamp TEXT NOT NULL,
            FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE
          )
        ''');
      } catch (e) {
        debugPrint('Moments table creation error: $e');
      }

      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS route_points (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            trip_id INTEGER NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            timestamp TEXT NOT NULL,
            FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE
          )
        ''');
      } catch (e) {
        debugPrint('Route points table creation error: $e');
      }

      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS geofence_events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            event_type TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            radius REAL
          )
        ''');
      } catch (e) {
        debugPrint('Geofence table creation error: $e');
      }

      try {
        await db.execute('ALTER TABLE trips ADD COLUMN distance REAL');
      } catch (e) {
        debugPrint('Distance column addition error (likely safe to ignore): $e');
      }
    }
  }
}