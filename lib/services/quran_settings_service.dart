import 'package:azkari_app/services/readers_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quran_reader_model.dart';

enum VerseDisplayMode { list, page }

class QuranSettingsService {
  static final QuranSettingsService _instance =
      QuranSettingsService._internal();

  factory QuranSettingsService() => _instance;

  QuranSettingsService._internal();

  SharedPreferences? _prefs;
  VerseDisplayMode _displayMode = VerseDisplayMode.list;
  double _fontSize = 24.0;
  QuranReaderModel? _selectedReader;
  bool _readVerseOnLaunch = false;

  // القائمة أصبحت ديناميكية الآن
  List<QuranReaderModel> _readers = [];
  List<QuranReaderModel> get readers => _readers;

  VerseDisplayMode get displayMode => _displayMode;
  double get fontSize => _fontSize;
  QuranReaderModel? get selectedReader => _selectedReader;
  bool get readVerseOnLaunch => _readVerseOnLaunch;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    // 1. جلب القراء من الـ API أولاً قبل تحميل الإعدادات
    await loadReadersFromApi();

    // 2. تحميل الإعدادات المحفوظة وربطها بالقراء الذين تم جلبهم
    _loadSettings();
  }

  Future<void> loadReadersFromApi() async {
    try {
      final apiService = ReadersService();
      _readers = await apiService.fetchReciters();
    } catch (e) {
      print("Error loading readers: $e");
      // يمكنك إضافة قراء افتراضيين هنا في حال فشل الاتصال
    }
  }

  void _loadSettings() {
    final modeIndex = _prefs?.getInt('displayMode') ?? 0;
    _displayMode = VerseDisplayMode.values[modeIndex];
    _fontSize = _prefs?.getDouble('fontSize') ?? 24.0;
    _readVerseOnLaunch = _prefs?.getBool('readVerseOnLaunch') ?? false;

    // جلب الـ ID المحفوظ (كـ int لأن الـ API تستخدم أرقام)
    final readerId = _prefs?.getInt('selectedReader');

    if (readerId != null && _readers.isNotEmpty) {
      try {
        _selectedReader = _readers.firstWhere(
          (r) => r.id == readerId,
          orElse: () => _readers[0],
        );
      } catch (e) {
        _selectedReader = _readers.isNotEmpty ? _readers[0] : null;
      }
    } else if (_readers.isNotEmpty) {
      _selectedReader = _readers[0];
    }
  }

  Future<void> setDisplayMode(VerseDisplayMode mode) async {
    _displayMode = mode;
    await _prefs?.setInt('displayMode', mode.index);
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size;
    await _prefs?.setDouble('fontSize', size);
  }

  Future<void> setSelectedReader(QuranReaderModel reader) async {
    _selectedReader = reader;
    // حفظ الـ ID كـ int
    await _prefs?.setInt('selectedReader', reader.id);
  }

  Future<void> setReadVerseOnLaunch(bool value) async {
    _readVerseOnLaunch = value;
    await _prefs?.setBool('readVerseOnLaunch', value);
  }
}
