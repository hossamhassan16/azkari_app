import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Display option widget (horizontal/vertical radio button)
class DisplayOptionWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const DisplayOptionWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.white, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primaryGreen : AppColors.greyText,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

/// Checkbox option widget with title and description
class CheckboxOptionWidget extends StatelessWidget {
  final String title;
  final String description;
  final bool value;
  final Function(bool?) onChanged;

  const CheckboxOptionWidget({
    super.key,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.primaryGreen,
              ),
              Expanded(
                child: Text(
                  description,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppColors.greyText,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Font size slider widget
class FontSizeSliderWidget extends StatelessWidget {
  final double fontSize;
  final ValueChanged<double> onChanged;

  const FontSizeSliderWidget({
    super.key,
    required this.fontSize,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'حجم الخط',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text(
              '12',
              style: TextStyle(color: AppColors.greyText),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppColors.primaryGreen,
                  inactiveTrackColor: AppColors.greyText.withOpacity(0.3),
                  thumbColor: AppColors.primaryGreen,
                  overlayColor: AppColors.primaryGreen.withOpacity(0.3),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: fontSize,
                  min: 12,
                  max: 60,
                  divisions: 48,
                  onChanged: onChanged,
                ),
              ),
            ),
            const Text(
              '60',
              style: TextStyle(color: AppColors.greyText),
            ),
          ],
        ),
        Center(
          child: Text(
            '${fontSize.round()}',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
