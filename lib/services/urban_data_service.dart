import '../database/database_helper.dart';
import '../database/repositories/cycling_path_repository.dart';
import '../database/repositories/shelter_repository.dart';
import '../database/repositories/road_work_repository.dart';
import '../database/repositories/rating_repository.dart';

import '../models/cycling_path_model.dart';
import '../models/shelter_model.dart';
import '../models/road_work_model.dart';

class UrbanDataService {
  final CyclingPathRepository _cyclingPathRepository;
  final ShelterRepository _shelterRepository;
  final RoadWorkRepository _roadWorkRepository;
  final RatingRepository _ratingRepository;

  UrbanDataService(DatabaseHelper databaseHelper)
      : _cyclingPathRepository =
            CyclingPathRepository(databaseHelper),
        _shelterRepository =
            ShelterRepository(databaseHelper),
        _roadWorkRepository =
            RoadWorkRepository(databaseHelper),
        _ratingRepository =
            RatingRepository(databaseHelper);

  Future<List<CyclingPathModel>> getCyclingPaths() {
    return _cyclingPathRepository.getCyclingPaths();
  }

  Future<List<ShelterModel>> getShelters() {
    return _shelterRepository.getShelters();
  }

  Future<List<RoadWorkModel>> getRoadWorks() {
    return _roadWorkRepository.getRoadWorks();
  }

  Future<Map<String, double>> getAverageRatings({
    required String targetType,
  }) async {
    final ratings = await _ratingRepository.getAllRatings();

    final grouped = <String, List<int>>{};

    for (final rating in ratings) {
      if (rating.targetType != targetType) {
        continue;
      }

      grouped
          .putIfAbsent(rating.targetId, () => [])
          .add(rating.rating);
    }

    final averages = <String, double>{};

    for (final entry in grouped.entries) {
      final values = entry.value;

      if (values.isEmpty) {
        continue;
      }

      final sum = values.reduce((a, b) => a + b);

      averages[entry.key] = sum / values.length;
    }

    return averages;
  }
}