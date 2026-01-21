import 'dart:convert';
import 'package:flutter/services.dart';

class RamadanRepository {
  Future<List<String>> getDetailsByTitle(String title) async {
    final jsonString = await rootBundle.loadString('assets/data/ramadan.json');

    final Map<String, dynamic> data = json.decode(jsonString);

    return List<String>.from(data[title] ?? []);
  }
}
