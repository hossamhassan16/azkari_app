import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/nawawi_hadith_model.dart';

class NawawiHadithService {
  static final NawawiHadithService _instance = NawawiHadithService._internal();
  factory NawawiHadithService() => _instance;
  NawawiHadithService._internal();

  List<NawawiHadithModel>? _cachedHadiths;

  Future<List<NawawiHadithModel>> loadHadiths() async {
    if (_cachedHadiths != null) {
      return _cachedHadiths!;
    }

    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/40-hadith-nawawi.json');
      final List<dynamic> data = json.decode(jsonString);

      _cachedHadiths = data
          .asMap()
          .entries
          .map((entry) => NawawiHadithModel.fromJson(
              entry.value as Map<String, dynamic>, entry.key))
          .toList();

      return _cachedHadiths!;
    } catch (e) {
      throw Exception('Failed to load hadiths: $e');
    }
  }

  void clearCache() {
    _cachedHadiths = null;
  }
}
