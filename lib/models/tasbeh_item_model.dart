class TasbehItemModel {
  final String id;
  final String name;
  final int beadsCount;
  final String benefit;
  int currentCount;
  int cycleCount;
  int totalCount;

  TasbehItemModel({
    required this.id,
    required this.name,
    required this.beadsCount,
    this.benefit = '',
    this.currentCount = 0,
    this.cycleCount = 0,
    this.totalCount = 0,
  });

  factory TasbehItemModel.fromJson(Map<String, dynamic> json) {
    return TasbehItemModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      beadsCount: json['beadsCount'] ?? 33,
      benefit: json['benefit'] ?? '',
      currentCount: json['currentCount'] ?? 0,
      cycleCount: json['cycleCount'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'beadsCount': beadsCount,
      'benefit': benefit,
      'currentCount': currentCount,
      'cycleCount': cycleCount,
      'totalCount': totalCount,
    };
  }

  TasbehItemModel copyWith({
    String? id,
    String? name,
    int? beadsCount,
    String? benefit,
    int? currentCount,
    int? cycleCount,
    int? totalCount,
  }) {
    return TasbehItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      beadsCount: beadsCount ?? this.beadsCount,
      benefit: benefit ?? this.benefit,
      currentCount: currentCount ?? this.currentCount,
      cycleCount: cycleCount ?? this.cycleCount,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}
