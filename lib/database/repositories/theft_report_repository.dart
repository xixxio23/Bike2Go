import 'package:sqflite/sqflite.dart';

import '../database_helper.dart';
import '../../models/theft_report_model.dart';

class TheftReportRepository {
  final DatabaseHelper _databaseHelper;

  TheftReportRepository(this._databaseHelper);

  Future<int> insertTheftReport(
    TheftReportModel report,
  ) async {
    final db = await _databaseHelper.database;

    return db.insert(
      'theft_reports',
      report.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

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

  Future<void> deleteTheftReport(int id) async {
    final db = await _databaseHelper.database;

    await db.delete(
      'theft_reports',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAll() async {
    final db = await _databaseHelper.database;

    await db.delete('theft_reports');
  }
}
