class Moshaf {
  final int id;
  final String name;
  final String server;
  final List<int> surahList; // حولناها لقائمة أرقام لسهولة التعامل

  Moshaf(
      {required this.id,
      required this.name,
      required this.server,
      required this.surahList});

  factory Moshaf.fromJson(Map<String, dynamic> json) {
    // السور تأتي كنص "1,2,3" ونحن نحولها لـ List<int>
    var surahs = (json['surah_list'] as String)
        .split(',')
        .map((e) => int.parse(e))
        .toList();

    return Moshaf(
      id: json['id'],
      name: json['name'],
      server: json['server'],
      surahList: surahs,
    );
  }
  String getSurahUrl(int surahNumber) {
    // السيرفر يأتي هكذا: https://server.com/
    // ونريد إضافة: 001.mp3
    String formattedNumber = surahNumber.toString().padLeft(3, '0');
    return "$server$formattedNumber.mp3";
  }
}

class QuranReaderModel {
  final int id;
  final String name;
  final List<Moshaf> moshaf;

  QuranReaderModel(
      {required this.id, required this.name, required this.moshaf});

  factory QuranReaderModel.fromJson(Map<String, dynamic> json) {
    var moshafList =
        (json['moshaf'] as List).map((m) => Moshaf.fromJson(m)).toList();

    return QuranReaderModel(
      id: json['id'],
      name: json['name'],
      moshaf: moshafList,
    );
  }
}
