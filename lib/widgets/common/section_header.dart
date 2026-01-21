import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onShare;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              if (trailing != null) trailing!,
              if (onShare != null)
                IconButton(
                  icon: const Icon(
                    Icons.share,
                    color: AppColors.white,
                    size: 20,
                  ),
                  onPressed: onShare,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

