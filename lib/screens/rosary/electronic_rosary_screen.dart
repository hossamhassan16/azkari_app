import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/tasbeh_item_model.dart';
import '../../services/tasbeh_service.dart';
import 'tasbeh_detail_screen.dart';

class ElectronicRosaryScreen extends StatefulWidget {
  const ElectronicRosaryScreen({super.key});

  @override
  State<ElectronicRosaryScreen> createState() => _ElectronicRosaryScreenState();
}

class _ElectronicRosaryScreenState extends State<ElectronicRosaryScreen> {
  final TasbehService _tasbehService = TasbehService();
  List<TasbehItemModel> _tasbehList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasbeh();
  }

  Future<void> _loadTasbeh() async {
    try {
      final tasbeh = await _tasbehService.loadTasbeh();
      if (mounted) {
        setState(() {
          _tasbehList = tasbeh;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل المسبحة: $e')),
        );
      }
    }
  }

  void _showAddTasbehDialog() {
    final nameController = TextEditingController();
    final benefitController = TextEditingController();
    final countController = TextEditingController(text: '33');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'إضافة ذكر للمسبحة',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.right,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              textAlign: TextAlign.right,
              style: const TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'الذكر',
                hintStyle: TextStyle(color: AppColors.greyText),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.greyText),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryGreen),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: benefitController,
              textAlign: TextAlign.right,
              style: const TextStyle(color: AppColors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'الفائدة',
                hintStyle: TextStyle(color: AppColors.greyText),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.greyText),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryGreen),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: countController,
              textAlign: TextAlign.right,
              style: const TextStyle(color: AppColors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'عدد الحبات',
                hintStyle: TextStyle(color: AppColors.greyText),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.greyText),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryGreen),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: AppColors.greyText, fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  countController.text.isNotEmpty) {
                final newTasbeh = TasbehItemModel(
                  id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameController.text,
                  beadsCount: int.tryParse(countController.text) ?? 33,
                  benefit: benefitController.text,
                );
                await _tasbehService.addTasbeh(newTasbeh);
                await _loadTasbeh();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تمت الإضافة بنجاح'),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'إضافة',
              style: TextStyle(color: AppColors.primaryGreen, fontSize: 16),
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
          'المسبحة الالكترونية (5)',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tasbehList.length,
              itemBuilder: (context, index) {
                final tasbeh = _tasbehList[index];
                return _buildTasbehCard(tasbeh);
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryGreen,
        onPressed: _showAddTasbehDialog,
        child: const Icon(Icons.add, color: AppColors.white, size: 32),
      ),
    );
  }

  Widget _buildTasbehCard(TasbehItemModel tasbeh) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TasbehDetailScreen(tasbehId: tasbeh.id),
          ),
        );
        _loadTasbeh(); // Refresh data when returning
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Three dots menu
            Align(
              alignment: Alignment.topLeft,
              child: Icon(
                Icons.more_vert,
                color: AppColors.white.withOpacity(0.5),
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            // Tasbeh name
            Text(
              tasbeh.name,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 20),
            // Counts row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Total count
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'عدد الحبات',
                      style: TextStyle(
                        color: AppColors.greyText,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${tasbeh.beadsCount}',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Current/Total count
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'عدد المرات الاجمالي',
                      style: TextStyle(
                        color: AppColors.greyText,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${tasbeh.totalCount}',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Cycle and current count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'العدد الحالي',
                      style: TextStyle(
                        color: AppColors.greyText,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${tasbeh.currentCount}',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'دورة',
                      style: TextStyle(
                        color: AppColors.greyText,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${tasbeh.cycleCount}',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
