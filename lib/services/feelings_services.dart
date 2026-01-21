import 'dart:convert';
import 'package:azkari_app/models/feelings_model.dart';
import 'package:flutter/services.dart';

class FeelingsService {
  static final FeelingsService _instance = FeelingsService._internal();
  factory FeelingsService() => _instance;
  FeelingsService._internal();

  List<FeelingModel>? _feelings;

  Future<List<FeelingModel>> loadFeelings() async {
    if (_feelings != null) return _feelings!;

    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/duas_by_feelings.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      _feelings = jsonData.map((json) => FeelingModel.fromJson(json)).toList();
      return _feelings!;
    } catch (e) {
      print('Error loading feelings: $e');
      return [];
    }
  }
}
