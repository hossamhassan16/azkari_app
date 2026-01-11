import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../common/section_header.dart';

class VerseOfDaySection extends StatelessWidget {
  const VerseOfDaySection({super.key});

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
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verse content will be here',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                ),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 8),
              Text(
                'Surah name',
                style: TextStyle(
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
