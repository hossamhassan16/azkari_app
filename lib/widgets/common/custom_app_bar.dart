import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Profile icon
          const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.cardBackground,
            child: Icon(
              Icons.person,
              color: AppColors.white,
            ),
          ),
          // App title
          const Text(
            AppStrings.appName,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Remove ads button
          ElevatedButton(
            onPressed: () {
              // Handle remove ads
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              AppStrings.removeAds,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

