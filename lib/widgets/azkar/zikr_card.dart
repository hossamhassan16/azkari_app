import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/zikr_model.dart';

class ZikrCard extends StatelessWidget {
  final ZikrModel zikr;
  final VoidCallback onCounterTap;
  final VoidCallback? onEdit;
  final bool isHorizontal;
  final double fontSize;

  const ZikrCard({
    super.key,
    required this.zikr,
    required this.onCounterTap,
    this.onEdit,
    this.isHorizontal = false,
    this.fontSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      constraints: isHorizontal
          ? BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9)
          : null,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pre-text (if exists)
          if (zikr.preText != null && zikr.preText!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Text(
                zikr.preText!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.greyText,
                  fontSize: fontSize * 0.7,
                ),
              ),
            ),

          // Main content
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              zikr.content,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white,
                fontSize: fontSize,
                height: 1.6,
              ),
            ),
          ),

          // Description (if exists)
          if (zikr.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                zikr.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.greyText,
                  fontSize: fontSize * 0.65,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          // Reference (if exists)
          if (zikr.reference.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Text(
                zikr.reference,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryYellow,
                  fontSize: fontSize * 0.55,
                ),
              ),
            ),
          const SizedBox(height: 4),
          // Counter section
          GestureDetector(
            onTap: zikr.currentCount > 0 ? onCounterTap : null,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: zikr.currentCount > 0
                    ? const Color.fromARGB(255, 49, 113, 52)
                    : Colors.red,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${zikr.currentCount}',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: fontSize * 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (onEdit != null) ...[
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit,
                          color: AppColors.white, size: 20),
                      onPressed: onEdit,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
