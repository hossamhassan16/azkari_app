import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/surah_model.dart';
import '../models/ayah_model.dart';

class QuranApiService {
  static final QuranApiService _instance = QuranApiService._internal();
  factory QuranApiService() => _instance;
  QuranApiService._internal();

  List<SurahModel>? _cachedSurahs;
  List<AyahModel>? _cachedAyahs;

  /// -------------------------------
  /// Load ALL Quran data from local JSON
  /// -------------------------------
  Future<void> _loadQuranData() async {
    if (_cachedSurahs != null && _cachedAyahs != null) {
      return; // Already loaded
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/data/quran.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List surahsJson = data['data']['surahs'];

      List<SurahModel> allSurahs = [];
      List<AyahModel> allAyahs = [];

      for (final surahData in surahsJson) {
        final surah = SurahModel(
          number: surahData['number'],
          name: surahData['englishName'],
          arabicName: surahData['name'],
          revelationType: surahData['revelationType'] == 'Meccan' ? 'مكية' : 'مدنية',
          numberOfVerses: (surahData['ayahs'] as List).length,
        );
        allSurahs.add(surah);

        for (final ayahData in surahData['ayahs']) {
          allAyahs.add(
            AyahModel(
              number: ayahData['numberInSurah'],
              text: ayahData['text'],
              surahNumber: surah.number,
              surahName: surah.arabicName,
              juz: ayahData['juz'],
            ),
          );
        }
      }

      _cachedSurahs = allSurahs;
      _cachedAyahs = allAyahs;
    } catch (e) {
      throw Exception('Failed to load Quran data: $e');
    }
  }

  /// -------------------------------
  /// Get all surahs (METADATA ONLY)
  /// -------------------------------
  Future<List<SurahModel>> getAllSurahs() async {
    await _loadQuranData();
    return _cachedSurahs!;
  }

  /// -------------------------------
  /// Get ayahs of a specific surah
  /// -------------------------------
  Future<List<AyahModel>> getSurahAyahs(int surahNumber) async {
    await _loadQuranData();
    return _cachedAyahs!
        .where((ayah) => ayah.surahNumber == surahNumber)
        .toList();
  }

  /// -------------------------------
  /// Get ayahs of a juz
  /// -------------------------------
  Future<List<AyahModel>> getJuzAyahs(int juzNumber) async {
    await _loadQuranData();
    return _cachedAyahs!.where((ayah) => ayah.juz == juzNumber).toList();
  }

  /// -------------------------------
  /// Normalize Arabic text for search
  /// Remove tashkeel, Alif Khanjariyah (ٰ), and normalize characters
  /// -------------------------------
  String _normalizeArabicText(String text) {
    // Remove tashkeel (diacritics) and Alif Khanjariyah (ٰ - \u0670)
    final tashkeelRegex = RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]');
    String normalized = text.replaceAll(tashkeelRegex, '');

    // Remove extra spaces and trim
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Normalize different forms of Alif
    normalized = normalized
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ٱ', 'ا') // Alif wasla
        .replaceAll('\u0671', 'ا') // Alif wasla
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll('ئ', 'ي')
        .replaceAll('ؤ', 'و');

    // Remove Zero Width characters
    normalized = normalized.replaceAll('\ufeff', ''); // BOM
    normalized = normalized.replaceAll('\u200D', ''); // Zero width joiner
    normalized = normalized.replaceAll('\u200C', ''); // Zero width non-joiner

    return normalized.toLowerCase();
  }

  /// -------------------------------
  /// Search verses - finds any phrase anywhere in any ayah
  /// -------------------------------
  Future<List<AyahModel>> searchVerses(String query) async {
    if (query.trim().isEmpty) return [];

    await _loadQuranData();

    final normalizedQuery = _normalizeArabicText(query);
    
    return _cachedAyahs!.where((ayah) {
      final normalizedAyahText = _normalizeArabicText(ayah.text);
      return normalizedAyahText.contains(normalizedQuery);
    }).toList();
  }

  /// -------------------------------
  /// Search surahs by name
  /// -------------------------------
  Future<List<SurahModel>> searchSurahs(String query) async {
    await _loadQuranData();
    
    if (query.trim().isEmpty) return _cachedSurahs!;

    final normalizedQuery = _normalizeArabicText(query);

    return _cachedSurahs!.where((surah) {
      final normalizedArabicName = _normalizeArabicText(surah.arabicName);
      final normalizedEnglishName = surah.name.toLowerCase();
      return normalizedArabicName.contains(normalizedQuery) ||
          normalizedEnglishName.contains(normalizedQuery.toLowerCase()) ||
          surah.number.toString() == query;
    }).toList();
  }

  /// -------------------------------
  /// Search juzs by number
  /// -------------------------------
  List<int> searchJuzs(String query) {
    if (query.isEmpty) return List.generate(30, (i) => i + 1);
    final int? juzNumber = int.tryParse(query);
    if (juzNumber != null && juzNumber >= 1 && juzNumber <= 30) {
      return [juzNumber];
    }
    return [];
  }
}
