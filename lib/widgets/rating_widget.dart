import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../services/user_feedback_service.dart';

class RatingWidget extends StatefulWidget {
  final String targetType;
  final String targetId;

  const RatingWidget({
    super.key,
    required this.targetType,
    required this.targetId,
  });

  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  late final UserFeedbackService _service;

  int _selectedRating = 0;
  double _averageRating = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _service = UserFeedbackService(
      DatabaseHelper(),
    );

    _loadRating();
  }

  Future<void> _loadRating() async {
    final average = await _service.getAverageRating(
      targetType: widget.targetType,
      targetId: widget.targetId,
    );

    if (!mounted) return;

    setState(() {
      _averageRating = average;
      _isLoading = false;
    });
  }

  Future<void> _submitRating() async {
    if (_selectedRating == 0) return;

    await _service.addRating(
      targetType: widget.targetType,
      targetId: widget.targetId,
      rating: _selectedRating,
    );

    setState(() {
      _selectedRating = 0;
    });

    await _loadRating();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Valutazione',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _averageRating == 0
                  ? 'Nessuna valutazione'
                  : 'Media: ${_averageRating.toStringAsFixed(1)} / 5',
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) {
                  final rating = index + 1;

                  return IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedRating = rating;
                      });
                    },
                    icon: Icon(
                      rating <= _selectedRating
                          ? Icons.star
                          : Icons.star_border,
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed:
                  _selectedRating == 0 ? null : _submitRating,
              child: const Text('Valuta'),
            ),
          ],
        ),
      ),
    );
  }
}
