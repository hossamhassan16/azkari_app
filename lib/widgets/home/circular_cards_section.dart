import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class CircularCardsSection extends StatelessWidget {
  const CircularCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: 8, // Placeholder count
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _CircularCard(index: index),
          );
        },
      ),
    );
  }
}

class _CircularCard extends StatelessWidget {
  final int index;

  const _CircularCard({required this.index});

  @override
  Widget build(BuildContext context) {
    // Placeholder for card content
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.cardBackground,
        border: Border.all(
          color:
              index % 2 == 0 ? AppColors.primaryGreen : AppColors.primaryYellow,
          width: 2,
        ),
      ),
      child: Center(
        child: index < 2
            ? const Text(
                'Content',
                style: TextStyle(color: AppColors.white),
              )
            : Text(
                index == 2 ? AppStrings.hadith : AppStrings.dua,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}
