import 'dart:convert';
import 'dart:io';

import '../database/database_helper.dart';
import '../database/repositories/shelter_repository.dart';
import '../models/shelter_model.dart';

class ShelterDataService {
  final ShelterRepository _repository;

  ShelterDataService(DatabaseHelper databaseHelper)
      : _repository = ShelterRepository(databaseHelper);

  static const String _filePath =
      'data/raw/rastrelliere-per-biciclette.json';

  Future<List<ShelterModel>> loadData() async {
    final file = File(_filePath);

    if (!await file.exists()) {
      throw Exception(
        'Dataset rastrelliere non trovato: $_filePath',
      );
    }

    final jsonString = await file.readAsString();
    final dynamic decoded = jsonDecode(jsonString);

    if (decoded is! List) {
      throw const FormatException(
        'Il dataset delle rastrelliere deve essere un array JSON.',
      );
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(ShelterModel.fromMap)
        .toList();
  }

  Future<void> importData() async {
    final shelters = await loadData();

    await _repository.insertShelters(shelters);
  }
}
