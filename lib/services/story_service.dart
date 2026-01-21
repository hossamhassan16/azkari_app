import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/story_model.dart';

class StoryService {
  static const String _storiesKey = 'daily_stories';
  static const String _viewedStoriesKey = 'viewed_stories';
  static const String _previousContentKey = 'previous_content';
  static const String _recentContentsKey =
      'recent_contents'; // NEW: Track recent items

  // Singleton
  static final StoryService _instance = StoryService._internal();
  factory StoryService() => _instance;
  StoryService._internal();

  final Random _random = Random();
  List<StoryModel> _stories = [];
  Set<String> _viewedStories = {};
  Map<String, String> _previousContent =
      {}; // Track previous content to avoid repetition

  // NEW: Track recent contents for each type (last 5 items to avoid)
  Map<String, List<String>> _recentContents = {
    'hadith': [],
    'duaa': [],
    'ayah': [],
  };

  // Initialize stories (call this in main.dart)
  Future<void> init() async {
    await _loadViewedStories();
    await _loadPreviousContent();
    await _loadRecentContents(); // NEW: Load recent contents
    await _loadOrGenerateStories();
  }

  // Get all stories sorted: UNVIEWED FIRST, VIEWED LAST
  List<StoryModel> getStories() {
    final unviewed = _stories.where((s) => !s.isViewed).toList();
    final viewed = _stories.where((s) => s.isViewed).toList();
    return [...unviewed, ...viewed];
  }

  // Mark story as viewed and MOVE TO END
  Future<void> markAsViewed(String storyId) async {
    _viewedStories.add(storyId);

    // Update story model
    final index = _stories.indexWhere((s) => s.id == storyId);
    if (index != -1) {
      final viewedStory = _stories[index].copyWith(isViewed: true);
      _stories.removeAt(index);
      _stories.add(viewedStory); // Move to end
    }

    await _saveViewedStories();
    await _saveStories();
  }

  // Check if 24 hours passed
  bool _shouldRefreshStory(DateTime lastUpdated) {
    final now = DateTime.now();
    final diff = now.difference(lastUpdated);
    return diff.inHours >= 24;
  }
  // bool _shouldRefreshStory(DateTime lastUpdated) {
  //   if (kDebugMode) return true; // refresh every run
  //   return DateTime.now().difference(lastUpdated).inHours >= 24;
  // }

  // Load or generate stories
  Future<void> _loadOrGenerateStories() async {
    final prefs = await SharedPreferences.getInstance();
    final storiesJson = prefs.getString(_storiesKey);

    if (storiesJson != null) {
      // Load existing stories
      final List<dynamic> decoded = json.decode(storiesJson);
      _stories = decoded.map((s) => StoryModel.fromJson(s)).toList();

      // Check each story for 24h refresh
      final refreshedStories = <StoryModel>[];
      final nonRefreshedStories = <StoryModel>[];

      for (int i = 0; i < _stories.length; i++) {
        if (_shouldRefreshStory(_stories[i].lastUpdated)) {
          // ✅ REFRESH: Generate NEW content (different from previous)
          final newStory = await _refreshStory(_stories[i]);
          refreshedStories.add(newStory);
        } else {
          // ✅ Keep existing story with updated viewed status
          final story = _stories[i].copyWith(
            isViewed: _viewedStories.contains(_stories[i].id),
          );
          nonRefreshedStories.add(story);
        }
      }

      // ✅ REORDER: Refreshed stories FIRST (unviewed), then others
      _stories = [...refreshedStories, ...nonRefreshedStories];

      if (refreshedStories.isNotEmpty) {
        await _saveStories();
      }
    } else {
      // Generate new stories (3 of each type)
      await _generateAllStories();
    }
  }

