import 'package:sqflite/sqflite.dart';

import '../database_helper.dart';
import 'sync_queue_repository.dart';
import '../../models/theft_report_model.dart';

class TheftReportRepository {
  final DatabaseHelper _databaseHelper;
  late final SyncQueueRepository _syncQueueRepository;

  TheftReportRepository(this._databaseHelper) {
    _syncQueueRepository = SyncQueueRepository(_databaseHelper);
  }

  // ============================================================
  // INSERT
  // ============================================================

  Future<int> insertTheftReport(
    TheftReportModel report, {
    bool addToSyncQueue = true,
  }) async {
    final db = await _databaseHelper.database;

    final id = await db.insert(
      'theft_reports',
      report.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (addToSyncQueue) {
      await _syncQueueRepository.addToQueue(
        syncId: report.syncId,
        entityType: 'theft_report',
        operation: 'insert',
      );
    }

    return id;
  }

  // ============================================================
  // READ
  // ============================================================

  Future<List<TheftReportModel>> getReportsByShelter(
    String shelterId,
  ) async {
    final db = await _databaseHelper.database;

    final maps = await db.query(
      'theft_reports',
      where: 'shelter_id = ?',
      whereArgs: [shelterId],
      orderBy: 'created_at DESC',
    );

    return maps.map(TheftReportModel.fromMap).toList();
  }

  Future<List<TheftReportModel>> getAllReports() async {
    final db = await _databaseHelper.database;

    final maps = await db.query(
      'theft_reports',
      orderBy: 'created_at DESC',
    );

    return maps.map(TheftReportModel.fromMap).toList();
  }

  Future<bool> existsBySyncId(String syncId) async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'theft_reports',
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

  Future<void> deleteTheftReport(int id) async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'theft_reports',
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
      'theft_reports',
      where: 'id = ?',
      whereArgs: [id],
    );

    await _syncQueueRepository.addToQueue(
      syncId: syncId,
      entityType: 'theft_report',
      operation: 'delete',
    );
  }

  // ============================================================
  // DELETE ALL
  // ============================================================

  Future<void> deleteAll() async {
    final db = await _databaseHelper.database;

    final reports = await db.query(
      'theft_reports',
      columns: ['sync_id'],
    );

    await db.delete('theft_reports');

    for (final report in reports) {
      final syncId = report['sync_id'] as String;

      await _syncQueueRepository.addToQueue(
        syncId: syncId,
        entityType: 'theft_report',
        operation: 'delete',
      );
    }
  }
}
