import 'package:flutter/material.dart';

import '../widgets/rating_widget.dart';
import '../widgets/review_widget.dart';
import '../widgets/theft_report_widget.dart';

class UserFeedbackScreen extends StatelessWidget {
  final String targetType;
  final String targetId;

  const UserFeedbackScreen({
    super.key,
    required this.targetType,
    required this.targetId,
  });

  bool get _isCyclingPath =>
      targetType == 'cycling_path';

  bool get _isShelter =>
      targetType == 'shelter';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_isCyclingPath || _isShelter)
            RatingWidget(
              targetType: targetType,
              targetId: targetId,
            ),

          if (_isCyclingPath || _isShelter)
            const SizedBox(height: 16),

          if (_isCyclingPath || _isShelter)
            ReviewWidget(
              targetType: targetType,
              targetId: targetId,
            ),

          if (_isShelter) ...[
            const SizedBox(height: 16),
            TheftReportWidget(
              shelterId: targetId,
            ),
          ],
        ],
      ),
    );
  }
}
