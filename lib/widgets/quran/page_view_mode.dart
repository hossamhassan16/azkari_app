import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/ayah_model.dart';

class PageViewMode extends StatelessWidget {
  final List<AyahModel> ayahs;
  final double fontSize;

  const PageViewMode({
    super.key,
    required this.ayahs,
    required this.fontSize,
  });

  // Helper to remove Basmala from the start of an ayah
  String _removeBismillah(String text) {
    final bismillahPatterns = [
      'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      'بسم الله الرحمن الرحيم',
      'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
    ];

    String cleanedText = text;

    for (final pattern in bismillahPatterns) {
      if (cleanedText.startsWith(pattern)) {
        cleanedText = cleanedText.substring(pattern.length).trim();
        break;
      }
    }

    // Also remove BOM character if present
    cleanedText = cleanedText.replaceFirst('\ufeff', '').trim();

    return cleanedText;
  }

  @override
  Widget build(BuildContext context) {
    if (ayahs.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد آيات للعرض',
          style: TextStyle(color: AppColors.white),
        ),
      );
    }

    List<Widget> pageWidgets = [];
    int? currentSurahNumber;

    // Check if this is a single surah or multiple surahs (like in Juz view)
    final uniqueSurahs = ayahs.map((a) => a.surahNumber).toSet();
    final isMultipleSurahs = uniqueSurahs.length > 1;

    List<InlineSpan> textSpans = [];

    for (int i = 0; i < ayahs.length; i++) {
      final ayah = ayahs[i];

      // Add Surah header and Basmala if it's a new surah
      if (currentSurahNumber == null ||
          currentSurahNumber != ayah.surahNumber) {
        currentSurahNumber = ayah.surahNumber;

        // Add spacing before new surah (except for the first one)
        if (i != 0) {
          textSpans.add(const TextSpan(text: '\n\n\n'));
        }

        // Add surah name header (only in multi-surah view or first surah)
        if (isMultipleSurahs || i == 0) {
          // Add the surah name as a widget
          if (textSpans.isNotEmpty) {
            pageWidgets.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: RichText(
                  textAlign: TextAlign.justify,
                  textDirection: TextDirection.rtl,
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'AmiriQuran',
                      fontSize: fontSize,
                      color: AppColors.white,
                      height: 2.0,
                      letterSpacing: 0.5,
                    ),
                    children: textSpans,
                  ),
                ),
              ),
            );
            textSpans = [];
          }

          pageWidgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                ayah.surahName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'AmiriQuran',
                  fontSize: fontSize * 1.3,
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );

          // Add Basmala for all surahs except At-Tawbah (Surah 9)
          if (ayah.surahNumber != 9) {
            pageWidgets.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 8),
                child: Text(
                  'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'AmiriQuran',
                    fontSize: fontSize * 1.2,
                    color: const Color(0xFFD4AF37), // Gold color for Basmala
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          } else {
            pageWidgets.add(const SizedBox(height: 16));
          }
        }
      }

      // Get ayah text and remove Bismillah if it's the first ayah of a surah
      String ayahText = ayah.text;
      if (ayah.number == 1 && ayah.surahNumber != 9) {
        ayahText = _removeBismillah(ayahText);
      }

      // Add the ayah text with its number
      textSpans.add(
        TextSpan(
          text: '$ayahText ',
          style: TextStyle(
            fontFamily: 'AmiriQuran',
            fontSize: fontSize,
            color: AppColors.white,
          ),
          children: [
            TextSpan(
              text: '﴿${_convertToArabicNumbers(ayah.number)}﴾ ',
              style: TextStyle(
                fontFamily: 'AmiriQuran',
                fontSize: fontSize * 0.75,
                color: AppColors.primaryGreen,
              ),
            ),
          ],
        ),
      );
    }

    // Add remaining text spans
    if (textSpans.isNotEmpty) {
      pageWidgets.add(
        RichText(
          textAlign: TextAlign.justify,
          textDirection: TextDirection.rtl,
          text: TextSpan(
            style: TextStyle(
              fontFamily: 'AmiriQuran',
              fontSize: fontSize,
              color: AppColors.white,
              height: 2.0,
              letterSpacing: 0.5,
            ),
            children: textSpans,
          ),
        ),
      );
    }

    return Container(
      color: AppColors.darkBackground,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: pageWidgets,
        ),
      ),
    );
  }

  String _convertToArabicNumbers(int number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = number.toString();
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }
}
