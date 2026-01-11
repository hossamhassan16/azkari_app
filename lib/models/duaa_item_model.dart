class DuaItemModel {
  final String id;
  final String content;
  final int initialCount;
  final int currentCount;

  DuaItemModel({
    required this.id,
    required this.content,
    this.initialCount = 1,
    required this.currentCount,
  });

  DuaItemModel copyWith({
    String? id,
    String? content,
    int? initialCount,
    int? currentCount,
  }) {
    return DuaItemModel(
      id: id ?? this.id,
      content: content ?? this.content,
      initialCount: initialCount ?? this.initialCount,
      currentCount: currentCount ?? this.currentCount,
    );
  }
}
