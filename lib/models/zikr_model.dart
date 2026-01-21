class ZikrModel {
  final String id; // unique identifier
  final String category;
  final int initialCount;
  final int currentCount;
  final String content;
  final String description;
  final String reference;
  final String? preText; // ما قبل الذكر
  final int order; // ترتيب الذكر

  ZikrModel({
    required this.id,
    required this.category,
    required this.initialCount,
    required this.currentCount,
    required this.content,
    this.description = '',
    this.reference = '',
    this.preText,
    this.order = 0,
  });

  factory ZikrModel.fromJson(
      Map<String, dynamic> json, String category, int index) {
    int count = 1;
    try {
      count = int.parse(json['count'].toString());
    } catch (e) {
      count = 1;
    }

    return ZikrModel(
      id: '${category}_$index',
      category: category,
      initialCount: count,
      currentCount: count,
      content: json['content'] ?? '',
      description: json['description'] ?? '',
      reference: json['reference'] ?? '',
      order: index,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'count': initialCount.toString(),
      'content': content,
      'description': description,
      'reference': reference,
      'preText': preText,
      'order': order,
    };
  }

  ZikrModel copyWith({
    String? id,
    String? category,
    int? initialCount,
    int? currentCount,
    String? content,
    String? description,
    String? reference,
    String? preText,
    int? order,
  }) {
    return ZikrModel(
      id: id ?? this.id,
      category: category ?? this.category,
      initialCount: initialCount ?? this.initialCount,
      currentCount: currentCount ?? this.currentCount,
      content: content ?? this.content,
      description: description ?? this.description,
      reference: reference ?? this.reference,
      preText: preText ?? this.preText,
      order: order ?? this.order,
    );
  }
}
