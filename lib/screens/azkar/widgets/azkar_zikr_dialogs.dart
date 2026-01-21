import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cubits/azkar/azkar_detail_cubit.dart';
import '../../../models/zikr_model.dart';
import '../add_zikr_dialog.dart';

/// Helper class for Zikr-related dialogs
class AzkarZikrDialogs {
  /// Show dialog to add a new zikr
  static void showAddZikrDialog({
    required BuildContext context,
    required String categoryName,
  }) {
    final cubit = context.read<AzkarDetailCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => AddZikrDialog(
        categoryName: categoryName,
        onAdd: (zikr) async {
          await cubit.addCustomZikr(
            categoryName: categoryName,
            zikr: zikr,
          );
        },
      ),
    );
  }

  /// Show dialog to edit an existing zikr
  static void showEditZikrDialog({
    required BuildContext context,
    required String categoryName,
    required ZikrModel zikr,
  }) {
    final cubit = context.read<AzkarDetailCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => AddZikrDialog(
        categoryName: categoryName,
        existingZikr: zikr,
        onAdd: (updatedZikr) async {
          await cubit.updateZikr(
            categoryName: categoryName,
            zikr: updatedZikr,
          );
        },
        onDelete: () async {
          await cubit.deleteZikr(
            categoryName: categoryName,
            zikrId: zikr.id,
          );
        },
      ),
    );
  }
}
