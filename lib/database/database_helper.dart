import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
    final path = join(dbPath, 'bike2go.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: DatabaseSchema.create,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> clearAllData() async {
    final db = await database;

    await db.delete('theft_reports');
    await db.delete('reviews');
    await db.delete('ratings');
    await db.delete('activity_events');
    await db.delete('user_preferences');

    await db.delete('road_works');
    await db.delete('shelters');
    await db.delete('cycling_paths');
  }

  Future<Map<String, dynamic>> getDatabaseStats() async {
    final db = await database;

    final cyclingPaths = await db.rawQuery(
      'SELECT COUNT(*) as count FROM cycling_paths',
    );

    final shelters = await db.rawQuery(
      'SELECT COUNT(*) as count FROM shelters',
    );

    final roadWorks = await db.rawQuery(
      'SELECT COUNT(*) as count FROM road_works',
    );

    final ratings = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ratings',
    );

    final reviews = await db.rawQuery(
      'SELECT COUNT(*) as count FROM reviews',
    );

    final theftReports = await db.rawQuery(
      'SELECT COUNT(*) as count FROM theft_reports',
    );

    final activityEvents = await db.rawQuery(
      'SELECT COUNT(*) as count FROM activity_events',
    );

    return {
      'cycling_paths': cyclingPaths.first['count'],
      'shelters': shelters.first['count'],
      'road_works': roadWorks.first['count'],
      'ratings': ratings.first['count'],
      'reviews': reviews.first['count'],
      'theft_reports': theftReports.first['count'],
      'activity_events': activityEvents.first['count'],
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
