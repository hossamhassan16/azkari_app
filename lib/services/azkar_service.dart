import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/azkar_category_model.dart';
import '../models/zikr_model.dart';

class AzkarService {
  static final AzkarService _instance = AzkarService._internal();
  factory AzkarService() => _instance;
  AzkarService._internal();

  SharedPreferences? _prefs;
  List<AzkarCategoryModel> _categories = [];

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<AzkarCategoryModel>> loadAzkarCategories() async {
    if (_categories.isNotEmpty) {
      return _categories;
    }

    try {
      // Load from JSON
      final String jsonString =
          await rootBundle.loadString('assets/data/azkar.json');
      final Map<String, dynamic> data = json.decode(jsonString);

      _categories = [];
      data.forEach((categoryName, categoryData) {
        _categories
            .add(AzkarCategoryModel.fromJson(categoryName, categoryData));
      });

      // Load custom categories
      await _loadCustomCategories();

      // Load progress
      await _loadProgress();

      return _categories;
    } catch (e) {
      throw Exception('Failed to load azkar: $e');
    }
  }

  Future<void> _loadCustomCategories() async {
    final customCategoriesJson = _prefs?.getString('custom_categories');
    if (customCategoriesJson != null) {
      final List<dynamic> customList = json.decode(customCategoriesJson);
      for (var categoryJson in customList) {
        _categories.add(AzkarCategoryModel(
          name: categoryJson['name'],
          azkar: (categoryJson['azkar'] as List)
              .map((z) => ZikrModel(
                    id: z['id'],
                    category: z['category'],
                    initialCount: z['count'] is int
                        ? z['count']
                        : int.parse(z['count'].toString()),
                    currentCount: z['currentCount'] ?? z['count'],
                    content: z['content'],
                    description: z['description'] ?? '',
                    reference: z['reference'] ?? '',
                    preText: z['preText'],
                    order: z['order'] ?? 0,
                  ))
              .toList(),
          isCustom: true,
        ));
      }
    }
  }

  Future<void> _loadProgress() async {
    for (var category in _categories) {
      for (int i = 0; i < category.azkar.length; i++) {
        final zikr = category.azkar[i];
        final key = 'progress_${category.name}_${zikr.id}';
        final savedCount = _prefs?.getInt(key);
        if (savedCount != null) {
          category.azkar[i] = zikr.copyWith(currentCount: savedCount);
        }
      }
    }
  }

  Future<void> saveProgress(
      String categoryName, String zikrId, int count) async {
    final key = 'progress_${categoryName}_$zikrId';
    await _prefs?.setInt(key, count);

    // Update in memory
    for (var category in _categories) {
      if (category.name == categoryName) {
        for (int i = 0; i < category.azkar.length; i++) {
          if (category.azkar[i].id == zikrId) {
            category.azkar[i] = category.azkar[i].copyWith(currentCount: count);
            break;
          }
        }
        break;
      }
    }
  }

  Future<void> resetCategory(String categoryName) async {
    for (var category in _categories) {
      if (category.name == categoryName) {
        for (int i = 0; i < category.azkar.length; i++) {
          final zikr = category.azkar[i];
          category.azkar[i] = zikr.copyWith(currentCount: zikr.initialCount);
          final key = 'progress_${categoryName}_${zikr.id}';
          await _prefs?.setInt(key, zikr.initialCount);
        }
        break;
      }
    }
  }

  Future<void> addCustomCategory(String name) async {
    final newCategory = AzkarCategoryModel(
      name: name,
      azkar: [],
      isCustom: true,
    );
    _categories.add(newCategory);
    await _saveCustomCategories();
  }

  Future<void> addCustomZikr(String categoryName, ZikrModel zikr) async {
    for (var category in _categories) {
      if (category.name == categoryName) {
        category.azkar.add(zikr);
        await _saveCustomCategories();
        break;
      }
    }
  }

  Future<void> updateZikr(String categoryName, ZikrModel zikr) async {
    for (var category in _categories) {
      if (category.name == categoryName) {
        for (int i = 0; i < category.azkar.length; i++) {
          if (category.azkar[i].id == zikr.id) {
            category.azkar[i] = zikr;
            await _saveCustomCategories();
            break;
          }
        }
        break;
      }
    }
  }

  Future<void> deleteZikr(String categoryName, String zikrId) async {
    for (var category in _categories) {
      if (category.name == categoryName) {
        category.azkar.removeWhere((z) => z.id == zikrId);
        await _saveCustomCategories();
        // Remove progress
        final key = 'progress_${categoryName}_$zikrId';
        await _prefs?.remove(key);
        break;
      }
    }
  }

  Future<void> _saveCustomCategories() async {
    final customCategories =
        _categories.where((c) => c.isCustom).map((c) => c.toJson()).toList();
    await _prefs?.setString('custom_categories', json.encode(customCategories));
  }

  AzkarCategoryModel? getCategoryByName(String name) {
    try {
      return _categories.firstWhere((c) => c.name == name);
    } catch (e) {
      return null;
    }
  }

  void clearCache() {
    _categories.clear();
  }
}
