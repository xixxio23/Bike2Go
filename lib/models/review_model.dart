class ReviewModel {
  final int? id;
  final String syncId;
  final String targetType;
  final String targetId;
  final String text;
  final DateTime createdAt;

  const ReviewModel({
    this.id,
    required this.syncId,
    required this.targetType,
    required this.targetId,
    required this.text,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] as int?,
      syncId: map['sync_id'] as String,
      targetType: map['target_type'] as String,
      targetId: map['target_id'] as String,
      text: map['text'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'sync_id': syncId,
      'target_type': targetType,
      'target_id': targetId,
      'text': text,
      'created_at': createdAt.toIso8601String(),
    };
  }
}