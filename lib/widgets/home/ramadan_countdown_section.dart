import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../core/constants/app_colors.dart';

class RamadanCountdownSection extends StatefulWidget {
  const RamadanCountdownSection({super.key});

  @override
  State<RamadanCountdownSection> createState() =>
      _RamadanCountdownSectionState();
}

class _RamadanCountdownSectionState extends State<RamadanCountdownSection> {
  late Timer _timer;
  int _remainingDays = 0;

  @override
  void initState() {
    super.initState();
    _updateCountdown(); // تحديث العداد عند البداية

    // تحديث العداد كل ساعة
    _timer = Timer.periodic(const Duration(hours: 1), (_) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    final todayHijri = HijriCalendar.now();

    // أول يوم رمضان في نفس السنة الهجرية
    final ramadanStartHijri = HijriCalendar()
      ..hYear = todayHijri.hYear
      ..hMonth = 9
      ..hDay = 1;

    // تحويل أول يوم رمضان إلى ميلادي
    final ramadanStartGregorian = ramadanStartHijri.hijriToGregorian(
        ramadanStartHijri.hYear,
        ramadanStartHijri.hMonth,
        ramadanStartHijri.hDay);

    final now = DateTime.now();
    setState(() {
      final difference = ramadanStartGregorian.difference(now);
      _remainingDays = difference.isNegative ? 0 : difference.inDays + 1;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _remainingDays == 0
            ? 'رمضان مبارك!'
            : '  بقى $_remainingDays  أيام لرمضان',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
