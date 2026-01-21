import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../common/section_header.dart';

class PrayerOfDaySection extends StatefulWidget {
  const PrayerOfDaySection({super.key});

  @override
  State<PrayerOfDaySection> createState() => _PrayerOfDaySectionState();
}

class _PrayerOfDaySectionState extends State<PrayerOfDaySection> {
  String _prayerArabic = 'تحميل...';

  @override
  void initState() {
    super.initState();
    _loadDailyPrayer();
  }

  Future<void> _loadDailyPrayer() async {
    // تحميل ملف JSON من assets
    final String jsonString =
        await rootBundle.loadString('assets/data/duaa_elyoum.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final List prayers = jsonData['duas'];

    // نستخدم اليوم الحالي لتوليد "عشوائي ثابت يوميًا"
    final startDate = DateTime(2026, 1, 1);
    final now = DateTime.now();
    final dayIndex = now.difference(startDate).inDays;

    final random = Random(dayIndex);
    final todayPrayer = prayers[random.nextInt(prayers.length)];

    setState(() {
      _prayerArabic = todayPrayer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: AppStrings.prayerOfTheDay,
          onShare: () {
            // Handle share
          },
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _prayerArabic,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
