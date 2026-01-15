import 'package:azkari_app/screens/azkar/azkar_screen.dart';
import 'package:azkari_app/screens/more/allah_names_screen.dart';
import 'package:azkari_app/screens/more/anbyaa_duas_screen.dart';
import 'package:azkari_app/screens/more/feelings_screen.dart';
import 'package:azkari_app/screens/more/friday_sona_screen.dart';
import 'package:azkari_app/screens/more/hamd_screen.dart';
import 'package:azkari_app/screens/more/istighfar_screen.dart';
import 'package:azkari_app/screens/more/nabaywa_duas_screen.dart';
import 'package:azkari_app/screens/more/nawawi_hadiths_list_screen.dart';
import 'package:azkari_app/screens/more/quran_duas_screen.dart';
import 'package:azkari_app/screens/more/my_azkar_screen.dart';
import 'package:azkari_app/screens/more/ramadan_categories_screen.dart';
import 'package:azkari_app/screens/more/roqaya_sharyaa_screen.dart';
import 'package:azkari_app/screens/more/tasbeh_screen.dart';
import 'package:azkari_app/screens/qibla/qibla_compass_screen.dart';
import 'package:azkari_app/screens/quran/quran_screen.dart';
import 'package:azkari_app/screens/rosary/electronic_rosary_screen.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/navigation/bottom_nav_bar.dart';
import '../../widgets/more/more_item_button.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.nightlight_round,
                      color: AppColors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      // TODO: Toggle theme
                    },
                  ),
                  const Text(
                    'المزيد',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the layout
                ],
              ),
            ),

            // Grid of items
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                padding: const EdgeInsets.all(8),
                mainAxisSpacing: 24,
                crossAxisSpacing: 0,
                childAspectRatio: 0.85,
                children: [
                  // Row 1
                  MoreItemButton(
                    icon: Icons.people,
                    label: 'ادعو معي',
                    onTap: () {},
                  ),
                  MoreItemButton(
                    icon: Icons.auto_awesome,
                    label: 'حلقات الذكر',
                    onTap: () {},
                  ),
                  MoreItemButton(
                    icon: Icons.settings,
                    label: 'الإعدادات',
                    onTap: () {},
                  ),
                  MoreItemButton(
                    icon: Icons.circle_outlined,
                    label: 'المسبحة الالكترونية',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ElectronicRosaryScreen(),
                        ),
                      );
                    },
                  ),

                  // Row 2
                  MoreItemButton(
                    icon: Icons.text_fields,
                    label: 'أسماء الله الحسنى',
                    customText: 'الله',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllahNamesScreen(),
                        ),
                      );
                    },
                  ),
                  MoreItemButton(
                    icon: Icons.emoji_emotions_outlined,
                    label: 'بماذا تشعر؟',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FeelingsScreen(),
                        ),
                      );
                    },
                  ),
                  MoreItemButton(
                    icon: Icons.auto_stories,
                    label: 'أذكار المسلم',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AzkarScreen(),
                        ),
                      );
                    },
                  ),
                  MoreItemButton(
                    icon: Icons.bar_chart,
                    label: 'إحصائيات',
                    onTap: () {},
                  ),

                  // Row 3
                  MoreItemButton(
                    icon: Icons.edit_note,
                    label: 'أذكاري',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyAzkarScreen(),
                        ),
                      );
                    },
                  ),
                  MoreItemButton(
                    icon: Icons.menu_book,
                    label: 'قرآن',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QuranScreen(),
                        ),
                      );
                    },
                  ),
                  MoreItemButton(
                    icon: Icons.explore,
                    label: 'بوصلة القبلة',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QiblaCompassScreen(),
                        ),
                      );
                    },
                  ),
                  MoreItemButton(
                    icon: Icons.check_box_outlined,
                    label: 'متعقب العادة',
                    onTap: () {},
                  ),

                  // Row 4
                  MoreItemButton(
                    icon: Icons.sentiment_dissatisfied_outlined,
                    label: 'الرقية الشرعية',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RoqayaSharyaaScreen(),
                        ),
                      );
                    },
                  ),
                  MoreItemButton(
                    icon: Icons.person_outline,
                    label: 'استغفار',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IstighfarScreen(),
                        ),
                      );
                    },
                  ),
                  MoreItemButton(
                    icon: Icons.mosque,
                    label: 'الحمد',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HamdScreen(),
                        ),
                      );
                    },
                  ),
                  MoreItemButton(
                    icon: Icons.whatshot_outlined,
                    label: 'تسبيح',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TasbehScreen(),
                        ),
                      );
                    },
                  ),

                  // Row 5
                  MoreItemButton(
                    icon: Icons.book,
                    label: 'الاربعون النووية',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NawawiHadithsListScreen(),
                        ),
                      );
                    },
                  ),
                  MoreItemButton(
                    icon: Icons.person,
                    label: 'ادعية الانبياء',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AnbyaaDuasScreen(),
                        ),
                      );
                    },
                  ),
                  MoreItemButton(
                    icon: Icons.star_border,
                    label: 'ادعية نبوية',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NabaywaDuasScreen(),
                        ),
                      );
                    },
                  ),
                  MoreItemButton(
                    icon: Icons.menu_book_outlined,
                    label: 'ادعية قرآنية',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QuranDuasScreen(),
                        ),
                      );
                    },
                  ),
                  // Row 6
                  MoreItemButton(
                    icon: Icons.book,
                    label: 'سنن الجمعة',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FridaySonaScreen(),
                        ),
                      );
                    },
                  ),
                  MoreItemButton(
                    icon: Icons.person,
                    label: 'رمضان',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RamadanPage(),
                        ),
                      );
                    },
                  ),
                  MoreItemButton(
                    icon: Icons.star_border,
                    label: 'ختمة',
                    onTap: () {},
                  ),
                  MoreItemButton(
                    icon: Icons.menu_book_outlined,
                    label: 'تطبيقاتنا',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 4, // More tab
        onTap: (index) {
          if (index != 4) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}
