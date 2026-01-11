import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../common/section_header.dart';

class ShortcutsSection extends StatelessWidget {
  const ShortcutsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: AppStrings.shortcuts),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _ShortcutItem(index: index),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ShortcutItem extends StatelessWidget {
  final int index;

  const _ShortcutItem({required this.index});

  String getShortcutLabel(int index) {
    switch (index) {
      case 0:
        return AppStrings.prayWithMe;
      case 1:
        return AppStrings.remembranceCircles;
      case 2:
        return AppStrings.electronicRosary;
      case 3:
        return AppStrings.howDoYouFeel;
      case 4:
        return AppStrings.readKhatmah;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryGreen,
          ),
          child: const Icon(
            Icons.star,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            getShortcutLabel(index),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
