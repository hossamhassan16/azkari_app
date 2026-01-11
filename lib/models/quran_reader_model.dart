class QuranReaderModel {
  final String id;
  final String name;
  final String language;

  QuranReaderModel({
    required this.id,
    required this.name,
    required this.language,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuranReaderModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
