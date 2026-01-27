import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quran_reader_model.dart';

class ReadersService {
  static const String apiUrl =
      "https://www.mp3quran.net/api/v3/reciters?language=ar";

  Future<List<QuranReaderModel>> fetchReciters() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> recitersJson = data['reciters'];
        return recitersJson
            .map((json) => QuranReaderModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load reciters');
      }
    } catch (e) {
      print("Error fetching data: $e");
      return [];
    }
  }
}
