import 'package:sqflite/sqflite.dart';

import '../database_helper.dart';
import 'sync_queue_repository.dart';
import '../../models/rating_model.dart';

class RatingRepository {
  final DatabaseHelper _databaseHelper;
  late final SyncQueueRepository _syncQueueRepository;

  RatingRepository(this._databaseHelper) {
    _syncQueueRepository = SyncQueueRepository(_databaseHelper);
  }

  // ============================================================
  // INSERT
  // ============================================================

  Future<int> insertRating(
    RatingModel rating, {
    bool addToSyncQueue = true,
  }) async {
    final db = await _databaseHelper.database;

    final id = await db.insert(
      'ratings',
      rating.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (addToSyncQueue) {
      await _syncQueueRepository.addToQueue(
        syncId: rating.syncId,
        entityType: 'rating',
        operation: 'insert',
      );
    }

    return id;
  }

  // ============================================================
  // READ
  // ============================================================

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

  Future<bool> existsBySyncId(String syncId) async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'ratings',
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

  Future<void> deleteRating(int id) async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'ratings',
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
      'ratings',
      where: 'id = ?',
      whereArgs: [id],
    );

    await _syncQueueRepository.addToQueue(
      syncId: syncId,
      entityType: 'rating',
      operation: 'delete',
    );
  }

  // ============================================================
  // DELETE ALL
  // ============================================================

  Future<void> deleteAll() async {
    final db = await _databaseHelper.database;

    final ratings = await db.query(
      'ratings',
      columns: ['sync_id'],
    );

    await db.delete('ratings');

    for (final rating in ratings) {
      final syncId = rating['sync_id'] as String;

      await _syncQueueRepository.addToQueue(
        syncId: syncId,
        entityType: 'rating',
        operation: 'delete',
      );
    }
  }
}
