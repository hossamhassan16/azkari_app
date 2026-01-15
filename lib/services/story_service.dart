import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/story_model.dart';

class StoryService {
  static const String _storiesKey = 'daily_stories';
  static const String _viewedStoriesKey = 'viewed_stories';
  
  // Singleton
  static final StoryService _instance = StoryService._internal();
  factory StoryService() => _instance;
  StoryService._internal();

  final Random _random = Random();
  List<StoryModel> _stories = [];
  Set<String> _viewedStories = {};

  // Initialize stories (call this in main.dart)
  Future<void> init() async {
    await _loadViewedStories();
    await _loadOrGenerateStories();
  }

  // Get all stories sorted (viewed at end)
  List<StoryModel> getStories() {
    final unviewed = _stories.where((s) => !s.isViewed).toList();
    final viewed = _stories.where((s) => s.isViewed).toList();
    return [...unviewed, ...viewed];
  }

  // Mark story as viewed
  Future<void> markAsViewed(String storyId) async {
    _viewedStories.add(storyId);
    
    // Update story model
    final index = _stories.indexWhere((s) => s.id == storyId);
    if (index != -1) {
      _stories[index] = _stories[index].copyWith(isViewed: true);
    }
    
    await _saveViewedStories();
  }

  // Check if 24 hours passed
  bool _shouldRefreshStory(DateTime lastUpdated) {
    final now = DateTime.now();
    final diff = now.difference(lastUpdated);
    return diff.inHours >= 24;
  }

  // Load or generate stories
  Future<void> _loadOrGenerateStories() async {
    final prefs = await SharedPreferences.getInstance();
    final storiesJson = prefs.getString(_storiesKey);

    if (storiesJson != null) {
      // Load existing stories
      final List<dynamic> decoded = json.decode(storiesJson);
      _stories = decoded.map((s) => StoryModel.fromJson(s)).toList();
      
      // Check if any story needs refresh (24h passed)
      bool needsUpdate = false;
      for (int i = 0; i < _stories.length; i++) {
        if (_shouldRefreshStory(_stories[i].lastUpdated)) {
          // Generate new content for this story
          _stories[i] = await _generateStoryForType(
            _stories[i].type,
            'story_${_stories[i].type.index}_$i',
          );
          needsUpdate = true;
        } else {
          // Update viewed status
          _stories[i] = _stories[i].copyWith(
            isViewed: _viewedStories.contains(_stories[i].id),
          );
        }
      }
      
      if (needsUpdate) {
        await _saveStories();
      }
    } else {
      // Generate new stories (3 of each type)
      await _generateAllStories();
    }
  }

  // Generate all 9 stories (NO DUPLICATES)
  Future<void> _generateAllStories() async {
    _stories = [];
    
    // Generate 3 UNIQUE Hadith stories
    final hadiths = await _generate3UniqueStories(StoryType.hadith);
    _stories.addAll(hadiths);
    
    // Generate 3 UNIQUE Duaa stories
    final duas = await _generate3UniqueStories(StoryType.duaa);
    _stories.addAll(duas);
    
    // Generate 3 UNIQUE Ayah stories
    final ayahs = await _generate3UniqueStories(StoryType.ayah);
    _stories.addAll(ayahs);
    
    await _saveStories();
  }

  // Generate 3 unique stories of same type (no duplicates)
  Future<List<StoryModel>> _generate3UniqueStories(StoryType type) async {
    final stories = <StoryModel>[];
    final usedIndices = <int>{};
    
    try {
      // Load all items for this type
      final allItems = await _loadAllItemsForType(type);
      
      if (allItems.isEmpty) {
        // Fallback to default stories
        for (int i = 0; i < 3; i++) {
          stories.add(_createDefaultStory('story_${type.name}_$i', type));
        }
        return stories;
      }
      
      // Pick 3 unique random items
      for (int i = 0; i < 3; i++) {
        int randomIndex;
        int attempts = 0;
        
        // Find unused index (max 50 attempts to avoid infinite loop)
        do {
          randomIndex = _random.nextInt(allItems.length);
          attempts++;
        } while (usedIndices.contains(randomIndex) && attempts < 50);
        
        usedIndices.add(randomIndex);
        
        // Create story from selected item
        final item = allItems[randomIndex];
        stories.add(await _createStoryFromItem(
          'story_${type.name}_$i',
          type,
          item,
        ));
      }
    } catch (e) {
      // Fallback to default stories
      for (int i = 0; i < 3; i++) {
        stories.add(_createDefaultStory('story_${type.name}_$i', type));
      }
    }
    
    return stories;
  }

