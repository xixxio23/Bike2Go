import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../database_helper.dart';
import '../../models/cycling_path_model.dart';
import '../../models/geo_point_model.dart';

class CyclingPathRepository {
  final DatabaseHelper _databaseHelper;

  CyclingPathRepository(this._databaseHelper);

  Future<List<CyclingPathModel>> getCyclingPaths() async {
    final db = await _databaseHelper.database;

    final maps = await db.query('cycling_paths');

    return maps.map(_fromMap).toList();
  }

  Future<CyclingPathModel?> getCyclingPathById(int codice) async {
    final db = await _databaseHelper.database;

    final maps = await db.query(
      'cycling_paths',
      where: 'codice = ?',
      whereArgs: [codice],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return _fromMap(maps.first);
  }

  Future<void> insertCyclingPath(CyclingPathModel path) async {
    final db = await _databaseHelper.database;

    await db.insert(
      'cycling_paths',
      _toMap(path),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertCyclingPaths(
    List<CyclingPathModel> paths,
  ) async {
    final db = await _databaseHelper.database;

    final batch = db.batch();

    for (final path in paths) {
      batch.insert(
        'cycling_paths',
        _toMap(path),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> deleteAll() async {
    final db = await _databaseHelper.database;

    await db.delete('cycling_paths');
  }

  Map<String, dynamic> _toMap(CyclingPathModel path) {
    return {
      'codice': path.codice,
      'year': path.year,
      'length': path.length,
      'use': path.use,
      'type': path.type,
      'geometry': jsonEncode(
        path.geometry
            .map(
              (line) => line
                  .map(
                    (point) => {
                      'latitude': point.latitude,
                      'longitude': point.longitude,
                    },
                  )
                  .toList(),
            )
            .toList(),
      ),
      'fid': path.fid,
    };
  }

  CyclingPathModel _fromMap(Map<String, dynamic> map) {
    final rawGeometry = jsonDecode(map['geometry'] as String);

    final geometry = (rawGeometry as List)
        .map(
          (line) => (line as List)
              .map(
                (point) => GeoPointModel(
                  latitude: (point['latitude'] as num).toDouble(),
                  longitude: (point['longitude'] as num).toDouble(),
                ),
              )
              .toList(),
        )
        .toList();

    return CyclingPathModel(
      codice: map['codice'] as int,
      year: map['year'] as String?,
      length: (map['length'] as num?)?.toDouble(),
      use: map['use'] as String?,
      type: map['type'] as String?,
      geometry: geometry,
      fid: map['fid'] as String?,
    );
  }
}
