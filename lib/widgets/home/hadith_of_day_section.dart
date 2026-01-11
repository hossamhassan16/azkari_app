import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../common/section_header.dart';

class HadithOfDaySection extends StatelessWidget {
  const HadithOfDaySection({super.key});

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
          child: const Text(
            'Hadith content will be here',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
