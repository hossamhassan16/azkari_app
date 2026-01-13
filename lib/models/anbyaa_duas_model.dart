class AnbyaaDuaModel {
  final String id;
  final String content;
  final String reference;
  final String prophetName;
  final int initialCount;
  final int currentCount;

  AnbyaaDuaModel({
    required this.id,
    required this.content,
    required this.reference,
    required this.prophetName,
    this.initialCount = 1,
    required this.currentCount,
  });

  /// Used when loading from assets JSON (array of strings)
  factory AnbyaaDuaModel.fromJson(String rawText, int index) {
    String text = rawText.trim();

    // Remove "- " at the beginning if exists
    if (text.startsWith('- ')) {
      text = text.substring(2);
    }

    // Split by new line to extract prophet name
    final parts = text.split('\n');

    final mainLine = parts.first.trim(); // dua + reference
    final prophetName = parts.length > 1 ? parts.last.trim() : '';

    // Extract dua content inside parentheses
    String content = '';
    String reference = '';

    final start = mainLine.indexOf('(');
    final end = mainLine.lastIndexOf(')');

    if (start != -1 && end != -1) {
      content = mainLine.substring(start + 1, end).trim();
      reference = mainLine.substring(end + 1).trim();
    } else {
      content = mainLine;
    }

    return AnbyaaDuaModel(
      id: 'anbyaa_dua_$index',
      content: content,
      reference: reference,
      prophetName: prophetName,
      initialCount: 1,
      currentCount: 1,
    );
  }

  /// Used when loading saved data (Hive / SharedPreferences / Firestore)
  factory AnbyaaDuaModel.fromSavedJson(Map<String, dynamic> json) {
    return AnbyaaDuaModel(
      id: json['id'],
      content: json['content'],
      reference: json['reference'],
      prophetName: json['prophetName'],
      initialCount: json['initialCount'] ?? 1,
      currentCount: json['currentCount'] ?? json['initialCount'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'reference': reference,
      'prophetName': prophetName,
      'initialCount': initialCount,
      'currentCount': currentCount,
    };
  }

  AnbyaaDuaModel copyWith({
    String? id,
    String? content,
    String? reference,
    String? prophetName,
    int? initialCount,
    int? currentCount,
  }) {
    return AnbyaaDuaModel(
      id: id ?? this.id,
      content: content ?? this.content,
      reference: reference ?? this.reference,
      prophetName: prophetName ?? this.prophetName,
      initialCount: initialCount ?? this.initialCount,
      currentCount: currentCount ?? this.currentCount,
    );
  }
}
