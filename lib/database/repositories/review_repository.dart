import 'package:sqflite/sqflite.dart';

import '../database_helper.dart';
import '../../models/review_model.dart';

class ReviewRepository {
  final DatabaseHelper _databaseHelper;

  ReviewRepository(this._databaseHelper);

  Future<int> insertReview(ReviewModel review) async {
    final db = await _databaseHelper.database;

    return db.insert(
      'reviews',
      review.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ReviewModel>> getReviewsByTarget(
    String targetType,
    String targetId,
  ) async {
    final db = await _databaseHelper.database;

    final maps = await db.query(
      'reviews',
      where: 'target_type = ? AND target_id = ?',
      whereArgs: [targetType, targetId],
      orderBy: 'created_at DESC',
    );

    return maps.map(ReviewModel.fromMap).toList();
  }

  Future<List<ReviewModel>> getAllReviews() async {
    final db = await _databaseHelper.database;

    final maps = await db.query(
      'reviews',
      orderBy: 'created_at DESC',
    );

    return maps.map(ReviewModel.fromMap).toList();
  }

  Future<void> deleteReview(int id) async {
    final db = await _databaseHelper.database;

    await db.delete(
      'reviews',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAll() async {
    final db = await _databaseHelper.database;

    await db.delete('reviews');
  }
}
