import '../database_helper.dart';
import '../../models/road_work_model.dart';

class RoadWorkRepository {
  final DatabaseHelper _databaseHelper;

  RoadWorkRepository(this._databaseHelper);

  Future<List<RoadWorkModel>> getRoadWorks() async {
    // TODO: implementare dopo la creazione della tabella
    return [];
  }

  Future<RoadWorkModel?> getRoadWorkById(int id) async {
    // TODO: implementare dopo la creazione della tabella
    return null;
  }

  Future<void> insertRoadWork(RoadWorkModel roadWork) async {
    // TODO: implementare dopo la creazione della tabella
  }

  Future<void> insertRoadWorks(
    List<RoadWorkModel> roadWorks,
  ) async {
    // TODO: implementare dopo la creazione della tabella
  }

  Future<void> deleteAll() async {
    // TODO: implementare dopo la creazione della tabella
  }
}
