import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/nawawi_hadith_model.dart';

class NawawiHadithDetailScreen extends StatelessWidget {
  final NawawiHadithModel hadith;

  const NawawiHadithDetailScreen({
    super.key,
    required this.hadith,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'الحديث ${hadith.number}',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Title section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    hadith.title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Hadith text section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'نص الحديث:',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    hadith.hadithText,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      height: 1.8,
                      fontFamily: 'Amiri',
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Description section
            if (hadith.description.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'شرح وفوائد الحديث:',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      hadith.description,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
