import 'package:sqflite/sqflite.dart';

class DatabaseSchema {
  static Future<void> create(Database db, int version) async {
    // ============================================================
    // OPEN DATA - COMUNE DI BOLOGNA
    // ============================================================

    await db.execute('''
      CREATE TABLE cycling_paths (
        codice INTEGER PRIMARY KEY,
        year TEXT,
        length REAL,
        use TEXT,
        type TEXT,
        geometry TEXT NOT NULL,
        fid TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE shelters (
        id TEXT PRIMARY KEY,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        street_name TEXT,
        street_number TEXT,
        capacity INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE road_works (
        id INTEGER PRIMARY KEY,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        address TEXT,
        neighborhood TEXT,
        status TEXT,
        start_date TEXT,
        end_date TEXT,
        traffic_changes_measure TEXT,
        description TEXT,
        visualization_notes TEXT
      )
    ''');

    // ============================================================
    // CONTRIBUTI UTENTE
    // ============================================================

    await db.execute('''
      CREATE TABLE ratings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        target_type TEXT NOT NULL,
        target_id TEXT NOT NULL,
        rating INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        target_type TEXT NOT NULL,
        target_id TEXT NOT NULL,
        text TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE theft_reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shelter_id TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (shelter_id) REFERENCES shelters(id)
          ON DELETE CASCADE
      )
    ''');

    // ============================================================
    // ACTIVITY RECOGNITION
    // ============================================================

    await db.execute('''
      CREATE TABLE activity_events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        activity TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // ============================================================
    // PREFERENZE UTENTE
    // ============================================================

    await db.execute('''
      CREATE TABLE user_preferences (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }
}