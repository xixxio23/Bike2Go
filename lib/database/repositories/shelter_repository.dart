import '../database_helper.dart';
import '../../models/shelter_model.dart';
import 'package:sqflite/sqflite.dart';

class ShelterRepository {
  final DatabaseHelper _databaseHelper;

  ShelterRepository(this._databaseHelper);

  Future<List<ShelterModel>> getShelters() async {
    final db = await _databaseHelper.database;

    final maps = await db.query('shelters');

    return maps.map(_fromMap).toList();
  }

  Future<ShelterModel?> getShelterById(String id) async {
    final db = await _databaseHelper.database;

    final maps = await db.query(
      'shelters',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return _fromMap(maps.first);
  }

  Future<void> insertShelter(ShelterModel shelter) async {
    final db = await _databaseHelper.database;

    await db.insert(
      'shelters',
      _toMap(shelter),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertShelters(
    List<ShelterModel> shelters,
  ) async {
    final db = await _databaseHelper.database;

    final batch = db.batch();

    for (final shelter in shelters) {
      batch.insert(
        'shelters',
        _toMap(shelter),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> deleteAll() async {
    final db = await _databaseHelper.database;

    await db.delete('shelters');
  }

  Map<String, dynamic> _toMap(ShelterModel shelter) {
    return {
      'id': shelter.id,
      'latitude': shelter.latitude,
      'longitude': shelter.longitude,
      'street_name': shelter.streetName,
      'street_number': shelter.streetNumber,
      'capacity': shelter.capacity,
    };
  }

  ShelterModel _fromMap(Map<String, dynamic> map) {
    return ShelterModel(
      id: map['id'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      streetName: map['street_name'] as String?,
      streetNumber: map['street_number'] as String?,
      capacity: map['capacity'] as int?,
    );
  }
}
