import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class EncouragementSection extends StatelessWidget {
  const EncouragementSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            AppStrings.encouragement,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.share,
              color: AppColors.white,
            ),
            onPressed: () {
              // Handle share
            },
          ),
        ],
      ),
    );
  }
}

