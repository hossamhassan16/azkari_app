class QuranDuaModel {
  final String id;
  final String content;
  final String reference;
  final int initialCount;
  final int currentCount;

  QuranDuaModel({
    required this.id,
    required this.content,
    required this.reference,
    this.initialCount = 1,
    required this.currentCount,
  });

  factory QuranDuaModel.fromJson(String duaText, int index) {
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

    return QuranDuaModel(
      id: 'quran_dua_$index',
      content: content,
      reference: reference,
      initialCount: 1,
      currentCount: 1,
    );
  }

  factory QuranDuaModel.fromSavedJson(Map<String, dynamic> json) {
    return QuranDuaModel(
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

  QuranDuaModel copyWith({
    String? id,
    String? content,
    String? reference,
    int? initialCount,
    int? currentCount,
  }) {
    return QuranDuaModel(
      id: id ?? this.id,
      content: content ?? this.content,
      reference: reference ?? this.reference,
      initialCount: initialCount ?? this.initialCount,
      currentCount: currentCount ?? this.currentCount,
    );
  }
}
