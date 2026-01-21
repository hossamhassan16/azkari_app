import 'package:azkari_app/core/constants/app_colors.dart';
import 'package:azkari_app/widgets/ramadan/ramadan_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RamadanDetailScreen extends StatefulWidget {
  final String title;
  final String jsonKey;

  const RamadanDetailScreen({
    super.key,
    required this.title,
    required this.jsonKey,
  });

  @override
  State<RamadanDetailScreen> createState() => _RamadanDetailScreenState();
}

class _RamadanDetailScreenState extends State<RamadanDetailScreen> {
  final _repository = RamadanRepository();
  List<String> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _repository.getDetailsByTitle(widget.jsonKey);
      setState(() {
        _items = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
              ),
            )
          : _items.isEmpty
              ? const Center(
                  child: Text(
                    'لا توجد بيانات',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    
                    // Skip empty strings and the first item (which is usually the title)
                    if (item.trim().isEmpty || index == 0) {
                      return const SizedBox.shrink();
                    }

                    return _buildContentCard(item);
                  },
                ),
    );
  }

  Widget _buildContentCard(String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Three dots menu
          Align(
            alignment: Alignment.topLeft,
            child: PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_horiz,
                color: AppColors.greyText,
              ),
              color: AppColors.cardBackground,
              onSelected: (value) {
                if (value == 'copy') {
                  _copyToClipboard(content);
                } else if (value == 'share') {
                  _shareContent(content);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share, color: AppColors.white, size: 20),
                      SizedBox(width: 12),
                      Text(
                        'مشاركة',
                        style: TextStyle(color: AppColors.white),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'copy',
                  child: Row(
                    children: [
                      Icon(Icons.copy, color: AppColors.white, size: 20),
                      SizedBox(width: 12),
                      Text(
                        'نسخ',
                        style: TextStyle(color: AppColors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Text(
              content,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                height: 2.0,
                fontFamily: 'Amiri',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم النسخ إلى الحافظة'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  void _shareContent(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم النسخ - يمكنك مشاركته الآن'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }
}
