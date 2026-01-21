class RoqayaSharyaaModel {
  final String id;
  final String content;
  final int initialCount;
  final int currentCount;

  RoqayaSharyaaModel({
    required this.id,
    required this.content,
    required this.initialCount,
    required this.currentCount,
  });

  /// Used when loading from assets JSON
  factory RoqayaSharyaaModel.fromJson(
    Map<String, dynamic> json,
    int index,
  ) {
    final int count = json['count'] ?? 1;

    return RoqayaSharyaaModel(
      id: 'dua_$index',
      content: json['content'] as String,
      initialCount: count,
      currentCount: count,
    );
  }

  /// Used when loading from local storage (Hive / SharedPreferences)
  factory RoqayaSharyaaModel.fromSavedJson(Map<String, dynamic> json) {
    return RoqayaSharyaaModel(
      id: json['id'],
      content: json['content'],
      initialCount: json['initialCount'] ?? 1,
      currentCount: json['currentCount'] ?? json['initialCount'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'initialCount': initialCount,
      'currentCount': currentCount,
    };
  }

  RoqayaSharyaaModel copyWith({
    String? id,
    String? content,
    int? initialCount,
    int? currentCount,
  }) {
    return RoqayaSharyaaModel(
      id: id ?? this.id,
      content: content ?? this.content,
      initialCount: initialCount ?? this.initialCount,
      currentCount: currentCount ?? this.currentCount,
    );
  }
}
