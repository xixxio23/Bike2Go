import 'package:sqflite/sqflite.dart';

import '../database_helper.dart';
import '../../models/rating_model.dart';

class RatingRepository {
  final DatabaseHelper _databaseHelper;

  RatingRepository(this._databaseHelper);

  Future<int> insertRating(RatingModel rating) async {
    final db = await _databaseHelper.database;

    return db.insert(
      'ratings',
      rating.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<RatingModel>> getRatingsByTarget(
    String targetType,
    String targetId,
  ) async {
    final db = await _databaseHelper.database;

    final maps = await db.query(
      'ratings',
      where: 'target_type = ? AND target_id = ?',
      whereArgs: [targetType, targetId],
      orderBy: 'created_at DESC',
    );

    return maps.map(RatingModel.fromMap).toList();
  }

  Future<List<RatingModel>> getAllRatings() async {
    final db = await _databaseHelper.database;

    final maps = await db.query(
      'ratings',
      orderBy: 'created_at DESC',
    );

    return maps.map(RatingModel.fromMap).toList();
  }

  Future<void> deleteRating(int id) async {
    final db = await _databaseHelper.database;

    await db.delete(
      'ratings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAll() async {
    final db = await _databaseHelper.database;

    await db.delete('ratings');
  }
}
