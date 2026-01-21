import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/quran/ayah_item.dart';
import '../../services/saved_verses_service.dart';
import '../../services/quran_settings_service.dart';

class SavedVersesScreen extends StatefulWidget {
  const SavedVersesScreen({super.key});

  @override
  State<SavedVersesScreen> createState() => _SavedVersesScreenState();
}

class _SavedVersesScreenState extends State<SavedVersesScreen> {
  final SavedVersesService _savedVersesService = SavedVersesService();
  final QuranSettingsService _settingsService = QuranSettingsService();

  @override
  Widget build(BuildContext context) {
    final savedVerses = _savedVersesService.savedVerses;

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
        title: const Text(
          AppStrings.savedVerses,
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: savedVerses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.bookmark_border,
                    color: AppColors.greyText,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد آيات محفوظة',
                    style: const TextStyle(
                      color: AppColors.greyText,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: savedVerses.length,
              itemBuilder: (context, index) {
                final ayah = savedVerses[index];
                return AyahItem(
                  ayah: ayah,
                  fontSize: _settingsService.fontSize,
                  onBookmarkTap: () {
                    setState(() {
                      _savedVersesService.removeVerse(ayah);
                    });
                  },
                );
              },
            ),
    );
  }
}
