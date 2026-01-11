import 'package:azkari_app/widgets/azkar/azkar_progress_card.dart';
import 'package:flutter/material.dart';

class AzkarCategoriesPage extends StatelessWidget {
  const AzkarCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<AzkarCategoryModel> categories = [
      AzkarCategoryModel(title: 'أذكار الصباح', progress: 0.6),
      AzkarCategoryModel(title: 'أذكار المساء', progress: 0.3),
      AzkarCategoryModel(title: 'أذكار الصلاة', progress: 1.0),
      AzkarCategoryModel(title: 'أذكار بعد الصلاة', progress: 0.0),
      AzkarCategoryModel(title: 'أذكار الأذان', progress: 0.2),
      AzkarCategoryModel(title: 'أذكار النوم', progress: 0.8),
      AzkarCategoryModel(title: 'أذكار الاستيقاظ', progress: 0.4),
      AzkarCategoryModel(title: 'أذكار المسجد', progress: 0.1),
      AzkarCategoryModel(title: 'أذكار الوضوء', progress: 0.0),
      AzkarCategoryModel(title: 'أذكار المنزل', progress: 0.5),
      AzkarCategoryModel(title: 'أذكار الطعام', progress: 0.7),
      AzkarCategoryModel(title: 'أذكار الخلاء', progress: 0.9),
      AzkarCategoryModel(title: 'أذكار السفر', progress: 0.0),
      AzkarCategoryModel(title: 'أذكار أخرى', progress: 0.0),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'أذكار المسلم',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.6,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];

            return AzkarProgressCard(
              title: category.title,
              progress: category.progress,
              onTap: () {
                // TODO: Navigate to Azkar details page
                // Navigator.push(context, ...)
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2ECC71),
        onPressed: () {
          // TODO: Add new Azkar
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AzkarCategoryModel {
  final String title;
  final double progress;

  AzkarCategoryModel({
    required this.title,
    required this.progress,
  });
}
