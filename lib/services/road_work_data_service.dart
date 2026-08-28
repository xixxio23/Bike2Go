import 'dart:convert';
import 'dart:io';

import '../database/database_helper.dart';
import '../database/repositories/road_work_repository.dart';
import '../models/road_work_model.dart';

class RoadWorkDataService {
  final RoadWorkRepository _repository;

  RoadWorkDataService(DatabaseHelper databaseHelper)
      : _repository = RoadWorkRepository(databaseHelper);

  static const String _filePath =
      'data/raw/lavori-pubblici.json';

  Future<List<RoadWorkModel>> loadData() async {
    final file = File(_filePath);

    if (!await file.exists()) {
      throw Exception(
        'Dataset lavori pubblici non trovato: $_filePath',
      );
    }

    final jsonString = await file.readAsString();
    final dynamic decoded = jsonDecode(jsonString);

    if (decoded is! List) {
      throw const FormatException(
        'Il dataset dei lavori pubblici deve essere un array JSON.',
      );
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(RoadWorkModel.fromMap)
        .toList();
  }

  Future<void> importData() async {
    final roadWorks = await loadData();

    await _repository.insertRoadWorks(roadWorks);
  }
}