  // Refresh a single story (24h passed)
  Future<StoryModel> _refreshStory(StoryModel oldStory) async {
    try {
      final allItems = await _loadAllItemsForType(oldStory.type);

      if (allItems.isEmpty) {
        // Fallback only if JSON fails
        final fallbackIndex = _random.nextInt(3); // Use random fallback
        return _createFallbackStory(oldStory.id, oldStory.type, fallbackIndex);
      }

      // ✅ Find NEW content (different from previous AND recent)
      final previousContent = _previousContent[oldStory.id] ?? oldStory.content;
      final typePrefix = oldStory.type.name;
      final recentContents = _recentContents[typePrefix] ?? [];

      final newItem = _findDifferentItem(
        allItems,
        previousContent,
        oldStory.type,
        recentContents, // ✅ Pass recent contents to avoid
      );

      final newStory = await _createStoryFromItem(
        oldStory.id,
        oldStory.type,
        newItem,
      );

      // ✅ Save new content as "previous" for next refresh
      _previousContent[oldStory.id] = newStory.content;
      await _savePreviousContent();

      // ✅ Add to recent contents
      _addToRecentContents(typePrefix, [newStory.content]);
      await _saveRecentContents();

      // ✅ Reset isViewed to FALSE (make ring GREEN)
      _viewedStories.remove(oldStory.id);
      await _saveViewedStories();

      return newStory.copyWith(isViewed: false);
    } catch (e) {
      final fallbackIndex = _random.nextInt(3);
      return _createFallbackStory(oldStory.id, oldStory.type, fallbackIndex);
    }
  }

  // Find an item different from previous content AND recent contents
  dynamic _findDifferentItem(
      List<dynamic> allItems, String previousContent, StoryType type,
      [List<String>? recentContents]) {
    if (allItems.length == 1) {
      return allItems[0]; // Only one item available
    }

    final recents = recentContents ?? [];

    // Try to find different item (max 200 attempts)
    for (int attempt = 0; attempt < 200; attempt++) {
      final randomItem = allItems[_random.nextInt(allItems.length)];
      final itemContent = _extractContent(randomItem, type);

      // ✅ Check: Not same as previous AND not in recent contents
      if (itemContent != previousContent && !recents.contains(itemContent)) {
        if (kDebugMode) {
          print('✅ Found different item after $attempt attempts');
        }
        return randomItem; // Found different item!
      }
    }

    if (kDebugMode) {
      print(
          '⚠️ Could not find different item after 200 attempts, using random');
    }

    // Fallback: return random item (better than nothing)
    return allItems[_random.nextInt(allItems.length)];
  }

  // Extract content from item
  String _extractContent(dynamic item, StoryType type) {
    if (type == StoryType.ayah) {
      return item['text'] ?? '';
    }
    if (type == StoryType.hadith) {
      // Try hadithArabic first, then text, then content
      return item['hadithArabic'] ?? item['text'] ?? item['content'] ?? '';
    }
    return item['text'] ?? item['content'] ?? '';
  }

  // Generate all 9 stories (NO DUPLICATES)
  Future<void> _generateAllStories() async {
    _stories = [];

    // Generate 3 UNIQUE Hadith stories
    final hadiths = await _generate3UniqueStories(StoryType.hadith, 'hadith');
    _stories.addAll(hadiths);

    // Generate 3 UNIQUE Duaa stories
    final duas = await _generate3UniqueStories(StoryType.duaa, 'duaa');
    _stories.addAll(duas);

    // Generate 3 UNIQUE Ayah stories
    final ayahs = await _generate3UniqueStories(StoryType.ayah, 'ayah');
    _stories.addAll(ayahs);

    await _saveStories();
  }

