import '../database/database_helper.dart';
import '../database/repositories/cycling_path_repository.dart';
import '../database/repositories/shelter_repository.dart';
import '../database/repositories/road_work_repository.dart';
import '../models/cycling_path_model.dart';
import '../models/shelter_model.dart';
import '../models/road_work_model.dart';

class UrbanDataService {
  final CyclingPathRepository _cyclingPathRepository;
  final ShelterRepository _shelterRepository;
  final RoadWorkRepository _roadWorkRepository;

  UrbanDataService(DatabaseHelper databaseHelper)
      : _cyclingPathRepository =
            CyclingPathRepository(databaseHelper),
        _shelterRepository =
            ShelterRepository(databaseHelper),
        _roadWorkRepository =
            RoadWorkRepository(databaseHelper);

  Future<List<CyclingPathModel>> getCyclingPaths() {
    return _cyclingPathRepository.getCyclingPaths();
  }

  Future<List<ShelterModel>> getShelters() {
    return _shelterRepository.getShelters();
  }

  Future<List<RoadWorkModel>> getRoadWorks() {
    return _roadWorkRepository.getRoadWorks();
  }
}
