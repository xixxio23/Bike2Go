class RatingModel {
  final int? id;
  final String syncId;
  final String targetType;
  final String targetId;
  final int rating;
  final DateTime createdAt;

  const RatingModel({
    this.id,
    required this.syncId,
    required this.targetType,
    required this.targetId,
    required this.rating,
    required this.createdAt,
  });

  factory RatingModel.fromMap(Map<String, dynamic> map) {
    return RatingModel(
      id: map['id'] as int?,
      syncId: map['sync_id'] as String,
      targetType: map['target_type'] as String,
      targetId: map['target_id'] as String,
      rating: (map['rating'] as num).toInt(),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'sync_id': syncId,
      'target_type': targetType,
      'target_id': targetId,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

