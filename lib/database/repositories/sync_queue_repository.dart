import '../database_helper.dart';

class SyncQueueRepository {
  final DatabaseHelper _databaseHelper;

  SyncQueueRepository(this._databaseHelper);

  // ============================================================
  // INSERT
  // ============================================================

  Future<int> addToQueue({
    required String syncId,
    required String entityType,
    required String operation,
  }) async {
    final db = await _databaseHelper.database;

    return db.insert(
      'sync_queue',
      {
        'sync_id': syncId,
        'entity_type': entityType,
        'operation': operation,
        'updated_at': DateTime.now().toIso8601String(),
      },
    );
  }

  // ============================================================
  // READ
  // ============================================================

  Future<List<Map<String, dynamic>>> getPendingItems() async {
    final db = await _databaseHelper.database;

    return db.query(
      'sync_queue',
      orderBy: 'id ASC',
    );
  }

  Future<Map<String, dynamic>?> getById(int id) async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'sync_queue',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> remove(int id) async {
    final db = await _databaseHelper.database;

    await db.delete(
      'sync_queue',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // UTILITY
  // ============================================================

  Future<void> clear() async {
    final db = await _databaseHelper.database;

    await db.delete('sync_queue');
  }

  Future<int> count() async {
    final db = await _databaseHelper.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM sync_queue',
    );

    return (result.first['count'] as num?)?.toInt() ?? 0;
  }
}
