import '../database_helper.dart';
import '../../models/road_work_model.dart';

import 'package:sqflite/sqflite.dart';

class RoadWorkRepository {
  final DatabaseHelper _databaseHelper;

  RoadWorkRepository(this._databaseHelper);

  Future<List<RoadWorkModel>> getRoadWorks() async {
    final db = await _databaseHelper.database;

    final maps = await db.query('road_works');

    return maps.map(_fromMap).toList();
  }

  Future<RoadWorkModel?> getRoadWorkById(int id) async {
    final db = await _databaseHelper.database;

    final maps = await db.query(
      'road_works',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return _fromMap(maps.first);
  }

  Future<void> insertRoadWork(RoadWorkModel roadWork) async {
    final db = await _databaseHelper.database;

    await db.insert(
      'road_works',
      _toMap(roadWork),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertRoadWorks(
    List<RoadWorkModel> roadWorks,
  ) async {
    final db = await _databaseHelper.database;

    final batch = db.batch();

    for (final roadWork in roadWorks) {
      batch.insert(
        'road_works',
        _toMap(roadWork),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> deleteAll() async {
    final db = await _databaseHelper.database;

    await db.delete('road_works');
  }

  Map<String, dynamic> _toMap(RoadWorkModel roadWork) {
    return {
      'id': roadWork.id,
      'latitude': roadWork.latitude,
      'longitude': roadWork.longitude,
      'address': roadWork.address,
      'neighborhood': roadWork.neighborhood,
      'status': roadWork.status,
      'start_date': roadWork.startDate?.toIso8601String(),
      'end_date': roadWork.endDate?.toIso8601String(),
      'traffic_changes_measure': roadWork.trafficChangesMeasure,
      'description': roadWork.description,
      'visualization_notes': roadWork.visualizationNotes,
    };
  }

  RoadWorkModel _fromMap(Map<String, dynamic> map) {
    return RoadWorkModel(
      id: map['id'] as int,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      address: map['address'] as String?,
      neighborhood: map['neighborhood'] as String?,
      status: map['status'] as String?,
      startDate: _parseDate(map['start_date']),
      endDate: _parseDate(map['end_date']),
      trafficChangesMeasure:
          map['traffic_changes_measure'] as String?,
      description: map['description'] as String?,
      visualizationNotes:
          map['visualization_notes'] as String?,
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value as String);
  }
}
