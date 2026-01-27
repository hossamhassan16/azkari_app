import 'package:azkari_app/services/audio_service.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/surah_model.dart';
import '../../widgets/quran/surah_card.dart';
import '../../services/quran_api_service.dart';
import 'surah_detail_screen.dart';

class SurahListView extends StatefulWidget {
  const SurahListView({super.key});

  @override
  State<SurahListView> createState() => SurahListViewState();
}

class SurahListViewState extends State<SurahListView> {
  final QuranApiService _apiService = QuranApiService();
  List<SurahModel> _allSurahs = [];
  List<SurahModel> _filteredSurahs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    try {
      final surahs = await _apiService.getAllSurahs();
      if (!mounted) return;
      setState(() {
        _allSurahs = surahs;
        _filteredSurahs = surahs;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void searchSurahs(String query) async {
    if (!mounted) return;

    if (query.trim().isEmpty) {
      setState(() {
        _filteredSurahs = _allSurahs;
      });
      return;
    }

    try {
      final results = await _apiService.searchSurahs(query);
      if (!mounted) return;
      setState(() {
        _filteredSurahs = results;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _filteredSurahs = _allSurahs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: AppColors.darkBackground,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryGreen,
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        color: AppColors.darkBackground,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'حدث خطأ في تحميل البيانات',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadSurahs,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                ),
                child: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(color: AppColors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: AppColors.darkBackground,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
        ),
        itemCount: _filteredSurahs.length,
        itemBuilder: (context, index) {
          return SurahCard(
            surah: _filteredSurahs[index],
            onTap: () {
              // 1. حفظ رقم السورة المختارة في خدمة الصوت
              AudioService().selectSurah(_filteredSurahs[index].number);

              // 2. الانتقال لصفحة التفاصيل كما كنت تفعل
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SurahDetailScreen(
                    surah: _filteredSurahs[index],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
