import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class BasmalaSection extends StatelessWidget {
  const BasmalaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Center(
        child: Text(
          AppStrings.basmala,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.primaryGreen,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
