// import 'zikr_model.dart';

// class AzkarCategoryModel {
//   final String name;
//   final List<ZikrModel> azkar;
//   final bool isCustom;

//   AzkarCategoryModel({
//     required this.name,
//     required this.azkar,
//     this.isCustom = false,
//   });

//   factory AzkarCategoryModel.fromJson(String categoryName, dynamic json) {
//     List<ZikrModel> azkarList = [];

//     if (json is List) {
//       // Handle both list and nested list structures
//       int index = 0;
//       for (var item in json) {
//         if (item is List) {
//           // Nested list
//           for (var nestedItem in item) {
//             if (nestedItem is Map<String, dynamic> &&
//                 nestedItem['category'] != 'stop') {
//               azkarList
//                   .add(ZikrModel.fromJson(nestedItem, categoryName, index++));
//             }
//           }
//         } else if (item is Map<String, dynamic> && item['category'] != 'stop') {
//           azkarList.add(ZikrModel.fromJson(item, categoryName, index++));
//         }
//       }
//     }

//     return AzkarCategoryModel(
//       name: categoryName,
//       azkar: azkarList,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'azkar': azkar.map((z) => z.toJson()).toList(),
//       'isCustom': isCustom,
//     };
//   }

//   int get totalProgress {
//     if (azkar.isEmpty) return 0;
//     int completed = azkar.where((z) => z.currentCount == 0).length;
//     return ((completed / azkar.length) * 100).round();
//   }

//   bool get isCompleted => azkar.every((z) => z.currentCount == 0);
// }

import 'zikr_model.dart';

class AzkarCategoryModel {
  final String name;
  final List<ZikrModel> azkar;
  final bool isCustom;

  AzkarCategoryModel({
    required this.name,
    required this.azkar,
    this.isCustom = false,
  });

  factory AzkarCategoryModel.fromJson(String categoryName, dynamic json) {
    List<ZikrModel> azkarList = [];

    if (json is List) {
      // Handle both list and nested list structures
      int index = 0;
      for (var item in json) {
        if (item is List) {
          // Nested list
          for (var nestedItem in item) {
            if (nestedItem is Map<String, dynamic> &&
                nestedItem['category'] != 'stop') {
              azkarList
                  .add(ZikrModel.fromJson(nestedItem, categoryName, index++));
            }
          }
        } else if (item is Map<String, dynamic> && item['category'] != 'stop') {
          azkarList.add(ZikrModel.fromJson(item, categoryName, index++));
        }
      }
    }

    return AzkarCategoryModel(
      name: categoryName,
      azkar: azkarList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'azkar': azkar.map((z) => z.toJson()).toList(),
      'isCustom': isCustom,
    };
  }

  int get totalProgress {
    if (azkar.isEmpty) return 0;
    int completed = azkar.where((z) => z.currentCount == 0).length;
    return ((completed / azkar.length) * 100).round();
  }

  /// ✅ Added only this getter
  double get progress {
    if (azkar.isEmpty) return 0.0;
    int completed = azkar.where((z) => z.currentCount == 0).length;
    return completed / azkar.length;
  }

  bool get isCompleted => azkar.every((z) => z.currentCount == 0);
}
