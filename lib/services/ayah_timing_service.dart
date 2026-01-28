import 'dart:convert';
import 'package:http/http.dart' as http;

class AyahTimingService {
  Future<List<Duration>> fetchAyahTimings({
    required int surahNumber,
    required int readerId,
  }) async {
    final url =
        'https://www.mp3quran.net/api/v3/ayat_timing?surah=$surahNumber&read=$readerId';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to load ayah timings');
    }

    final data = jsonDecode(response.body);
    final List ayat = data;

    return ayat
        .map<Duration>((e) => Duration(milliseconds: e['start_time'] as int))
        .toList();
  }
}
