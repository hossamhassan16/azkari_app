import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/ayah_model.dart';
import '../../widgets/quran/ayah_item.dart';
import '../../widgets/quran/page_view_mode.dart';
import '../../widgets/quran/quran_settings_bottom_sheet.dart';
import '../../services/saved_verses_service.dart';
import '../../services/quran_api_service.dart';
import '../../services/quran_settings_service.dart';

class JuzDetailScreen extends StatefulWidget {
  final int juzNumber;

  const JuzDetailScreen({
    super.key,
    required this.juzNumber,
  });

  @override
  State<JuzDetailScreen> createState() => _JuzDetailScreenState();
}

class _JuzDetailScreenState extends State<JuzDetailScreen> {
  final SavedVersesService _savedVersesService = SavedVersesService();
  final QuranApiService _apiService = QuranApiService();
  final QuranSettingsService _settingsService = QuranSettingsService();
  List<AyahModel> _ayahs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAyahs();
  }

  void _onSettingsChanged() {
    setState(() {
      // Rebuild UI when settings change
    });
  }

  Future<void> _loadAyahs() async {
    try {
      final ayahs = await _apiService.getJuzAyahs(widget.juzNumber);

      if (!mounted) return;

      // Check which ayahs are saved
      final savedAyahs = ayahs.map((ayah) {
        final isSaved = _savedVersesService.isVerseSaved(ayah);
        return ayah.copyWith(isSaved: isSaved);
      }).toList();

      setState(() {
        _ayahs = savedAyahs;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Helper to remove Basmala from the first ayah of each surah
  AyahModel _removeBasmalaFromFirstAyah(AyahModel ayah) {
    // Only remove from first ayah of surahs (except Surah 9)
    if (ayah.number == 1 && ayah.surahNumber != 9) {
      String text = ayah.text;

      // List of possible Basmala patterns
      final basmalaPatterns = [
        'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        'بسم الله الرحمن الرحيم',
        'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
      ];

      for (final pattern in basmalaPatterns) {
        if (text.startsWith(pattern)) {
          text = text.substring(pattern.length).trim();
          break;
        }
      }

      // Also try to remove it if it contains BOM character
      text = text.replaceFirst('\ufeff', '').trim();

      return ayah.copyWith(text: text);
    }
    return ayah;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'الجزء ${widget.juzNumber}',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.fullscreen,
              color: AppColors.white,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => QuranSettingsBottomSheet(
                  onSettingsChanged: _onSettingsChanged,
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'حدث خطأ في تحميل البيانات',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAyahs,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                        ),
                        child: const Text(
                          'إعادة المحاولة',
                          style: TextStyle(color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                )
              : _settingsService.displayMode == VerseDisplayMode.list
                  ? ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _ayahs.length,
                      itemBuilder: (context, index) {
                        final ayah = _ayahs[index];
                        final isFirstAyahOfSurah = index == 0 ||
                            _ayahs[index - 1].surahNumber != ayah.surahNumber;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Add spacing and surah name before new surah
                            if (isFirstAyahOfSurah) ...[
                              if (index != 0) const SizedBox(height: 24),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Column(
                                  children: [
                                    Text(
                                      '━━━━━━━━━━━━━━━━━━━━━',
                                      style: TextStyle(
                                        color: AppColors.primaryGreen
                                            .withOpacity(0.5),
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      ayah.surahName,
                                      style: const TextStyle(
                                        fontFamily: 'AmiriQuran',
                                        color: AppColors.primaryGreen,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '━━━━━━━━━━━━━━━━━━━━━',
                                      style: TextStyle(
                                        color: AppColors.primaryGreen
                                            .withOpacity(0.5),
                                        fontSize: 16,
                                      ),
                                    ),
                                    // Add Basmala for all surahs except Surah 9 (At-Tawbah)
                                    if (ayah.surahNumber != 9) ...[
                                      const SizedBox(height: 12),
                                      Text(
                                        'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
                                        style: TextStyle(
                                          fontFamily: 'AmiriQuran',
                                          fontSize: 22,
                                          color: AppColors.greenAccent,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  ],
                                ),
                              ),
                            ],

                            // The ayah item
                            AyahItem(
                              isActive: false,
                              ayah: _removeBasmalaFromFirstAyah(ayah),
                              onBookmarkTap: () {
                                if (!mounted) return;
                                setState(() {
                                  if (ayah.isSaved) {
                                    _savedVersesService.removeVerse(ayah);
                                  } else {
                                    _savedVersesService.saveVerse(ayah);
                                  }
                                  _ayahs[index] = ayah.copyWith(
                                    isSaved: !ayah.isSaved,
                                  );
                                });
                              },
                            ),
                          ],
                        );
                      },
                    )
                  : PageViewMode(
                      ayahs: _ayahs
                          .map((ayah) => _removeBasmalaFromFirstAyah(ayah))
                          .toList(),
                      fontSize: _settingsService.fontSize,
                    ),
    );
  }
}
