import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/duaa_item_model.dart';

class DuaCard extends StatelessWidget {
  final DuaItemModel dua;
  final VoidCallback onCounterTap;
  final VoidCallback? onEdit;
  final bool isHorizontal;
  final double fontSize;

  const DuaCard({
    super.key,
    required this.dua,
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
          // Main content
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              dua.content,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white,
                fontSize: fontSize,
                height: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Counter section
          GestureDetector(
            onTap: dua.currentCount > 0 ? onCounterTap : null,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: dua.currentCount > 0
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
                    '${dua.currentCount}',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: fontSize * 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (onEdit != null) ...[
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: AppColors.white,
                        size: 20,
                      ),
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
