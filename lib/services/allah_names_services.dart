import 'dart:convert';
import 'package:azkari_app/models/allah_names_model.dart';
import 'package:flutter/services.dart';

class AllahNamesService {
  static final AllahNamesService _instance = AllahNamesService._internal();
  factory AllahNamesService() => _instance;
  AllahNamesService._internal();

  List<AllahNameModel>? _names;

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
}
