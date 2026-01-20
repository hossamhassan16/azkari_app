import 'dart:convert';
import 'dart:math';

import 'package:azkari_app/models/allah_names_model.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllahNamesService {
  static final AllahNamesService _instance = AllahNamesService._internal();
  factory AllahNamesService() => _instance;
  AllahNamesService._internal();

  List<AllahNameModel>? _names;

  static const String _cacheKey = 'daily_allah_name';
  static const String _dateKey = 'daily_allah_name_date';

  /// Load all names from JSON (cached in memory)
  Future<List<AllahNameModel>> loadNames() async {
    if (_names != null) return _names!;

    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/asmaa_allah_alhusna.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      _names = jsonData.map((json) => AllahNameModel.fromJson(json)).toList();
      return _names!;
    } catch (e) {
      print('Error loading Allah names: $e');
      return [];
    }
  }

  /// ✅ Get ONE random name per 24 hours
  Future<AllahNameModel?> getDailyRandomName() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final cachedDate = prefs.getString(_dateKey);
    final cachedData = prefs.getString(_cacheKey);

    // ✅ Return cached value if same day
    if (cachedDate == today && cachedData != null) {
      return AllahNameModel.fromJson(json.decode(cachedData));
    }

    // 🔄 Load all names
    final names = await loadNames();
    if (names.isEmpty) return null;

    // 🎯 Pick random
    final random = Random();
    final selected = names[random.nextInt(names.length)];

    // 💾 Save for 24 hours
    await prefs.setString(_dateKey, today);
    await prefs.setString(
      _cacheKey,
      json.encode({
        'id': selected.id,
        'name_ar': selected.nameAr,
        'meaning_ar': selected.meaningAr,
      }),
    );

    return selected;
  }
}
