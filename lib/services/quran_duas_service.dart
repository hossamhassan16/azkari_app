import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quran_dua_model.dart';

class QuranDuasService {
  static final QuranDuasService _instance = QuranDuasService._internal();
  factory QuranDuasService() => _instance;
  QuranDuasService._internal();

  List<QuranDuaModel>? _cachedDuas;
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<QuranDuaModel>> loadQuranDuas() async {
    if (_cachedDuas != null) {
      return _cachedDuas!;
    }

    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/duas_quran.json');
      final Map<String, dynamic> data = json.decode(jsonString);

      final List<dynamic> duasList = data['duas'] as List<dynamic>;
      _cachedDuas = duasList
          .asMap()
          .entries
          .map((entry) => QuranDuaModel.fromJson(entry.value.toString(), entry.key))
          .toList();

      // Load counter progress
      await _loadProgress();

      return _cachedDuas!;
    } catch (e) {
      throw Exception('Failed to load Quran duas: $e');
    }
  }

  Future<void> _loadProgress() async {
    if (_cachedDuas == null) return;

    for (int i = 0; i < _cachedDuas!.length; i++) {
      final dua = _cachedDuas![i];
      final key = 'quran_dua_progress_${dua.id}';
      final savedCount = _prefs?.getInt(key);
      if (savedCount != null) {
        _cachedDuas![i] = dua.copyWith(currentCount: savedCount);
      }
    }
  }

  Future<void> saveProgress(String duaId, int count) async {
    final key = 'quran_dua_progress_$duaId';
    await _prefs?.setInt(key, count);

    // Update in cache
    if (_cachedDuas != null) {
      for (int i = 0; i < _cachedDuas!.length; i++) {
        if (_cachedDuas![i].id == duaId) {
          _cachedDuas![i] = _cachedDuas![i].copyWith(currentCount: count);
          break;
        }
      }
    }
  }

  Future<void> resetDua(String duaId) async {
    if (_cachedDuas == null) return;

    for (int i = 0; i < _cachedDuas!.length; i++) {
      if (_cachedDuas![i].id == duaId) {
        final dua = _cachedDuas![i];
        _cachedDuas![i] = dua.copyWith(currentCount: dua.initialCount);
        final key = 'quran_dua_progress_${dua.id}';
        await _prefs?.setInt(key, dua.initialCount);
        break;
      }
    }
  }

  // Get saved "My Azkar" duas
  Future<List<QuranDuaModel>> getMyAzkar() async {
    final myAzkarJson = _prefs?.getString('my_azkar_duas');
    if (myAzkarJson == null) return [];

    final List<dynamic> duasList = json.decode(myAzkarJson);
    return duasList.map((duaJson) => QuranDuaModel.fromSavedJson(duaJson)).toList();
  }

  // Add dua to "My Azkar"
  Future<void> addToMyAzkar(QuranDuaModel dua) async {
    final currentList = await getMyAzkar();
    
    // Check if already exists
    if (currentList.any((d) => d.id == dua.id)) {
      return; // Already added
    }

    currentList.add(dua);
    final jsonString = json.encode(currentList.map((d) => d.toJson()).toList());
    await _prefs?.setString('my_azkar_duas', jsonString);
  }

  // Remove dua from "My Azkar"
  Future<void> removeFromMyAzkar(String duaId) async {
    final currentList = await getMyAzkar();
    currentList.removeWhere((d) => d.id == duaId);
    
    final jsonString = json.encode(currentList.map((d) => d.toJson()).toList());
    await _prefs?.setString('my_azkar_duas', jsonString);
  }

  // Save progress for My Azkar duas
  Future<void> saveMyAzkarProgress(String duaId, int count) async {
    final currentList = await getMyAzkar();
    
    for (int i = 0; i < currentList.length; i++) {
      if (currentList[i].id == duaId) {
        currentList[i] = currentList[i].copyWith(currentCount: count);
        break;
      }
    }
    
    final jsonString = json.encode(currentList.map((d) => d.toJson()).toList());
    await _prefs?.setString('my_azkar_duas', jsonString);
  }

  // Check if dua is in "My Azkar"
  Future<bool> isInMyAzkar(String duaId) async {
    final currentList = await getMyAzkar();
    return currentList.any((d) => d.id == duaId);
  }

  void clearCache() {
    _cachedDuas = null;
  }
}