  // Generate 3 unique stories of same type (no duplicates)
  Future<List<StoryModel>> _generate3UniqueStories(
      StoryType type, String typePrefix) async {
    final stories = <StoryModel>[];
    final usedIndices = <int>{};
    final usedContents = <String>{};

    // ✅ Get recent contents for this type to AVOID them
    final recentContents = _recentContents[typePrefix] ?? [];

    try {
      if (kDebugMode) {
        print('🔍 Loading $typePrefix from JSON...');
      }

      // Load all items for this type
      final allItems = await _loadAllItemsForType(type);

      if (kDebugMode) {
        print('✅ Loaded ${allItems.length} items for $typePrefix');
      }

      if (allItems.isEmpty) {
        if (kDebugMode) {
          print('⚠️ JSON is EMPTY! Using fallback for $typePrefix');
        }
        // Fallback ONLY if JSON is empty (3 UNIQUE fallbacks)
        return _create3FallbackStories(type, typePrefix);
      }

      // Pick 3 unique random items (DIFFERENT from recent ones)
      for (int i = 0; i < 3; i++) {
        int randomIndex;
        String content;
        int attempts = 0;

        // Find unused index with different content (max 200 attempts)
        do {
          randomIndex = _random.nextInt(allItems.length);
          content = _extractContent(allItems[randomIndex], type);
          attempts++;
        } while ((usedIndices.contains(randomIndex) ||
                usedContents.contains(content) ||
                recentContents.contains(content)) && // ✅ AVOID recent contents!
            attempts < 200);

        usedIndices.add(randomIndex);
        usedContents.add(content);

        // Create story from selected item
        final item = allItems[randomIndex];
        final storyId = 'story_${typePrefix}_$i';
        final story = await _createStoryFromItem(storyId, type, item);

        stories.add(story);

        // Save as previous content
        _previousContent[storyId] = story.content;
      }

      // ✅ Update recent contents for this type (keep last 5)
      _addToRecentContents(typePrefix, usedContents.toList());

      await _savePreviousContent();
      await _saveRecentContents(); // ✅ Save recent contents

      if (kDebugMode) {
        print(
            '✅ Successfully generated ${stories.length} stories for $typePrefix from JSON');
      }
    } catch (e, stackTrace) {
      // Fallback ONLY on error (3 UNIQUE fallbacks)
      if (kDebugMode) {
        print('❌ ERROR loading $typePrefix: $e');
        print('Stack trace: $stackTrace');
        print('⚠️ Using fallback stories instead');
      }
      return _create3FallbackStories(type, typePrefix);
    }

    return stories;
  }

