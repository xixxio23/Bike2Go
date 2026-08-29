import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/review_model.dart';
import '../services/user_feedback_service.dart';

class ReviewWidget extends StatefulWidget {
  final String targetType;
  final String targetId;

  const ReviewWidget({
    super.key,
    required this.targetType,
    required this.targetId,
  });

  @override
  State<ReviewWidget> createState() => _ReviewWidgetState();
}

class _ReviewWidgetState extends State<ReviewWidget> {
  late final UserFeedbackService _service;

  final TextEditingController _controller =
      TextEditingController();

  List<ReviewModel> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _service = UserFeedbackService(
      DatabaseHelper(),
    );

    _loadReviews();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    final reviews = await _service.getReviews(
      targetType: widget.targetType,
      targetId: widget.targetId,
    );

    if (!mounted) return;

    setState(() {
      _reviews = reviews;
      _isLoading = false;
    });
  }

  Future<void> _submitReview() async {
    final text = _controller.text.trim();

    if (text.isEmpty) return;

    await _service.addReview(
      targetType: widget.targetType,
      targetId: widget.targetId,
      text: text,
    );

    _controller.clear();

    await _loadReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recensioni',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Scrivi una recensione...',
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _submitReview,
              child: const Text('Pubblica'),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (_reviews.isEmpty)
              const Text('Nessuna recensione.')
            else
              ..._reviews.map(
                (review) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(review.text),
                  subtitle: Text(
                    review.createdAt.toLocal().toString(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
