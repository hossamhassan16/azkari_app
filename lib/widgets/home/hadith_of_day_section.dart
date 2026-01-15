import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../common/section_header.dart';

class HadithOfDaySection extends StatefulWidget {
  const HadithOfDaySection({super.key});

  @override
  State<HadithOfDaySection> createState() => _HadithOfDaySectionState();
}

class _HadithOfDaySectionState extends State<HadithOfDaySection> {
  String _hadithArabic = '';

  @override
  void initState() {
    super.initState();
    _loadDailyHadith();
  }

  Future<void> _loadDailyHadith() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/hadiths.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List hadiths = jsonData['hadiths']['data'];

      // حساب اليوم الحالي بالنسبة لتاريخ ثابت
      final startDate = DateTime(2026, 1, 1);
      final now = DateTime.now();
      final dayIndex = now.difference(startDate).inDays;

      // Random ثابت اليومي
      final random = Random(dayIndex);
      final todayHadith = hadiths[random.nextInt(hadiths.length)];

      setState(() {
        _hadithArabic = todayHadith['hadithArabic'] ?? 'لا يوجد حديث اليوم';
      });
    } catch (e) {
      print('Error loading hadith: $e');
      setState(() {
        _hadithArabic = 'حدث خطأ في تحميل الحديث';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: AppStrings.hadithOfTheDay,
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
          child: Text(
            _hadithArabic.isEmpty ? 'جاري التحميل...' : _hadithArabic,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl, // مهم للنص العربي
          ),
        ),
      ],
    );
  }
}
