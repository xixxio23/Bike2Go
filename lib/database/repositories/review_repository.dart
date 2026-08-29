import 'package:sqflite/sqflite.dart';

import '../database_helper.dart';
import 'sync_queue_repository.dart';
import '../../models/review_model.dart';

class ReviewRepository {
  final DatabaseHelper _databaseHelper;
  late final SyncQueueRepository _syncQueueRepository;

  ReviewRepository(this._databaseHelper) {
    _syncQueueRepository = SyncQueueRepository(_databaseHelper);
  }

  // ============================================================
  // INSERT
  // ============================================================

  Future<int> insertReview(
    ReviewModel review, {
    bool addToSyncQueue = true,
  }) async {
    final db = await _databaseHelper.database;

    final id = await db.insert(
      'reviews',
      review.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (addToSyncQueue) {
      await _syncQueueRepository.addToQueue(
        syncId: review.syncId,
        entityType: 'review',
        operation: 'insert',
      );
    }

    return id;
  }

  // ============================================================
  // READ
  // ============================================================

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

  Future<bool> existsBySyncId(String syncId) async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'reviews',
      columns: ['sync_id'],
      where: 'sync_id = ?',
      whereArgs: [syncId],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deleteReview(int id) async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'reviews',
      columns: ['sync_id'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return;
    }

    final syncId = result.first['sync_id'] as String;

    await db.delete(
      'reviews',
      where: 'id = ?',
      whereArgs: [id],
    );

    await _syncQueueRepository.addToQueue(
      syncId: syncId,
      entityType: 'review',
      operation: 'delete',
    );
  }

  // ============================================================
  // DELETE ALL
  // ============================================================

  Future<void> deleteAll() async {
    final db = await _databaseHelper.database;

    final reviews = await db.query(
      'reviews',
      columns: ['sync_id'],
    );

    await db.delete('reviews');

    for (final review in reviews) {
      final syncId = review['sync_id'] as String;

      await _syncQueueRepository.addToQueue(
        syncId: syncId,
        entityType: 'review',
        operation: 'delete',
      );
    }
  }
}
