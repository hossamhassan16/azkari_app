import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/azkar_category_model.dart';
import '../../services/azkar_service.dart';
import '../../widgets/azkar/azkar_category_card.dart';
import '../../widgets/navigation/bottom_nav_bar.dart';
import 'azkar_detail_screen.dart';

class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {
  final AzkarService _azkarService = AzkarService();
  List<AzkarCategoryModel> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _azkarService.loadAzkarCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل البيانات: $e')),
        );
      }
    }
  }

  void _showAddCategoryDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: AppColors.yellowAccent),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _azkarService.addCustomCategory(controller.text);
                if (mounted) {
                  Navigator.pop(context);
                  _loadCategories();
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return AzkarCategoryCard(
                  category: _categories[index],
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AzkarDetailScreen(
                          category: _categories[index],
                        ),
                      ),
                    );
                    _loadCategories();
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add, color: AppColors.white, size: 32),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTap: (index) {
          if (index != 3) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}
