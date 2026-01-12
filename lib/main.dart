import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'screens/home/home_screen.dart';
import 'services/quran_settings_service.dart';
import 'services/azkar_service.dart';
import 'services/quran_duas_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await AzkarService().init();
  await QuranSettingsService().init();
  await QuranDuasService().init();

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
