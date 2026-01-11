import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class TabSelector extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChanged;

  const TabSelector({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBackground,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _TabItem(
            label: AppStrings.surah,
            isSelected: selectedIndex == 0,
            onTap: () => onTabChanged(0),
          ),
          _TabItem(
            label: AppStrings.juz,
            isSelected: selectedIndex == 1,
            onTap: () => onTabChanged(1),
          ),
          _TabItem(
            label: AppStrings.ayah,
            isSelected: selectedIndex == 2,
            onTap: () => onTabChanged(2),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primaryGreen : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primaryGreen : AppColors.white,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

