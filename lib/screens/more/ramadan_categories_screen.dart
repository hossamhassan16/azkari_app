import 'package:azkari_app/core/constants/app_colors.dart';
import 'package:azkari_app/models/ramadan_item_model.dart';
import 'package:azkari_app/screens/more/ramadan_detail_screen.dart';
import 'package:azkari_app/widgets/ramadan/ramadan_card.dart';
import 'package:flutter/material.dart';

class RamadanPage extends StatelessWidget {
  const RamadanPage({super.key});

  static const List<Map<String, dynamic>> items = [
    {
      'item': RamadanItem(
        title: 'قرآن',
        subtitle: 'أحاديث عن نزول و تلاوة القرآن',
        icon: Icons.menu_book,
      ),
      'jsonKey': 'قرآن',
    },
    {
      'item': RamadanItem(
        title: 'أدعية رمضانية',
        subtitle: 'أدعية يمكن ذكرها في رمضان',
        icon: Icons.pan_tool_alt,
      ),
      'jsonKey': 'أدعية رمضانية',
    },
    {
      'item': RamadanItem(
        title: 'السحور و الإفطار',
        subtitle: 'سنن السحور و الإفطار',
        icon: Icons.restaurant,
      ),
      'jsonKey': 'السَّحور و الإفطار',
    },
    {
      'item': RamadanItem(
        title: 'الاعتكاف',
        subtitle: 'أحاديث عن الاعتكاف في رمضان',
        icon: Icons.self_improvement,
      ),
      'jsonKey': 'الاعتكاف',
    },
    {
      'item': RamadanItem(
        title: 'العشر الأواخر و ليلة القدر',
        subtitle: 'أحاديث عن العشر الأواخر من رمضان و ليلة القدر',
        icon: Icons.nights_stay,
        badge: '10',
      ),
      'jsonKey': 'العشر الأواخر',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        title: const Text('رمضان'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final itemData = items[index];
            final item = itemData['item'] as RamadanItem;
            final jsonKey = itemData['jsonKey'] as String;
            
            return RamadanCard(
              title: item.title,
              subtitle: item.subtitle,
              icon: item.icon,
              badge: item.badge,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RamadanDetailScreen(
                      title: item.title,
                      jsonKey: jsonKey,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
