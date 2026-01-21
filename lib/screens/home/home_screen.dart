import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/ad_banner.dart';
import '../../widgets/navigation/bottom_nav_bar.dart';
import '../../widgets/home/basmala_section.dart';
import '../../widgets/home/circular_cards_section.dart';
import '../../widgets/home/date_section.dart';
import '../../widgets/home/shortcuts_section.dart';
import '../../widgets/home/encouragement_section.dart';
import '../../widgets/home/ramadan_countdown_section.dart';
import '../../widgets/home/khatmah_section.dart';
import '../../widgets/home/habit_tracker_section.dart';
import '../../widgets/home/verse_of_day_section.dart';
import '../../widgets/home/hadith_of_day_section.dart';
import '../../widgets/home/question_of_day_section.dart';
import '../../widgets/home/prayer_of_day_section.dart';
import '../../widgets/home/beautiful_names_section.dart';
import '../quran/quran_screen.dart';
import '../azkar/azkar_screen.dart';
import '../more/more_screen.dart';
import '../notifications/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;

  // ✅ List of screens for IndexedStack
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Initialize screens once
    _screens = [
      _buildHomeScreen(), // Index 0: Home
      const NotificationsScreen(), // Index 1: Notifications
      const QuranScreen(), // Index 2: Quran
      const AzkarScreen(), // Index 3: Azkar
      const MoreScreen(), // Index 4: More
    ];
  }

  // Build home screen content
  Widget _buildHomeScreen() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basmala Section
          const BasmalaSection(),

          // Circular Cards Section
          const CircularCardsSection(),

          // Date Section
          const DateSection(),

          // Shortcuts Section
          const ShortcutsSection(),

          const SizedBox(height: 16),

          // Encouragement Section
          const EncouragementSection(),

          // Ramadan Countdown Section
          const RamadanCountdownSection(),

          // Khatmah Section
          const KhatmahSection(),

          const SizedBox(height: 16),

          // Habit Tracker Section
          const HabitTrackerSection(),

          const SizedBox(height: 16),

          // Verse of the Day Section
          const VerseOfDaySection(),

          const SizedBox(height: 16),

          // Hadith of the Day Section
          const HadithOfDaySection(),

          const SizedBox(height: 16),

          // Question of the Day Section
          const QuestionOfDaySection(),

          const SizedBox(height: 16),

          // Prayer of the Day Section
          const PrayerOfDaySection(),

          const SizedBox(height: 16),

          // Beautiful Names Section
          const BeautifulNamesSection(),

          const SizedBox(height: 16),

          // Ad Banner
          const AdBanner(),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ✅ Simple navigation - just update index
  void _onNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar (only show on Home screen)
            if (_currentNavIndex == 0) const CustomAppBar(),

            // ✅ IndexedStack: Shows selected screen, keeps others in memory
            Expanded(
              child: IndexedStack(
                index: _currentNavIndex,
                children: _screens,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
