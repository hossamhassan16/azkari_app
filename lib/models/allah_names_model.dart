class AllahNameModel {
  final int id;
  final String nameAr;
  final String meaningAr;

  AllahNameModel({
    required this.id,
    required this.nameAr,
    required this.meaningAr,
  });

  factory AllahNameModel.fromJson(Map<String, dynamic> json) {
    return AllahNameModel(
      id: json['id'],
      nameAr: json['name_ar'],
      meaningAr: json['meaning_ar'],
    );
  }
}
