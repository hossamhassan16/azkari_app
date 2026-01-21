import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../cubits/azkar/azkar_categories_cubit.dart';
import '../../services/azkar_service.dart';
import '../../widgets/azkar/azkar_category_card.dart';
import 'azkar_detail_screen.dart';

class AzkarScreen extends StatelessWidget {
  const AzkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AzkarCategoriesCubit(AzkarService())..loadCategories(),
      child: const AzkarScreenView(),
    );
  }
}

class AzkarScreenView extends StatelessWidget {
  const AzkarScreenView({super.key});

  void _showAddCategoryDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'إضافة مجموعة أذكار',
          style: TextStyle(color: AppColors.white),
          textAlign: TextAlign.right,
        ),
        content: TextField(
          controller: controller,
          textAlign: TextAlign.right,
          style: const TextStyle(color: AppColors.white),
          decoration: InputDecoration(
            hintText: 'اضافة مجموعة أذكار',
            hintStyle: TextStyle(color: AppColors.greyText),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.greyText),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryGreen),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: AppColors.yellowAccent),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await context
                    .read<AzkarCategoriesCubit>()
                    .addCustomCategory(controller.text);
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              }
            },
            child: const Text(
              'اضافة',
              style: TextStyle(color: AppColors.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

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
        title: const Text(
          'أذكار المسلم',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocConsumer<AzkarCategoriesCubit, AzkarCategoriesState>(
        listener: (context, state) {
          if (state is AzkarCategoriesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is AzkarCategoriesLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (state is AzkarCategoriesLoaded) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                return AzkarCategoryCard(
                  category: state.categories[index],
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AzkarDetailScreen(
                          category: state.categories[index],
                        ),
                      ),
                    );
                    if (context.mounted) {
                      context.read<AzkarCategoriesCubit>().refreshCategories();
                    }
                  },
                );
              },
            );
          }

          return const Center(
            child: Text(
              'لا توجد بيانات',
              style: TextStyle(color: AppColors.white, fontSize: 18),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add, color: AppColors.white, size: 32),
      ),
    );
  }
}
