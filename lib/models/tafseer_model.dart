class TafseerInfo {
  final int id;
  final String name;
  final String language;
  final String author;
  final String bookName;

  TafseerInfo({
    required this.id,
    required this.name,
    required this.language,
    required this.author,
    required this.bookName,
  });

  factory TafseerInfo.fromJson(Map<String, dynamic> json) {
    return TafseerInfo(
      id: json['id'],
      name: json['name'],
      language: json['language'],
      author: json['author'],
      bookName: json['book_name'],
    );
  }
}

class TafseerContent {
  final int tafseerId;
  final String tafseerName;
  final String ayahUrl;
  final int ayahNumber;
  final String text;

  TafseerContent({
    required this.tafseerId,
    required this.tafseerName,
    required this.ayahUrl,
    required this.ayahNumber,
    required this.text,
  });

  factory TafseerContent.fromJson(Map<String, dynamic> json) {
    return TafseerContent(
      tafseerId: json['tafseer_id'],
      tafseerName: json['tafseer_name'],
      ayahUrl: json['ayah_url'],
      ayahNumber: json['ayah_number'],
      text: json['text'],
    );
  }
}
