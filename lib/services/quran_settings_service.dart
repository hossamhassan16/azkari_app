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

  // Cached list of readers to ensure consistent object references
  final List<QuranReaderModel> _readers = [
    QuranReaderModel(
      id: 'ar.abdulbasetmratal',
      name: 'عبد الباسط عبد الصمد المرتل',
      language: 'ar',
    ),
    QuranReaderModel(
      id: 'ar.abdullahbesfer',
      name: 'عبد الله بصفر',
      language: 'ar',
    ),
    QuranReaderModel(
      id: 'ar.abdulrahmanalsudais',
      name: 'عبدالرحمن السديس',
      language: 'ar',
    ),
    QuranReaderModel(
      id: 'ar.abdulbasetabdulsamad',
      name: 'عبدالباسط عبدالصمد',
      language: 'ar',
    ),
    QuranReaderModel(
      id: 'ar.aboubakralshatri',
      name: 'أبو بكر الشاطري',
      language: 'ar',
    ),
    QuranReaderModel(
      id: 'ar.ahmedajamy',
      name: 'أحمد بن علي العجمي',
      language: 'ar',
    ),
    QuranReaderModel(
      id: 'ar.alafasy',
      name: 'مشاري العفاسي',
      language: 'ar',
    ),
    QuranReaderModel(
      id: 'ar.hanirifai',
      name: 'هاني الرفاعي',
      language: 'ar',
    ),
    QuranReaderModel(
      id: 'ar.husary',
      name: 'محمود خليل الحصري',
      language: 'ar',
    ),
    QuranReaderModel(
      id: 'ar.husarymujawwad',
      name: 'محمود خليل الحصري (المجود)',
      language: 'ar',
    ),
  ];

  List<QuranReaderModel> get readers => _readers;

  VerseDisplayMode get displayMode => _displayMode;
  double get fontSize => _fontSize;
  QuranReaderModel? get selectedReader => _selectedReader;
  bool get readVerseOnLaunch => _readVerseOnLaunch;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }

  void _loadSettings() {
    final modeIndex = _prefs?.getInt('displayMode') ?? 0;
    _displayMode = VerseDisplayMode.values[modeIndex];
    _fontSize = _prefs?.getDouble('fontSize') ?? 24.0;
    _readVerseOnLaunch = _prefs?.getBool('readVerseOnLaunch') ?? false;

    final readerId = _prefs?.getString('selectedReader');
    if (readerId != null) {
      _selectedReader = _readers.firstWhere((r) => r.id == readerId,
          orElse: () => _readers[0]);
    } else {
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
    await _prefs?.setString('selectedReader', reader.id);
  }

  Future<void> setReadVerseOnLaunch(bool value) async {
    _readVerseOnLaunch = value;
    await _prefs?.setBool('readVerseOnLaunch', value);
  }
}
