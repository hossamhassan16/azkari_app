import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/quran/juz_card.dart';
import '../../services/quran_api_service.dart';
import 'juz_detail_screen.dart';

class JuzListView extends StatefulWidget {
  const JuzListView({super.key});

  @override
  State<JuzListView> createState() => JuzListViewState();
}

class JuzListViewState extends State<JuzListView> {
  final QuranApiService _apiService = QuranApiService();
  List<int> _filteredJuzs = List.generate(30, (i) => i + 1);

  void searchJuzs(String query) {
    if (!mounted) return;
    setState(() {
      _filteredJuzs = _apiService.searchJuzs(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkBackground,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: _filteredJuzs.length,
        itemBuilder: (context, index) {
          return JuzCard(
            juzNumber: _filteredJuzs[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JuzDetailScreen(juzNumber: _filteredJuzs[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

