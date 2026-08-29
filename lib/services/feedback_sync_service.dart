import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/database_helper.dart';
import '../database/repositories/rating_repository.dart';
import '../database/repositories/review_repository.dart';
import '../database/repositories/theft_report_repository.dart';
import '../database/repositories/sync_queue_repository.dart';

import '../models/rating_model.dart';
import '../models/review_model.dart';
import '../models/theft_report_model.dart';

class FeedbackSyncService {
  final RatingRepository _ratingRepository;
  final ReviewRepository _reviewRepository;
  final TheftReportRepository _theftReportRepository;
  final SyncQueueRepository _syncQueueRepository;

  final SupabaseClient _supabase;

  Timer? _syncTimer;
  bool _isSyncing = false;

  FeedbackSyncService({
    required DatabaseHelper databaseHelper,
    SupabaseClient? supabaseClient,
  })  : _ratingRepository = RatingRepository(databaseHelper),
        _reviewRepository = ReviewRepository(databaseHelper),
        _theftReportRepository = TheftReportRepository(databaseHelper),
        _syncQueueRepository = SyncQueueRepository(databaseHelper),
        _supabase = supabaseClient ?? Supabase.instance.client;

  bool get isSyncing => _isSyncing;

  void startAutoSync({
    Duration interval = const Duration(minutes: 15),
  }) {
    stopAutoSync();

    unawaited(sync());

    _syncTimer = Timer.periodic(
      interval,
      (_) => unawaited(sync()),
    );
  }

  void stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  void dispose() {
    stopAutoSync();
  }

  Future<void> sync() async {
    if (_isSyncing) {
      return;
    }

    _isSyncing = true;

    try {
      await _uploadPendingChanges();
      await _downloadRemoteData();

      debugPrint(
        'FeedbackSyncService: sincronizzazione completata.',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'FeedbackSyncService: errore sincronizzazione: $e',
      );
      debugPrint('$stackTrace');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _uploadPendingChanges() async {
    final pendingItems =
        await _syncQueueRepository.getPendingItems();

    if (pendingItems.isEmpty) {
      return;
    }

    for (final item in pendingItems) {
      final queueId = item['id'] as int;
      final syncId = item['sync_id'] as String;
      final entityType = item['entity_type'] as String;
      final operation = item['operation'] as String;

      try {
        switch (entityType) {
          case 'rating':
            await _processRating(
              syncId: syncId,
              operation: operation,
            );
            break;

          case 'review':
            await _processReview(
              syncId: syncId,
              operation: operation,
            );
            break;

          case 'theft_report':
            await _processTheftReport(
              syncId: syncId,
              operation: operation,
            );
            break;

          default:
            await _syncQueueRepository.remove(queueId);
            continue;
        }

        await _syncQueueRepository.remove(queueId);
      } catch (e) {
        debugPrint(
          'FeedbackSyncService: errore '
          '$entityType/$syncId: $e',
        );
      }
    }
  }

  Future<void> _processRating({
    required String syncId,
    required String operation,
  }) async {
    if (operation == 'delete') {
      await _supabase
          .from('ratings')
          .delete()
          .eq('sync_id', syncId);
      return;
    }

    final ratings = await _ratingRepository.getAllRatings();

    RatingModel? rating;

    for (final item in ratings) {
      if (item.syncId == syncId) {
        rating = item;
        break;
      }
    }

    if (rating == null) {
      return;
    }

    await _supabase.from('ratings').upsert(
      {
        'sync_id': rating.syncId,
        'target_type': rating.targetType,
        'target_id': rating.targetId,
        'rating': rating.rating,
        'created_at': rating.createdAt.toIso8601String(),
      },
      onConflict: 'sync_id',
    );
  }

  Future<void> _processReview({
    required String syncId,
    required String operation,
  }) async {
    if (operation == 'delete') {
      await _supabase
          .from('reviews')
          .delete()
          .eq('sync_id', syncId);
      return;
    }

    final reviews = await _reviewRepository.getAllReviews();

    ReviewModel? review;

    for (final item in reviews) {
      if (item.syncId == syncId) {
        review = item;
        break;
      }
    }

    if (review == null) {
      return;
    }

    await _supabase.from('reviews').upsert(
      {
        'sync_id': review.syncId,
        'target_type': review.targetType,
        'target_id': review.targetId,
        'text': review.text,
        'created_at': review.createdAt.toIso8601String(),
      },
      onConflict: 'sync_id',
    );
  }

  Future<void> _processTheftReport({
    required String syncId,
    required String operation,
  }) async {
    if (operation == 'delete') {
      await _supabase
          .from('theft_reports')
          .delete()
          .eq('sync_id', syncId);
      return;
    }

    final reports =
        await _theftReportRepository.getAllReports();

    TheftReportModel? report;

    for (final item in reports) {
      if (item.syncId == syncId) {
        report = item;
        break;
      }
    }

    if (report == null) {
      return;
    }

    await _supabase.from('theft_reports').upsert(
      {
        'sync_id': report.syncId,
        'shelter_id': report.shelterId,
        'description': report.description,
        'created_at': report.createdAt.toIso8601String(),
      },
      onConflict: 'sync_id',
    );
  }

  Future<void> _downloadRemoteData() async {
    await _downloadRatings();
    await _downloadReviews();
    await _downloadTheftReports();
  }

  Future<void> _downloadRatings() async {
    final response = await _supabase
        .from('ratings')
        .select()
        .order('created_at');

    for (final map in response) {
      final rating = RatingModel.fromMap(
        Map<String, dynamic>.from(map),
      );

      final exists =
          await _ratingRepository.existsBySyncId(
        rating.syncId,
      );

      if (exists) {
        continue;
      }

      await _ratingRepository.insertRating(
        rating,
        addToSyncQueue: false,
      );
    }
  }

  Future<void> _downloadReviews() async {
    final response = await _supabase
        .from('reviews')
        .select()
        .order('created_at');

    for (final map in response) {
      final review = ReviewModel.fromMap(
        Map<String, dynamic>.from(map),
      );

      final exists =
          await _reviewRepository.existsBySyncId(
        review.syncId,
      );

      if (exists) {
        continue;
      }

      await _reviewRepository.insertReview(
        review,
        addToSyncQueue: false,
      );
    }
  }

  Future<void> _downloadTheftReports() async {
    final response = await _supabase
        .from('theft_reports')
        .select()
        .order('created_at');

    for (final map in response) {
      final report = TheftReportModel.fromMap(
        Map<String, dynamic>.from(map),
      );

      final exists =
          await _theftReportRepository.existsBySyncId(
        report.syncId,
      );

      if (exists) {
        continue;
      }

      await _theftReportRepository.insertTheftReport(
        report,
        addToSyncQueue: false,
      );
    }
  }
}