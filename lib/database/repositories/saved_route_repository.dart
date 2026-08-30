import 'package:sqflite/sqflite.dart';

import '../database_helper.dart';
import '../../models/saved_route_model.dart';

class SavedRouteRepository {
  final DatabaseHelper _databaseHelper;

  SavedRouteRepository(this._databaseHelper);

  // ============================================================
  // INSERT
  // ============================================================

  Future<void> insertSavedRoute(
    SavedRouteModel route,
  ) async {
    final db = await _databaseHelper.database;

    await db.insert(
      'saved_routes',
      route.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ============================================================
  // READ
  // ============================================================

  Future<List<SavedRouteModel>> getAllSavedRoutes() async {
    final db = await _databaseHelper.database;

    final maps = await db.query(
      'saved_routes',
      orderBy: 'saved_at DESC',
    );

    return maps.map(SavedRouteModel.fromMap).toList();
  }

  Future<SavedRouteModel?> getSavedRouteById(
    String id,
  ) async {
    final db = await _databaseHelper.database;

    final maps = await db.query(
      'saved_routes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return SavedRouteModel.fromMap(maps.first);
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deleteSavedRoute(
    String id,
  ) async {
    final db = await _databaseHelper.database;

    await db.delete(
      'saved_routes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // DELETE ALL
  // ============================================================

  Future<void> deleteAll() async {
    final db = await _databaseHelper.database;

    await db.delete('saved_routes');
  }
}