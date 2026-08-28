import 'dart:convert';
import 'dart:io';

import '../database/database_helper.dart';
import '../database/repositories/cycling_path_repository.dart';
import '../models/cycling_path_model.dart';

class CyclingPathDataService {
  final CyclingPathRepository _repository;

  CyclingPathDataService(DatabaseHelper databaseHelper)
      : _repository = CyclingPathRepository(databaseHelper);

  static const String _filePath =
      'data/raw/piste-ciclopedonali.json';

  Future<List<CyclingPathModel>> loadData() async {
    final file = File(_filePath);

    if (!await file.exists()) {
      throw Exception(
        'Dataset piste ciclabili non trovato: $_filePath',
      );
    }

    final jsonString = await file.readAsString();
    final dynamic decoded = jsonDecode(jsonString);

    if (decoded is! List) {
      throw const FormatException(
        'Il dataset delle piste ciclabili deve essere un array JSON.',
      );
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(CyclingPathModel.fromMap)
        .toList();
  }

  Future<void> importData() async {
    final paths = await loadData();

    await _repository.insertCyclingPaths(paths);
  }
}