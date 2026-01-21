import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../models/ayah_model.dart';
import '../screens/quran/tafseer_screen.dart';

class AyahMenuBottomSheet extends StatelessWidget {
  final AyahModel ayah;
  final VoidCallback onBookmarkTap;

  const AyahMenuBottomSheet({
    super.key,
    required this.ayah,
    required this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle indicator
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Ayah text with surah name
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ayah text
                Text(
                  ayah.text,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'AmiriQuran',
                    color: AppColors.white,
                    fontSize: 20,
                    height: 2,
                  ),
                ),
                const SizedBox(height: 12),
                // Surah name and ayah number
                Text(
                  '(${ayah.surahName}) ﴿${ayah.number}﴾',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'AmiriQuran',
                    color: AppColors.primaryGreen,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Menu options
          _buildMenuItem(
            context,
            icon: Icons.play_arrow,
            title: 'اقرأ الآية',
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement audio playback
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('سيتم إضافة هذه الميزة قريباً'),
                  backgroundColor: AppColors.primaryGreen,
                ),
              );
            },
          ),

          _buildMenuItem(
            context,
            icon: Icons.bookmark_border,
            title: 'إضافة علامة مرجعية',
            onTap: () {
              Navigator.pop(context);
              onBookmarkTap();
            },
          ),

          _buildMenuItem(
            context,
            icon: Icons.lightbulb_outline,
            title: 'تفسير الآية',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TafseerScreen(ayah: ayah),
                ),
              );
            },
          ),

          _buildMenuItem(
            context,
            icon: Icons.copy,
            title: 'نسخ',
            onTap: () {
              Clipboard.setData(ClipboardData(text: ayah.text));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم نسخ الآية'),
                  backgroundColor: AppColors.primaryGreen,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),

          _buildMenuItem(
            context,
            icon: Icons.share,
            title: 'مشارك',
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement sharing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('سيتم إضافة هذه الميزة قريباً'),
                  backgroundColor: AppColors.primaryGreen,
                ),
              );
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.white,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