  // Load all items for a specific type
  Future<List<dynamic>> _loadAllItemsForType(StoryType type) async {
    switch (type) {
      case StoryType.hadith:
        final jsonString = await rootBundle.loadString('assets/data/hadiths.json');
        return json.decode(jsonString) as List<dynamic>;
      
      case StoryType.duaa:
        final jsonString = await rootBundle.loadString('assets/data/duas_quran.json');
        return json.decode(jsonString) as List<dynamic>;
      
      case StoryType.ayah:
        final jsonString = await rootBundle.loadString('assets/data/quran.json');
        final Map<String, dynamic> quranData = json.decode(jsonString);
        final List<dynamic> surahs = quranData['surahs'] ?? quranData['data'] ?? [];
        
        // Flatten all ayahs from all surahs
        final allAyahs = <Map<String, dynamic>>[];
        for (final surah in surahs) {
          final surahName = surah['name'] ?? surah['englishName'] ?? '';
          final List<dynamic> ayahs = surah['ayahs'] ?? surah['verses'] ?? [];
          
          for (final ayah in ayahs) {
            allAyahs.add({
              'text': ayah['text'] ?? ayah['content'] ?? '',
              'surahName': surahName,
              'ayahNumber': ayah['numberInSurah'] ?? ayah['number'] ?? '',
            });
          }
        }
        return allAyahs;
    }
  }

  // Create story from loaded item
  Future<StoryModel> _createStoryFromItem(
    String id,
    StoryType type,
    dynamic item,
  ) async {
    String content = '';
    String title = '';
    IconData icon;
    
    switch (type) {
      case StoryType.hadith:
        content = item['text'] ?? item['content'] ?? '';
        title = 'حديث اليوم';
        icon = Icons.menu_book;
        break;
      
      case StoryType.duaa:
        content = item['text'] ?? item['content'] ?? '';
        title = 'دعاء اليوم';
        icon = Icons.pan_tool_alt;
        break;
      
      case StoryType.ayah:
        content = item['text'] ?? '';
        final surahName = item['surahName'] ?? '';
        final ayahNumber = item['ayahNumber'] ?? '';
        title = 'آية اليوم - $surahName ($ayahNumber)';
        icon = Icons.chrome_reader_mode;
        break;
    }
    
    return StoryModel(
      id: id,
      type: type,
      title: title,
      content: content,
      icon: icon,
      lastUpdated: DateTime.now(),
      isViewed: _viewedStories.contains(id),
    );
  }

  // Generate a single story for a specific type (for 24h refresh)
  Future<StoryModel> _generateStoryForType(StoryType type, String id) async {
    // When refreshing a single story, just pick one random item
    try {
      final allItems = await _loadAllItemsForType(type);
      if (allItems.isEmpty) {
        return _createDefaultStory(id, type);
      }
      
      final randomItem = allItems[_random.nextInt(allItems.length)];
      return await _createStoryFromItem(id, type, randomItem);
    } catch (e) {
      return _createDefaultStory(id, type);
    }
  }

  // Create default story (fallback)
  StoryModel _createDefaultStory(String id, StoryType type) {
    String content = '';
    String title = '';
    IconData icon;
    
    switch (type) {
      case StoryType.hadith:
        title = 'حديث اليوم';
        content = 'قَالَ رَسُولُ اللَّهِ صَلَّى اللهُ عَلَيْهِ وَسَلَّمَ: "إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ"';
        icon = Icons.menu_book;
        break;
      case StoryType.duaa:
        title = 'دعاء اليوم';
        content = 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ';
        icon = Icons.pan_tool_alt;
        break;
      case StoryType.ayah:
        title = 'آية اليوم';
        content = 'وَقُل رَّبِّ زِدْنِي عِلْمًا';
        icon = Icons.chrome_reader_mode;
        break;
    }
    
    return StoryModel(
      id: id,
      type: type,
      title: title,
      content: content,
      icon: icon,
      lastUpdated: DateTime.now(),
      isViewed: _viewedStories.contains(id),
    );
  }

  // Save stories to local storage
  Future<void> _saveStories() async {
    final prefs = await SharedPreferences.getInstance();
    final storiesJson = json.encode(_stories.map((s) => s.toJson()).toList());
    await prefs.setString(_storiesKey, storiesJson);
  }

  // Load viewed stories
  Future<void> _loadViewedStories() async {
    final prefs = await SharedPreferences.getInstance();
    final viewedJson = prefs.getString(_viewedStoriesKey);
    if (viewedJson != null) {
      final List<dynamic> decoded = json.decode(viewedJson);
      _viewedStories = Set<String>.from(decoded);
    }
  }

  // Save viewed stories
  Future<void> _saveViewedStories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_viewedStoriesKey, json.encode(_viewedStories.toList()));
  }

  // Force refresh all stories (for testing)
  Future<void> forceRefresh() async {
    await _generateAllStories();
  }
}
