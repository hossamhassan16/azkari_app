import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';

class DateSection extends StatefulWidget {
  const DateSection({super.key});

  @override
  State<DateSection> createState() => _DateSectionState();
}

class _DateSectionState extends State<DateSection> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  String _formatDate() {
    final hijri = HijriCalendar.fromDate(_selectedDate);

    final gregorianDate = DateFormat(
      'dd - MMMM - yyyy',
      'ar',
    ).format(_selectedDate);

    return '${hijri.hDay} - '
        '${hijri.longMonthName} - '
        '${hijri.hYear}'
        ' ($gregorianDate)';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Center(
        child: Text(
          _formatDate(),
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
