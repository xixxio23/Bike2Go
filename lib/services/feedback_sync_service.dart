import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/database_helper.dart';
import '../database/repositories/rating_repository.dart';
import '../database/repositories/review_repository.dart';
import '../database/repositories/theft_report_repository.dart';

class FeedbackSyncService {
  final RatingRepository _ratingRepository;
  final ReviewRepository _reviewRepository;
  final TheftReportRepository _theftReportRepository;

  final SupabaseClient _supabase;

  FeedbackSyncService({
    required DatabaseHelper databaseHelper,
    SupabaseClient? supabaseClient,
  })  : _ratingRepository = RatingRepository(databaseHelper),
        _reviewRepository = ReviewRepository(databaseHelper),
        _theftReportRepository = TheftReportRepository(databaseHelper),
        _supabase = supabaseClient ?? Supabase.instance.client;

  Future<void> sync() async {
    await syncRatings();
    await syncReviews();
    await syncTheftReports();
  }

  Future<void> syncRatings() async {
    final ratings = await _ratingRepository.getAllRatings();

    if (ratings.isEmpty) return;

    final data = ratings.map((rating) {
      return {
        'sync_id': rating.syncId,
        'target_type': rating.targetType,
        'target_id': rating.targetId,
        'rating': rating.rating,
        'created_at': rating.createdAt.toIso8601String(),
      };
    }).toList();

    await _supabase
        .from('ratings')
        .upsert(data, onConflict: 'sync_id');
  }

  Future<void> syncReviews() async {
    final reviews = await _reviewRepository.getAllReviews();

    if (reviews.isEmpty) return;

    final data = reviews.map((review) {
      return {
        'sync_id': review.syncId,
        'target_type': review.targetType,
        'target_id': review.targetId,
        'text': review.text,
        'created_at': review.createdAt.toIso8601String(),
      };
    }).toList();

    await _supabase
        .from('reviews')
        .upsert(data, onConflict: 'sync_id');
  }

  Future<void> syncTheftReports() async {
    final reports = await _theftReportRepository.getAllReports();

    if (reports.isEmpty) return;

    final data = reports.map((report) {
      return {
        'sync_id': report.syncId,
        'shelter_id': report.shelterId,
        'description': report.description,
        'created_at': report.createdAt.toIso8601String(),
      };
    }).toList();

    await _supabase
        .from('theft_reports')
        .upsert(data, onConflict: 'sync_id');
  }
}
