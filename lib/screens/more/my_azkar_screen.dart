import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../models/quran_dua_model.dart';
import '../../services/quran_duas_service.dart';

class MyAzkarScreen extends StatefulWidget {
  const MyAzkarScreen({super.key});

  @override
  State<MyAzkarScreen> createState() => _MyAzkarScreenState();
}

class _MyAzkarScreenState extends State<MyAzkarScreen> {
  final QuranDuasService _service = QuranDuasService();
  List<QuranDuaModel> _myAzkar = [];
  bool _isLoading = true;
  double _fontSize = 24.0;

  @override
  void initState() {
    super.initState();
    _loadMyAzkar();
  }

  Future<void> _loadMyAzkar() async {
    try {
      final azkar = await _service.getMyAzkar();
      if (mounted) {
        setState(() {
          _myAzkar = azkar;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDuaMenu(QuranDuaModel dua) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
            const SizedBox(height: 16),
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.greyText.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _buildMenuItem(
              icon: Icons.delete_outline,
              label: 'حذف من أذكاري',
              onTap: () async {
                await _service.removeFromMyAzkar(dua.id);
                if (mounted) {
                  Navigator.pop(context);
                  _loadMyAzkar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم الحذف من أذكاري'),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                }
              },
            ),
            _buildMenuItem(
              icon: Icons.share_outlined,
              label: 'مشاركة',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('سيتم إضافة هذه الميزة قريباً'),
                    backgroundColor: AppColors.primaryGreen,
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.content_copy_outlined,
              label: 'نسخ',
              onTap: () {
                Clipboard.setData(ClipboardData(text: dua.content));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم نسخ الدعاء'),
                    backgroundColor: AppColors.primaryGreen,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              icon,
              color: AppColors.white,
              size: 24,
            ),
          ],
        ),
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
          'أذكاري',
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
          : _myAzkar.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        size: 80,
                        color: AppColors.greyText,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'لا توجد أذكار محفوظة',
                        style: TextStyle(
                          color: AppColors.greyText,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'أضف أذكارك المفضلة من الأدعية القرآنية',
                        style: TextStyle(
                          color: AppColors.greyText,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _myAzkar.length,
                  itemBuilder: (context, index) {
                    return _buildDuaCard(_myAzkar[index]);
                  },
                ),
    );
  }

  Widget _buildDuaCard(QuranDuaModel dua) {
    final isCompleted = dua.currentCount == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Three dots menu button
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(
                Icons.more_vert,
                color: AppColors.white,
              ),
              onPressed: () => _showDuaMenu(dua),
            ),
          ),
          // Dua content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  dua.content,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: _fontSize,
                    height: 1.8,
                    // fontFamily: 'AmiriQuran',
                  ),
                ),
                if (dua.reference.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    dua.reference,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.greyText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Counter section at the bottom
          GestureDetector(
            onTap: dua.currentCount > 0
                ? () async {
                    final newCount = dua.currentCount - 1;
                    await _service.saveMyAzkarProgress(dua.id, newCount);

                    // Vibrate when reaching zero
                    if (newCount == 0) {
                      HapticFeedback.heavyImpact();
                    }

                    _loadMyAzkar(); // Reload to update UI
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.red
                    : const Color.fromARGB(255, 49, 113, 52),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Text(
                  isCompleted ? '✓' : '${dua.currentCount}',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
