class HamdModel {
  final String id;
  final String content;
  final String reference;
  final int initialCount;
  final int currentCount;

  HamdModel({
    required this.id,
    required this.content,
    required this.reference,
    this.initialCount = 1,
    required this.currentCount,
  });

  factory HamdModel.fromJson(String duaText, int index) {
    // Parse the dua text to extract content and reference
    // Format: "- (dua content) surah - ayah"
    final cleanText = duaText.trim();

    // Remove leading "- " if exists
    String text =
        cleanText.startsWith('- ') ? cleanText.substring(2) : cleanText;

    // Extract content between parentheses and reference after
    String content = '';
    String reference = '';

    final firstParen = text.indexOf('(');
    final lastParen = text.lastIndexOf(')');

    if (firstParen != -1 && lastParen != -1) {
      content = text.substring(firstParen + 1, lastParen);
      if (lastParen + 1 < text.length) {
        reference = text.substring(lastParen + 1).trim();
      }
    } else {
      content = text;
    }

    return HamdModel(
      id: 'hamd_$index',
      content: content,
      reference: reference,
      initialCount: 1,
      currentCount: 1,
    );
  }

  factory HamdModel.fromSavedJson(Map<String, dynamic> json) {
    return HamdModel(
      id: json['id'],
      content: json['content'],
      reference: json['reference'],
      initialCount: json['initialCount'] ?? 1,
      currentCount: json['currentCount'] ?? json['initialCount'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'reference': reference,
      'initialCount': initialCount,
      'currentCount': currentCount,
    };
  }

  HamdModel copyWith({
    String? id,
    String? content,
    String? reference,
    int? initialCount,
    int? currentCount,
  }) {
    return HamdModel(
      id: id ?? this.id,
      content: content ?? this.content,
      reference: reference ?? this.reference,
      initialCount: initialCount ?? this.initialCount,
      currentCount: currentCount ?? this.currentCount,
    );
  }
}
