import '../database_helper.dart';
import '../../models/cycling_path_model.dart';

class CyclingPathRepository {
  final DatabaseHelper _databaseHelper;

  CyclingPathRepository(this._databaseHelper);

  Future<List<CyclingPathModel>> getCyclingPaths() async {
    // TODO: implementare dopo la creazione della tabella
    return [];
  }

  Future<CyclingPathModel?> getCyclingPathById(int id) async {
    // TODO: implementare dopo la creazione della tabella
    return null;
  }

  Future<void> insertCyclingPath(CyclingPathModel path) async {
    // TODO: implementare dopo la creazione della tabella
  }

  Future<void> insertCyclingPaths(
    List<CyclingPathModel> paths,
  ) async {
    // TODO: implementare dopo la creazione della tabella
  }

  Future<void> deleteAll() async {
    // TODO: implementare dopo la creazione della tabella
  }
}