  // Load all items for a specific type
  Future<List<dynamic>> _loadAllItemsForType(StoryType type) async {
    try {
      switch (type) {
        case StoryType.hadith:
          if (kDebugMode) {
            print('📖 Loading hadiths.json...');
          }
          final jsonString =
              await rootBundle.loadString('assets/data/hadiths.json');
          final decoded = json.decode(jsonString);

          // ✅ Handle different JSON structures
          List<dynamic> items = [];
          if (decoded is List) {
            items = decoded;
          } else if (decoded is Map) {
            // Check for nested structure: { "hadiths": { "data": [...] } }
            if (decoded['hadiths'] != null &&
                decoded['hadiths']['data'] != null) {
              items = decoded['hadiths']['data'] as List;
            } else if (decoded['data'] != null) {
              items = decoded['data'] as List;
            } else if (decoded['hadiths'] != null &&
                decoded['hadiths'] is List) {
              items = decoded['hadiths'] as List;
            }
          }

          if (kDebugMode) {
            print('✅ Loaded ${items.length} hadiths');
            if (items.isNotEmpty) {
              // Try to find the Arabic text field
              final sampleText = items[0]['hadithArabic'] ??
                  items[0]['text'] ??
                  items[0]['content'] ??
                  'No text found';
              print(
                  '📝 Sample hadith: ${sampleText.toString().substring(0, 50)}...');
            }
          }
          return items;

        case StoryType.duaa:
          if (kDebugMode) {
            print('📖 Loading duas_quran.json...');
          }
          final jsonString =
              await rootBundle.loadString('assets/data/duas_quran.json');
          final decoded = json.decode(jsonString);

          // ✅ Handle different JSON structures
          List<dynamic> items = [];
          if (decoded is List) {
            items = decoded;
          } else if (decoded is Map && decoded['duas'] != null) {
            // Structure: { "duas": ["string1", "string2", ...] }
            final duasArray = decoded['duas'];
            if (duasArray is List) {
              // Convert string array to object array
              items = duasArray
                  .map((dua) => {
                        'text': dua.toString(),
                        'content': dua.toString(),
                      })
                  .toList();
            }
          }

          if (kDebugMode) {
            print('✅ Loaded ${items.length} duas');
            if (items.isNotEmpty) {
              final sampleText = items[0] is String
                  ? items[0]
                  : (items[0]['text'] ?? items[0]['content'] ?? 'No text');
              final sampleStr = sampleText.toString();
              final len = sampleStr.length > 50 ? 50 : sampleStr.length;
              print('📝 Sample dua: ${sampleStr.substring(0, len)}...');
            }
          }
          return items;

        case StoryType.ayah:
          if (kDebugMode) {
            print('📖 Loading quran.json...');
          }
          final jsonString =
              await rootBundle.loadString('assets/data/quran.json');
          final Map<String, dynamic> quranData = json.decode(jsonString);
          final List<dynamic> surahs =
              quranData['surahs'] ?? quranData['data'] ?? [];

          if (kDebugMode) {
            print('✅ Loaded ${surahs.length} surahs');
          }

          // Flatten all ayahs from all surahs
          final allAyahs = <Map<String, dynamic>>[];
          for (final surah in surahs) {
            final surahName = surah['name'] ?? surah['englishName'] ?? '';
            final List<dynamic> ayahs = surah['ayahs'] ?? surah['verses'] ?? [];

            for (final ayah in ayahs) {
              final ayahText = ayah['text'] ?? ayah['content'] ?? '';
              if (ayahText.isNotEmpty) {
                allAyahs.add({
                  'text': ayahText,
                  'surahName': surahName,
                  'ayahNumber': ayah['numberInSurah'] ?? ayah['number'] ?? '',
                });
              }
            }
          }

          if (kDebugMode) {
            print('✅ Flattened to ${allAyahs.length} ayahs');
            if (allAyahs.isNotEmpty) {
              print(
                  '📝 Sample ayah: ${allAyahs[0]['text']?.toString().substring(0, 50)}...');
            }
          }

          return allAyahs;
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ ERROR loading JSON for ${type.name}: $e');
        print('Stack trace: $stackTrace');
      }
      return []; // Return empty list on error
    }
  }

  // Create story from loaded item (CONTENT STORED ONCE)
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
        // Try multiple field names for hadith content
        content = item['hadithArabic'] ??
            item['text'] ??
            item['content'] ??
            item['hadithEnglish'] ??
            '';
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

