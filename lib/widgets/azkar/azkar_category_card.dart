import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/azkar_category_model.dart';

class AzkarCategoryCard extends StatelessWidget {
  final AzkarCategoryModel category;
  final VoidCallback onTap;

  const AzkarCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Progress bar at the top
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: LinearProgressIndicator(
                value: category.progress,
                backgroundColor: AppColors.greyText.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryGreen,
                ),
                minHeight: 8,
              ),
            ),

            // Category name
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    category.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
