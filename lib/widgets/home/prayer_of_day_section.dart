import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../common/section_header.dart';

class PrayerOfDaySection extends StatelessWidget {
  const PrayerOfDaySection({super.key});

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
          child: const Text(
            'Prayer content will be here',
            style: TextStyle(
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

