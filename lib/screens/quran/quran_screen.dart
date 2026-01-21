import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/quran/quran_app_bar.dart';
import '../../widgets/quran/tab_selector.dart';
import 'surah_list_view.dart';
import 'juz_list_view.dart';
import 'verse_search_view.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<SurahListViewState> _surahListViewKey = GlobalKey();
  final GlobalKey<JuzListViewState> _juzListViewKey = GlobalKey();
  final GlobalKey<VerseSearchViewState> _searchViewKey = GlobalKey();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String value) {
    if (_selectedTabIndex == 0) {
      // Search in Surahs
      _surahListViewKey.currentState?.searchSurahs(value);
    } else if (_selectedTabIndex == 1) {
      // Search in Juzs
      _juzListViewKey.currentState?.searchJuzs(value);
    } else if (_selectedTabIndex == 2) {
      // Search in Verses
      _searchViewKey.currentState?.searchVerses(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: QuranAppBar(
        searchController: _searchController,
        onSearchChanged: _handleSearch,
      ),
      body: Column(
        children: [
          TabSelector(
            selectedIndex: _selectedTabIndex,
            onTabChanged: (index) {
              setState(() {
                _selectedTabIndex = index;
                _searchController.clear();
                // Reset search results for all tabs
                _surahListViewKey.currentState?.searchSurahs('');
                _juzListViewKey.currentState?.searchJuzs('');
                _searchViewKey.currentState?.searchVerses('');
              });
            },
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                SurahListView(key: _surahListViewKey),
                JuzListView(key: _juzListViewKey),
                VerseSearchView(key: _searchViewKey),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
