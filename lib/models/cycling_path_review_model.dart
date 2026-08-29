class RatingModel {
  final int? id;
  final String targetType;
  final String targetId;
  final int rating;
  final DateTime createdAt;

  const RatingModel({
    this.id,
    required this.targetType,
    required this.targetId,
    required this.rating,
    required this.createdAt,
  });

  factory RatingModel.fromMap(Map<String, dynamic> map) {
    return RatingModel(
      id: map['id'] as int?,
      targetType: map['target_type'] as String,
      targetId: map['target_id'] as String,
      rating: map['rating'] as int,
      createdAt: DateTime.parse(
        map['created_at'] as String,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'target_type': targetType,
      'target_id': targetId,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
