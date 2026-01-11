class DuaItemModel {
  final String id;
  final String content;
  final String reference;
  final int count;
  final int currentCount;

  DuaItemModel({
    required this.id,
    required this.content,
    this.reference = '',
    this.count = 1,
    required this.currentCount,
  });

  DuaItemModel copyWith({
    String? id,
    String? content,
    String? reference,
    int? count,
    int? currentCount,
  }) {
    return DuaItemModel(
      id: id ?? this.id,
      content: content ?? this.content,
      reference: reference ?? this.reference,
      count: count ?? this.count,
      currentCount: currentCount ?? this.currentCount,
    );
  }
}
