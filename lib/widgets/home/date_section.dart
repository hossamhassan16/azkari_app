import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class DateSection extends StatelessWidget {
  const DateSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'اليوم: 14 - رجب- 1447 (03 - يناير- 2026)', // Placeholder date
            style: TextStyle(
              color: AppColors.white,
              fontSize: 14,
            ),
          ),
          TextButton.icon(
            onPressed: () {
              // Handle edit date
            },
            icon: const Icon(
              Icons.edit,
              color: AppColors.white,
              size: 18,
            ),
            label: const Text(
              AppStrings.edit,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
