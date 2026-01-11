class AyahModel {
  final int number;
  final String text;
  final int surahNumber;
  final String surahName;
  final int juz;
  final bool isSaved;

  AyahModel({
    required this.number,
    required this.text,
    required this.surahNumber,
    required this.surahName,
    required this.juz,
    this.isSaved = false,
  });

  AyahModel copyWith({
    int? number,
    String? text,
    int? surahNumber,
    String? surahName,
    int? juz,
    bool? isSaved,
  }) {
    return AyahModel(
      number: number ?? this.number,
      text: text ?? this.text,
      surahNumber: surahNumber ?? this.surahNumber,
      surahName: surahName ?? this.surahName,
      juz: juz ?? this.juz,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

