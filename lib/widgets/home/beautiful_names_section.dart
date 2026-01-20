import 'dart:ui';

import 'package:azkari_app/core/constants/app_colors.dart';
import 'package:azkari_app/core/constants/app_strings.dart';
import 'package:azkari_app/models/allah_names_model.dart';
import 'package:azkari_app/services/allah_names_services.dart';
import 'package:azkari_app/widgets/common/section_header.dart';
import 'package:flutter/material.dart';

class BeautifulNamesSection extends StatefulWidget {
  const BeautifulNamesSection({super.key});

  @override
  State<BeautifulNamesSection> createState() => _BeautifulNamesSectionState();
}

class _BeautifulNamesSectionState extends State<BeautifulNamesSection> {
  AllahNameModel? name;

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final result = await AllahNamesService().getDailyRandomName();
    setState(() => name = result);
  }

  @override
  Widget build(BuildContext context) {
    if (name == null) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: AppStrings.beautifulNames,
          onShare: () {},
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                name!.nameAr,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                name!.meaningAr,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
