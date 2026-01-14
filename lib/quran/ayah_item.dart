import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/ayah_model.dart';
import 'ayah_menu_bottom_sheet.dart';

class AyahItem extends StatelessWidget {
  final AyahModel ayah;
  final VoidCallback onBookmarkTap;
  final double? fontSize;

  const AyahItem({
    super.key,
    required this.ayah,
    required this.onBookmarkTap,
    this.fontSize,
  });

  void _showAyahMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AyahMenuBottomSheet(
        ayah: ayah,
        onBookmarkTap: onBookmarkTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAyahMenu(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ayah.number == 1
              ? AppColors.primaryGreen.withOpacity(0.2)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bookmark icon on the left
            GestureDetector(
              onTap: () {
                onBookmarkTap();
              },
              child: Icon(
                ayah.isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: ayah.isSaved ? AppColors.primaryGreen : AppColors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Ayah text
            Expanded(
              child: Text(
                ayah.text,
                style: TextStyle(
                  fontFamily: 'AmiriQuran',
                  color: AppColors.white,
                  fontSize: fontSize ?? 18,
                  height: 1.8,
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
            ),
            const SizedBox(width: 12),
            // Verse number on the right
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cardBackground,
                border: Border.all(
                  color: AppColors.primaryGreen,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '${ayah.number}',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
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
