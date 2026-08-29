import '../database/repositories/rating_repository.dart';
import '../database/repositories/theft_report_repository.dart';
import '../models/rating_model.dart';
import '../models/shelter_model.dart';

class ShelterSafetyService {
  static const String shelterTargetType = 'shelter';

  final RatingRepository _ratingRepository;
  final TheftReportRepository _theftReportRepository;

  ShelterSafetyService(
    this._ratingRepository,
    this._theftReportRepository,
  );

  Future<Map<String, double?>> calculateSafetyScores(
    List<ShelterModel> shelters,
  ) async {
    if (shelters.isEmpty) {
      return {};
    }

    final allRatings =
        await _ratingRepository.getAllRatings();

    final allTheftReports =
        await _theftReportRepository.getAllReports();

    final ratingsByShelter =
        <String, List<RatingModel>>{};

    for (final rating in allRatings) {
      if (rating.targetType != shelterTargetType) {
        continue;
      }

      ratingsByShelter
          .putIfAbsent(rating.targetId, () => [])
          .add(rating);
    }

    final theftCountByShelter = <String, int>{};

    for (final report in allTheftReports) {
      theftCountByShelter[report.shelterId] =
          (theftCountByShelter[report.shelterId] ?? 0) + 1;
    }

    final safetyScores = <String, double?>{};

    for (final shelter in shelters) {
      final ratings =
          ratingsByShelter[shelter.id] ??
              const <RatingModel>[];

      final theftCount =
          theftCountByShelter[shelter.id] ?? 0;

      final ratingScore =
          _calculateRatingScore(ratings);

      if (ratingScore == null) {
        safetyScores[shelter.id] = null;
        continue;
      }

      final theftScore =
          _calculateTheftScore(theftCount);

      safetyScores[shelter.id] =
          (ratingScore * 0.7) +
          (theftScore * 0.3);
    }

    return safetyScores;
  }

  double? _calculateRatingScore(
    List<RatingModel> ratings,
  ) {
    if (ratings.isEmpty) {
      return null;
    }

    final total = ratings.fold<int>(
      0,
      (sum, rating) => sum + rating.rating,
    );

    final average = total / ratings.length;

    return (average / 5.0) * 100.0;
  }

  double _calculateTheftScore(int theftCount) {
    return 100.0 / (1.0 + theftCount);
  }
}