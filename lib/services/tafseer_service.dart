import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tafseer_model.dart';

class TafseerService {
  static const String baseUrl = 'http://api.quran-tafseer.com';

  static final TafseerService _instance = TafseerService._internal();
  factory TafseerService() => _instance;
  TafseerService._internal();

  List<TafseerInfo>? _cachedTafseerList;

  /// Get list of all available tafseers
  Future<List<TafseerInfo>> getAllTafseers() async {
    if (_cachedTafseerList != null) {
      return _cachedTafseerList!;
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/tafseer'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _cachedTafseerList = data
            .map((item) => TafseerInfo.fromJson(item))
            .where(
                (tafseer) => tafseer.language == 'ar') // Only Arabic tafseers
            .toList();
        return _cachedTafseerList!;
      } else {
        throw Exception('Failed to load tafseers');
      }
    } catch (e) {
      throw Exception('Error loading tafseers: $e');
    }
  }

  /// Get tafseer for specific ayah
  Future<TafseerContent> getTafseerForAyah({
    required int tafseerId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tafseer/$tafseerId/$surahNumber/$ayahNumber'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TafseerContent.fromJson(data);
      } else {
        throw Exception('Failed to load tafseer');
      }
    } catch (e) {
      throw Exception('Error loading tafseer: $e');
    }
  }
}
