import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cubits/azkar/azkar_detail_cubit.dart';
import '../../../cubits/azkar/settings_cubit.dart';
import '../../../models/azkar_category_model.dart';
import '../../../models/duaa_item_model.dart';
import '../../../models/zikr_model.dart';
import '../../../widgets/azkar/duaa_card.dart';
import 'azkar_zikr_dialogs.dart';

/// Builder widget for Azkar Duaa Cards
class AzkarDuaaCardBuilder extends StatelessWidget {
  final AzkarCategoryModel category;
  final ZikrModel zikr;

  const AzkarDuaaCardBuilder({
    super.key,
    required this.category,
    required this.zikr,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        final duaItem = _createDuaItem(zikr);
        final isEditMode = context.read<AzkarDetailCubit>().isEditMode;

        return GestureDetector(
          onTap: settings.tapOnCardToCount && !isEditMode
              ? () => _handleCardTap(context, zikr, settings)
              : null,
          child: DuaCard(
            dua: duaItem,
            isHorizontal: settings.isHorizontal,
            fontSize: settings.fontSize,
            onCounterTap: () => _handleCounterTap(context, zikr, settings),
            onEdit: isEditMode
                ? () => _handleEdit(context, zikr)
                : null,
          ),
        );
      },
    );
  }

  DuaItemModel _createDuaItem(ZikrModel zikr) {
    return DuaItemModel(
      id: zikr.id,
      content: zikr.content,
      reference: zikr.description,
      count: zikr.initialCount,
      currentCount: zikr.currentCount,
    );
  }

  Future<void> _handleCardTap(
    BuildContext context,
    ZikrModel zikr,
    SettingsState settings,
  ) async {
    if (zikr.currentCount > 0) {
      await _decrementAndVibrate(context, zikr, settings);
    }
  }

  Future<void> _handleCounterTap(
    BuildContext context,
    ZikrModel zikr,
    SettingsState settings,
  ) async {
    if (zikr.currentCount > 0) {
      await _decrementAndVibrate(context, zikr, settings);
    }
  }

  Future<void> _decrementAndVibrate(
    BuildContext context,
    ZikrModel zikr,
    SettingsState settings,
  ) async {
    await context.read<AzkarDetailCubit>().decrementCounter(
          categoryName: category.name,
          zikrId: zikr.id,
          currentCount: zikr.currentCount,
        );

    // Vibrate at zero if enabled
    if (zikr.currentCount - 1 == 0 && settings.vibrateAtZero) {
      HapticFeedback.heavyImpact();
    }
  }

  void _handleEdit(BuildContext context, ZikrModel zikr) {
    AzkarZikrDialogs.showEditZikrDialog(
      context: context,
      categoryName: category.name,
      zikr: zikr,
    );
  }
}
