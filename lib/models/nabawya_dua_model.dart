class NabawyaDuaModel {
  final String id;
  final String content;
  final String reference;
  final int initialCount;
  final int currentCount;

  NabawyaDuaModel({
    required this.id,
    required this.content,
    required this.reference,
    this.initialCount = 1,
    required this.currentCount,
  });

  factory NabawyaDuaModel.fromJson(String duaText, int index) {
    String text = duaText.trim();

    // Remove leading "- " if exists
    if (text.startsWith('-')) {
      text = text.substring(1).trim();
    }

    String content = text;
    String reference = '';

    // Extract last parentheses as reference
    final lastOpenParen = text.lastIndexOf('(');
    final lastCloseParen = text.lastIndexOf(')');

    if (lastOpenParen != -1 &&
        lastCloseParen != -1 &&
        lastCloseParen > lastOpenParen) {
      content = text.substring(0, lastOpenParen).trim();
      reference = text.substring(lastOpenParen + 1, lastCloseParen).trim();
    }

    return NabawyaDuaModel(
      id: 'nabawya_dua_$index',
      content: content,
      reference: reference,
      initialCount: 1,
      currentCount: 1,
    );
  }

  factory NabawyaDuaModel.fromSavedJson(Map<String, dynamic> json) {
    return NabawyaDuaModel(
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

  NabawyaDuaModel copyWith({
    String? id,
    String? content,
    String? reference,
    int? initialCount,
    int? currentCount,
  }) {
    return NabawyaDuaModel(
      id: id ?? this.id,
      content: content ?? this.content,
      reference: reference ?? this.reference,
      initialCount: initialCount ?? this.initialCount,
      currentCount: currentCount ?? this.currentCount,
    );
  }
}
