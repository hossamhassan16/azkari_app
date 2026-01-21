import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../screens/quran/saved_verses_screen.dart';

class QuranAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController? searchController;
  final Function(String)? onSearchChanged;
  final VoidCallback? onBack;

  const QuranAppBar({
    super.key,
    this.searchController,
    this.onSearchChanged,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.cardBackground,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: AppColors.white,
        ),
        onPressed: onBack ?? () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          const Icon(
            Icons.search,
            color: AppColors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: AppStrings.search,
                hintStyle: const TextStyle(
                  color: AppColors.greyText,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.bookmark,
            color: AppColors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SavedVersesScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
