import '../models/ayah_model.dart';

class SavedVersesService {
  static final SavedVersesService _instance = SavedVersesService._internal();
  factory SavedVersesService() => _instance;
  SavedVersesService._internal();

  final List<AyahModel> _savedVerses = [];

  List<AyahModel> get savedVerses => List.unmodifiable(_savedVerses);

  void saveVerse(AyahModel ayah) {
    if (!_savedVerses.any((v) =>
        v.number == ayah.number &&
        v.surahNumber == ayah.surahNumber)) {
      _savedVerses.add(ayah.copyWith(isSaved: true));
    }
  }

  void removeVerse(AyahModel ayah) {
    _savedVerses.removeWhere((v) =>
        v.number == ayah.number &&
        v.surahNumber == ayah.surahNumber);
  }

  bool isVerseSaved(AyahModel ayah) {
    return _savedVerses.any((v) =>
        v.number == ayah.number &&
        v.surahNumber == ayah.surahNumber);
  }
}

