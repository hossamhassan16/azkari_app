import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/surah_model.dart';
import '../../models/ayah_model.dart';
import '../../widgets/quran/ayah_item.dart';
import '../../widgets/quran/page_view_mode.dart';
import '../../widgets/quran/quran_settings_bottom_sheet.dart';
import '../../services/saved_verses_service.dart';
import '../../services/quran_api_service.dart';
import '../../services/quran_settings_service.dart';

class SurahDetailScreen extends StatefulWidget {
  final SurahModel surah;

  const SurahDetailScreen({
    super.key,
    required this.surah,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final SavedVersesService _savedVersesService = SavedVersesService();
  final QuranApiService _apiService = QuranApiService();
  final QuranSettingsService _settingsService = QuranSettingsService();
  List<AyahModel> _ayahs = [];
  bool _isLoading = true;
  String? _error;
  int? _juzNumber;

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
      final ayahs = await _apiService.getSurahAyahs(widget.surah.number);

      if (!mounted) return;

      // Get juz number from first ayah
      if (ayahs.isNotEmpty) {
        _juzNumber = ayahs.first.juz;
      }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: AppColors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.surah.arabicName,
          style: const TextStyle(
            fontFamily: 'AmiriQuran',
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
          IconButton(
            icon: const Icon(
              Icons.cast,
              color: AppColors.white,
            ),
            onPressed: () {
              // Handle cast
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
              : Column(
                  children: [
                    // Juz indicator
                    if (_juzNumber != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        color: AppColors.cardBackground,
                        child: Text(
                          'الجزء $_juzNumber',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    // Verses list or page view
                    Expanded(
                      child: _settingsService.displayMode ==
                              VerseDisplayMode.list
                          ? ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: _ayahs.length,
                              itemBuilder: (context, index) {
                                final ayah = _ayahs[index];
                                return AyahItem(
                                  ayah: ayah,
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
                                );
                              },
                            )
                          : PageViewMode(
                              ayahs: _ayahs,
                              fontSize: _settingsService.fontSize,
                            ),
                    ),
                  ],
                ),
    );
  }
}
