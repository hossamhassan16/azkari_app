import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/azkar_category_model.dart';

/// Exit confirmation dialog for Azkar
class AzkarExitDialog {
  /// Show exit confirmation dialog if needed
  static Future<bool> show({
    required BuildContext context,
    required bool confirmExit,
    required AzkarCategoryModel category,
  }) async {
    if (!confirmExit) {
      return true;
    }

    // Check if any azkar are incomplete
    final hasIncomplete = category.azkar.any((z) => z.currentCount > 0);
    if (!hasIncomplete) {
      return true;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'تأكيد الخروج',
          style: TextStyle(color: AppColors.white),
          textAlign: TextAlign.right,
        ),
        content: const Text(
          'لم تنهي جميع الأذكار، هل تريد الخروج؟',
          style: TextStyle(color: AppColors.white),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: AppColors.greyText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'خروج',
              style: TextStyle(color: AppColors.primaryGreen),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
