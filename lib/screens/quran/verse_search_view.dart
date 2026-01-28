import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/ayah_model.dart';
import '../../widgets/quran/ayah_item.dart';
import '../../services/saved_verses_service.dart';
import '../../services/quran_api_service.dart';
import '../../services/quran_settings_service.dart';

class VerseSearchView extends StatefulWidget {
  const VerseSearchView({super.key});

  @override
  State<VerseSearchView> createState() => VerseSearchViewState();
}

class VerseSearchViewState extends State<VerseSearchView> {
  final QuranApiService _apiService = QuranApiService();
  final SavedVersesService _savedVersesService = SavedVersesService();
  final QuranSettingsService _settingsService = QuranSettingsService();

  List<AyahModel> _searchResults = [];
  bool _isSearching = false;
  String _searchQuery = '';

  Future<void> searchVerses(String query) async {
    if (query.isEmpty) {
      if (!mounted) return;
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _searchQuery = '';
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _isSearching = true;
      _searchQuery = query;
    });

    try {
      final results = await _apiService.searchVerses(query);

      if (!mounted) return;

      final savedResults = results.map((ayah) {
        final isSaved = _savedVersesService.isVerseSaved(ayah);
        return ayah.copyWith(isSaved: isSaved);
      }).toList();

      setState(() {
        _searchResults = savedResults;
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkBackground,
      child: _searchQuery.isEmpty && _searchResults.isEmpty
          ? Center(
              child: Text(
                AppStrings.search,
                style: const TextStyle(
                  color: AppColors.greyText,
                  fontSize: 18,
                ),
              ),
            )
          : _isSearching
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                )
              : _searchResults.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد نتائج',
                        style: const TextStyle(
                          color: AppColors.greyText,
                          fontSize: 18,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final ayah = _searchResults[index];
                        return AyahItem(
                          isActive: false,
                          ayah: ayah,
                          fontSize: _settingsService.fontSize,
                          onBookmarkTap: () {
                            if (!mounted) return;
                            setState(() {
                              if (ayah.isSaved) {
                                _savedVersesService.removeVerse(ayah);
                              } else {
                                _savedVersesService.saveVerse(ayah);
                              }

                              _searchResults[index] = ayah.copyWith(
                                isSaved: !ayah.isSaved,
                              );
                            });
                          },
                        );
                      },
                    ),
    );
  }
}