    // ✅ CONTENT IS STORED HERE - NOT CALCULATED DYNAMICALLY
    return StoryModel(
      id: id,
      type: type,
      title: title,
      content: content, // ✅ Fixed content!
      icon: icon,
      lastUpdated: DateTime.now(),
      isViewed: _viewedStories.contains(id),
    );
  }

  // Create 3 UNIQUE fallback stories (ONLY when JSON fails)
  List<StoryModel> _create3FallbackStories(StoryType type, String typePrefix) {
    final stories = <StoryModel>[];

    // ✅ Create 3 DIFFERENT stories using index
    for (int i = 0; i < 3; i++) {
      final storyId = 'story_${typePrefix}_$i';
      stories.add(_createFallbackStory(storyId, type, i));
    }

    return stories;
  }

  // Create single fallback story with UNIQUE content based on index
  StoryModel _createFallbackStory(String id, StoryType type, int index) {
    String content = '';
    String title = '';
    IconData icon;

    // ✅ Predefined UNIQUE fallback contents
    switch (type) {
      case StoryType.hadith:
        title = 'حديث اليوم';
        icon = Icons.menu_book;

        // ✅ 3 DIFFERENT fallback hadiths
        final fallbackHadiths = [
          'قَالَ رَسُولُ اللَّهِ صَلَّى اللهُ عَلَيْهِ وَسَلَّمَ: "إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى"',
          'قَالَ رَسُولُ اللَّهِ صَلَّى اللهُ عَلَيْهِ وَسَلَّمَ: "الْمُسْلِمُ مَنْ سَلِمَ الْمُسْلِمُونَ مِنْ لِسَانِهِ وَيَدِهِ"',
          'قَالَ رَسُولُ اللَّهِ صَلَّى اللهُ عَلَيْهِ وَسَلَّمَ: "مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الْآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ"',
        ];
        content = fallbackHadiths[index % fallbackHadiths.length];
        break;

      case StoryType.duaa:
        title = 'دعاء اليوم';
        icon = Icons.pan_tool_alt;

        // ✅ 3 DIFFERENT fallback duas
        final fallbackDuas = [
          'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
          'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِن لَّدُنكَ رَحْمَةً إِنَّكَ أَنتَ الْوَهَّابُ',
          'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي وَاحْلُلْ عُقْدَةً مِّن لِّسَانِي يَفْقَهُوا قَوْلِي',
        ];
        content = fallbackDuas[index % fallbackDuas.length];
        break;

      case StoryType.ayah:
        title = 'آية اليوم';
        icon = Icons.chrome_reader_mode;

        // ✅ 3 DIFFERENT fallback ayahs
        final fallbackAyahs = [
          'وَقُل رَّبِّ زِدْنِي عِلْمًا',
          'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
          'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
        ];
        content = fallbackAyahs[index % fallbackAyahs.length];
        break;
    }

    // ✅ CONTENT IS STORED HERE - NOT CALCULATED DYNAMICALLY
    return StoryModel(
      id: id,
      type: type,
      title: title,
      content: content, // ✅ Fixed content!
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
    await prefs.setString(
        _viewedStoriesKey, json.encode(_viewedStories.toList()));
  }

  // Load previous content (to avoid repetition on refresh)
  Future<void> _loadPreviousContent() async {
    final prefs = await SharedPreferences.getInstance();
    final contentJson = prefs.getString(_previousContentKey);
    if (contentJson != null) {
      final Map<String, dynamic> decoded = json.decode(contentJson);
      _previousContent = Map<String, String>.from(decoded);
    }
  }

  // Save previous content
  Future<void> _savePreviousContent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_previousContentKey, json.encode(_previousContent));
  }

  // Load recent contents (to avoid repetition)
  Future<void> _loadRecentContents() async {
    final prefs = await SharedPreferences.getInstance();
    final contentsJson = prefs.getString(_recentContentsKey);
    if (contentsJson != null) {
      final Map<String, dynamic> decoded = json.decode(contentsJson);
      _recentContents = decoded
          .map((key, value) => MapEntry(key, List<String>.from(value as List)));
    }
  }

  // Save recent contents
  Future<void> _saveRecentContents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_recentContentsKey, json.encode(_recentContents));
  }

  // Add contents to recent list (keep last 5 to avoid)
  void _addToRecentContents(String typePrefix, List<String> newContents) {
    final recent = _recentContents[typePrefix] ?? [];

    // Add new contents
    recent.addAll(newContents);

    // Keep only last 5 items (to have variety but not repeat too soon)
    if (recent.length > 5) {
      _recentContents[typePrefix] = recent.sublist(recent.length - 5);
    } else {
      _recentContents[typePrefix] = recent;
    }

    if (kDebugMode) {
      print('📝 Recent $typePrefix: ${_recentContents[typePrefix]}');
    }
  }

  // Force refresh all stories (for testing)
  Future<void> forceRefresh() async {
    await _generateAllStories();
  }

  // Clear all data (for testing)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storiesKey);
    await prefs.remove(_viewedStoriesKey);
    await prefs.remove(_previousContentKey);
    await prefs.remove(_recentContentsKey);
    _stories = [];
    _viewedStories = {};
    _previousContent = {};
    _recentContents = {
      'hadith': [],
      'duaa': [],
      'ayah': [],
    };
  }
}
