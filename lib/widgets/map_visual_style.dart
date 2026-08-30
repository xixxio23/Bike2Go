import 'package:flutter/material.dart';

class MapVisualStyle {
  MapVisualStyle._();

  static Color cyclingPathColor(double? rating) {
    if (rating == null) return Colors.grey;
    if (rating <= 2) return Colors.red;
    if (rating <= 3) return Colors.orange;
    if (rating <= 4) return Colors.yellow.shade700;
    return Colors.green;
  }

  static Color shelterSafetyColor(double? safetyScore) {
    if (safetyScore == null) return Colors.grey;
    if (safetyScore < 40) return Colors.red;
    if (safetyScore < 60) return Colors.orange;
    if (safetyScore < 80) return Colors.yellow.shade700;
    return Colors.green;
  }

  static const roadWorkColor = Colors.deepPurple;
  static const userLocationColor = Colors.blue;
}