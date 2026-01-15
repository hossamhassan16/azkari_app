import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'screens/home/home_screen.dart';
import 'services/quran_settings_service.dart';
import 'services/azkar_service.dart';
import 'services/quran_duas_service.dart';
import 'services/tasbeh_service.dart';
import 'services/story_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  Intl.defaultLocale = 'ar';
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar');

  // Initialize services
  await AzkarService().init();
  await QuranSettingsService().init();
  await QuranDuasService().init();
  await TasbehService().init();
  await StoryService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'أذكاري',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryGreen,
          secondary: AppColors.primaryYellow,
          surface: AppColors.cardBackground,
          background: AppColors.darkBackground,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
