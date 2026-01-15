import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tasbeh_item_model.dart';
import '../models/tasbeh_model.dart';

class TasbehService {
  static final TasbehService _instance = TasbehService._internal();
  factory TasbehService() => _instance;
  TasbehService._internal();

  SharedPreferences? _prefs;
  List<TasbehItemModel> _cachedTasbeh = [];
  List<TasbehModel>? _cachedTasbehDuas;

  // Default tasbeh items with their benefits
  static final List<Map<String, dynamic>> _defaultTasbeh = [
    {
      'id': 'tasbeh_1',
      'name': 'سبحان الله و يحمده',
      'beadsCount': 33,
      'benefit':
          '1- ( " كان رسول الله صلى الله عليه وسلم يكثر من قول " سبحان الله وبحمده أستغفر الله وأتوب إليه " . قالت فقلت : يا رسول الله ! أراك تكثر من قول " سبحان الله ومحمده أستغفر الله وأتوب إليه " فقال " خبرني ربي أني سأرى علامة في أمتي ، فإذا رأيتها أكثرت من قول : سبحان الله ومحمده أستغفر الله وأتوب إليه ، فقد رأيتها . [ إذا جاء نصر الله والفتح . فتح مكة . ورأيت الناس يدخلون في دين الله أفواجا ، فسبح بحمد ربك واستغفره إنه كان توابا صحيح[1] . ] ( " ربك واستغفره إنه كان توابا\n\n2- ( " كلمتان خفيفتان على اللسان، ثقيلتان في الميزان، ) . حبيبتان إلى الرحمن، : سبحان الله وحمده ، سبحان الله العظيم [2] .صحيح ) .\n\n3- ( " من قال : سبحان الله وحمده، في يوم مائة مرة، حطت خطاياه وإن كانت مثل زبد البحر .صحيح[3] ) .\n\n4- أَنَّ رسولَ اللَّهِ صلَّى اللَّهُ عليهِ وسلَّمَ سُئِلَ : أيُّ الكلامِ أفضلُ ؟ قالَ : " ما اصطفى اللَّهُ لملائِكتِهِ أو لعبادِه: سبحانَ اللَّهِ وبِحمدِهِ [4] .صحيح ) .',
    },
    {
      'id': 'tasbeh_2',
      'name': 'لا حول ولا قوة إلا بالله',
      'beadsCount': 33,
      'benefit':
          'عن أبي موسى رضي الله عنه قال ، قال لي رسول الله صلى الله عليه وسلم : " أ لا أدلك على كنز من كنوز الجنة ؟ فقلت بلى يا " رسول الله ، فقال: " لا حول ولا قوة إلا بالله ',
    },
    {
      'id': 'tasbeh_3',
      'name': 'اللهم صل على سيدنا محمد وعلى اله وصحبه وسلم',
      'beadsCount': 100,
      'benefit':
          'قال رسول الله صلى الله عليه وسلم "من صلى على واحدة صلى الله بها عليه عشر صلوات وحط عنه عشر سيئات ورفع له عشر درجات "',
    },
    {
      'id': 'tasbeh_4',
      'name': 'قراءة قل هو الله أحد',
      'beadsCount': 10,
      'benefit':
          'قال رسول الله صلى الله عليه وسلم " من قرأ قل هو الله أحد " حتى يختمها عشر مرات بنى الله له قصرا في الجنة',
    },
    {
      'id': 'tasbeh_5',
      'name': 'أستغفر الله العظيم',
      'beadsCount': 33,
      'benefit':
          'قال صلى الله عليه وسلم " من لزم الاستغفار جعل الله له من كل ضيق مخرجا ومن كل هم فرجا ورزقه من حيث لا يحتسب "',
    },
  ];

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await loadTasbeh();
  }

  Future<List<TasbehItemModel>> loadTasbeh() async {
    try {
      final savedData = _prefs?.getString('tasbeh_items');

      if (savedData != null) {
        final List<dynamic> jsonList = json.decode(savedData);
        _cachedTasbeh =
            jsonList.map((item) => TasbehItemModel.fromJson(item)).toList();
      } else {
        // Load default tasbeh
        _cachedTasbeh = _defaultTasbeh
            .map((item) => TasbehItemModel.fromJson(item))
            .toList();
        await saveTasbeh();
      }

      return _cachedTasbeh;
    } catch (e) {
      // If error, return default tasbeh
      _cachedTasbeh =
          _defaultTasbeh.map((item) => TasbehItemModel.fromJson(item)).toList();
      return _cachedTasbeh;
    }
  }

  Future<void> saveTasbeh() async {
    try {
      final jsonList = _cachedTasbeh.map((item) => item.toJson()).toList();
      await _prefs?.setString('tasbeh_items', json.encode(jsonList));
    } catch (e) {
      throw Exception('Failed to save tasbeh: $e');
    }
  }

  Future<void> addTasbeh(TasbehItemModel tasbeh) async {
    _cachedTasbeh.add(tasbeh);
    await saveTasbeh();
  }

  Future<void> updateTasbeh(TasbehItemModel updatedTasbeh) async {
    final index = _cachedTasbeh.indexWhere((t) => t.id == updatedTasbeh.id);
    if (index != -1) {
      _cachedTasbeh[index] = updatedTasbeh;
      await saveTasbeh();
    }
  }

  Future<void> deleteTasbeh(String id) async {
    _cachedTasbeh.removeWhere((t) => t.id == id);
    await saveTasbeh();
  }

  Future<void> incrementCount(String id) async {
    final index = _cachedTasbeh.indexWhere((t) => t.id == id);
    if (index != -1) {
      final tasbeh = _cachedTasbeh[index];
      final newCurrent = tasbeh.currentCount + 1;

      if (newCurrent >= tasbeh.beadsCount) {
        // Completed a cycle
        _cachedTasbeh[index] = tasbeh.copyWith(
          currentCount: 0,
          cycleCount: tasbeh.cycleCount + 1,
          totalCount: tasbeh.totalCount + 1,
        );
      } else {
        _cachedTasbeh[index] = tasbeh.copyWith(
          currentCount: newCurrent,
          totalCount: tasbeh.totalCount + 1,
        );
      }

      await saveTasbeh();
    }
  }

  Future<void> decrementCount(String id) async {
    final index = _cachedTasbeh.indexWhere((t) => t.id == id);
    if (index != -1) {
      final tasbeh = _cachedTasbeh[index];
      if (tasbeh.currentCount > 0) {
        _cachedTasbeh[index] = tasbeh.copyWith(
          currentCount: tasbeh.currentCount - 1,
          totalCount: tasbeh.totalCount > 0 ? tasbeh.totalCount - 1 : 0,
        );
        await saveTasbeh();
      } else if (tasbeh.cycleCount > 0) {
        // Go back to previous cycle
        _cachedTasbeh[index] = tasbeh.copyWith(
          currentCount: tasbeh.beadsCount - 1,
          cycleCount: tasbeh.cycleCount - 1,
          totalCount: tasbeh.totalCount > 0 ? tasbeh.totalCount - 1 : 0,
        );
        await saveTasbeh();
      }
    }
  }

  Future<void> resetCurrent(String id) async {
    final index = _cachedTasbeh.indexWhere((t) => t.id == id);
    if (index != -1) {
      _cachedTasbeh[index] = _cachedTasbeh[index].copyWith(
        currentCount: 0,
      );
      await saveTasbeh();
    }
  }

  Future<void> resetAll(String id) async {
    final index = _cachedTasbeh.indexWhere((t) => t.id == id);
    if (index != -1) {
      _cachedTasbeh[index] = _cachedTasbeh[index].copyWith(
        currentCount: 0,
        cycleCount: 0,
        totalCount: 0,
      );
      await saveTasbeh();
    }
  }

  TasbehItemModel? getTasbehById(String id) {
    try {
      return _cachedTasbeh.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  List<TasbehItemModel> getAllTasbeh() {
    return List.unmodifiable(_cachedTasbeh);
  }

  // Methods for Tasbeh Duas Screen (التسبيح)
  Future<List<TasbehModel>> loadQuranDuas() async {
    if (_cachedTasbehDuas != null) {
      return _cachedTasbehDuas!;
    }

    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/tasbeeh.json');
      final Map<String, dynamic> data = json.decode(jsonString);

      final List<dynamic> duasList = data['duas'] as List<dynamic>;
      _cachedTasbehDuas = duasList
          .asMap()
          .entries
          .map((entry) =>
              TasbehModel.fromJson(entry.value.toString(), entry.key))
          .toList();

      await _loadTasbehDuasProgress();
      return _cachedTasbehDuas!;
    } catch (e) {
      throw Exception('Failed to load tasbeh duas: $e');
    }
  }

  Future<void> _loadTasbehDuasProgress() async {
    if (_cachedTasbehDuas == null) return;

    for (int i = 0; i < _cachedTasbehDuas!.length; i++) {
      final dua = _cachedTasbehDuas![i];
      final key = 'tasbeh_dua_progress_${dua.id}';
      final savedCount = _prefs?.getInt(key);
      if (savedCount != null) {
        _cachedTasbehDuas![i] = dua.copyWith(currentCount: savedCount);
      }
    }
  }

  Future<void> saveProgress(String duaId, int count) async {
    final key = 'tasbeh_dua_progress_$duaId';
    await _prefs?.setInt(key, count);

    if (_cachedTasbehDuas != null) {
      for (int i = 0; i < _cachedTasbehDuas!.length; i++) {
        if (_cachedTasbehDuas![i].id == duaId) {
          _cachedTasbehDuas![i] =
              _cachedTasbehDuas![i].copyWith(currentCount: count);
          break;
        }
      }
    }
  }

  Future<void> resetTasbehDua(String duaId) async {
    if (_cachedTasbehDuas == null) return;

    for (int i = 0; i < _cachedTasbehDuas!.length; i++) {
      if (_cachedTasbehDuas![i].id == duaId) {
        final dua = _cachedTasbehDuas![i];
        _cachedTasbehDuas![i] = dua.copyWith(currentCount: dua.initialCount);
        final key = 'tasbeh_dua_progress_${dua.id}';
        await _prefs?.setInt(key, dua.initialCount);
        break;
      }
    }
  }

  void clearTasbehDuasCache() {
    _cachedTasbehDuas = null;
  }
}
