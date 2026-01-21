import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/nawawi_hadith_model.dart';
import '../../services/nawawi_hadith_service.dart';
import 'nawawi_hadith_detail_screen.dart';

class NawawiHadithsListScreen extends StatefulWidget {
  const NawawiHadithsListScreen({super.key});

  @override
  State<NawawiHadithsListScreen> createState() =>
      _NawawiHadithsListScreenState();
}

class _NawawiHadithsListScreenState extends State<NawawiHadithsListScreen> {
  final NawawiHadithService _service = NawawiHadithService();
  List<NawawiHadithModel> _hadiths = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHadiths();
  }

  Future<void> _loadHadiths() async {
    try {
      final hadiths = await _service.loadHadiths();
      if (mounted) {
        setState(() {
          _hadiths = hadiths;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
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
          'الأربعون النووية',
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
          : _error != null
              ? Center(
                  child: Text(
                    'خطأ: $_error',
                    style: const TextStyle(color: AppColors.white),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _hadiths.length,
                  itemBuilder: (context, index) {
                    return _buildHadithCard(_hadiths[index]);
                  },
                ),
    );
  }

  Widget _buildHadithCard(NawawiHadithModel hadith) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NawawiHadithDetailScreen(hadith: hadith),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryGreen.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'الحديث ${hadith.number}',
              style: const TextStyle(
                color: Color.fromARGB(255, 129, 126, 126),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Text(
              hadith.title,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
