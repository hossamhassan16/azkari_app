class SurahModel {
  final int number;
  final String name;
  final String arabicName;
  final String revelationType; // مكية or مدنية
  final int numberOfVerses;
  final int? juz;

  SurahModel({
    required this.number,
    required this.name,
    required this.arabicName,
    required this.revelationType,
    required this.numberOfVerses,
    this.juz,
  });
}

