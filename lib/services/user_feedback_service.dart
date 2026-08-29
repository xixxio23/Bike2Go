import '../database/database_helper.dart';
import '../database/repositories/rating_repository.dart';
import '../database/repositories/review_repository.dart';
import '../database/repositories/theft_report_repository.dart';
import '../models/rating_model.dart';
import '../models/review_model.dart';
import '../models/theft_report_model.dart';

class UserFeedbackService {
  final RatingRepository _ratingRepository;
  final ReviewRepository _reviewRepository;
  final TheftReportRepository _theftReportRepository;

  UserFeedbackService(DatabaseHelper databaseHelper)
      : _ratingRepository = RatingRepository(databaseHelper),
        _reviewRepository = ReviewRepository(databaseHelper),
        _theftReportRepository =
            TheftReportRepository(databaseHelper);

  // ============================================================
  // RATINGS
  // ============================================================

  Future<int> addRating({
    required String targetType,
    required String targetId,
    required int rating,
  }) async {
    if (rating < 1 || rating > 5) {
      throw ArgumentError('Il rating deve essere compreso tra 1 e 5.');
    }

    final model = RatingModel(
      targetType: targetType,
      targetId: targetId,
      rating: rating,
      createdAt: DateTime.now(),
    );

    return _ratingRepository.insertRating(model);
  }

  Future<List<RatingModel>> getRatings({
    required String targetType,
    required String targetId,
  }) {
    return _ratingRepository.getRatingsByTarget(
      targetType,
      targetId,
    );
  }

  Future<double> getAverageRating({
    required String targetType,
    required String targetId,
  }) async {
    final ratings = await getRatings(
      targetType: targetType,
      targetId: targetId,
    );

    if (ratings.isEmpty) {
      return 0.0;
    }

    final total = ratings.fold<int>(
      0,
      (sum, rating) => sum + rating.rating,
    );

    return total / ratings.length;
  }

  // ============================================================
  // REVIEWS
  // ============================================================

  Future<int> addReview({
    required String targetType,
    required String targetId,
    required String text,
  }) async {
    if (text.trim().isEmpty) {
      throw ArgumentError('Il testo della recensione non può essere vuoto.');
    }

    final model = ReviewModel(
      targetType: targetType,
      targetId: targetId,
      text: text.trim(),
      createdAt: DateTime.now(),
    );

    return _reviewRepository.insertReview(model);
  }

  Future<List<ReviewModel>> getReviews({
    required String targetType,
    required String targetId,
  }) {
    return _reviewRepository.getReviewsByTarget(
      targetType,
      targetId,
    );
  }

  // ============================================================
  // THEFT REPORTS
  // ============================================================

  Future<int> addTheftReport({
    required String shelterId,
    String? description,
  }) async {
    final model = TheftReportModel(
      shelterId: shelterId,
      description: description?.trim().isEmpty == true
          ? null
          : description?.trim(),
      createdAt: DateTime.now(),
    );

    return _theftReportRepository.insertTheftReport(model);
  }

  Future<List<TheftReportModel>> getTheftReports(
    String shelterId,
  ) {
    return _theftReportRepository.getReportsByShelter(
      shelterId,
    );
  }
}
