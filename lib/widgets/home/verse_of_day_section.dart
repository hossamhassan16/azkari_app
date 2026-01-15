import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // لتحميل JSON من assets
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../common/section_header.dart';

class VerseOfDaySection extends StatefulWidget {
  const VerseOfDaySection({super.key});

  @override
  State<VerseOfDaySection> createState() => _VerseOfDaySectionState();
}

class _VerseOfDaySectionState extends State<VerseOfDaySection> {
  String _verseText = '';
  String _surahName = '';

  @override
  void initState() {
    super.initState();
    _loadRandomVerse();
  }

  Future<void> _loadRandomVerse() async {
    // تحميل JSON من assets
    final String jsonString =
        await rootBundle.loadString('assets/data/quran.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    // دمج كل الآيات في قائمة واحدة
    final List allAyahs = [];
    for (var surah in jsonData['data']['surahs']) {
      for (var ayah in surah['ayahs']) {
        allAyahs.add({
          'text': ayah['text'],
          'surah': surah['name'],
        });
      }
    }

    // حساب seed اليوم (عدد الأيام منذ تاريخ ثابت)
    final startDate = DateTime(2026, 1, 1);
    final now = DateTime.now();
    final dayIndex = now.difference(startDate).inDays;

    // استخدام Random مع seed يومي لاختيار آية عشوائية
    final random = Random(dayIndex);
    final randomIndex = random.nextInt(allAyahs.length);

    final todayAyah = allAyahs[randomIndex];

    setState(() {
      _verseText = todayAyah['text'];
      _surahName = todayAyah['surah'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: AppStrings.verseOfTheDay,
          onShare: () {
            // Handle share
          },
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _verseText.isEmpty ? 'جاري التحميل...' : _verseText,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontFamily: "AmiriQuran",
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 8),
              Text(
                _surahName,
                style: const TextStyle(
                  color: AppColors.greyText,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
