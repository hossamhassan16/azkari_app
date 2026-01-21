import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../models/azkar_category_model.dart';
import '../../services/azkar_service.dart';
import '../../cubits/azkar/azkar_detail_cubit.dart';
import '../../cubits/azkar/settings_cubit.dart';
import '../../widgets/azkar/azkar_settings_dialog.dart';
import 'widgets/azkar_exit_dialog.dart';
import 'widgets/azkar_zikr_dialogs.dart';
import 'widgets/azkar_duaa_card_builder.dart';

class AzkarDetailScreen extends StatelessWidget {
  final AzkarCategoryModel category;

  const AzkarDetailScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: AppColors.darkBackground,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
      ),
    );
  }

        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => AzkarDetailCubit(AzkarService()),
            ),
            BlocProvider(
              create: (context) => SettingsCubit(snapshot.data!),
            ),
          ],
          child: AzkarDetailScreenView(category: category),
        );
      },
    );
  }
}

class AzkarDetailScreenView extends StatelessWidget {
  final AzkarCategoryModel category;

  const AzkarDetailScreenView({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (!didPop) {
              final canPop = await _handleWillPop(context, settingsState);
              if (canPop && context.mounted) {
                Navigator.of(context).pop();
              }
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.darkBackground,
            appBar: _buildAppBar(context),
            body: _buildBody(context, settingsState),
            floatingActionButton: _buildFloatingActionButton(context),
          ),
        );
      },
    );
  }

  /// Get visible azkar based on hideAtZero setting
  List<dynamic> _getVisibleAzkar(SettingsState settings) {
    return settings.hideAtZero
        ? category.azkar.where((z) => z.currentCount > 0).toList()
        : category.azkar;
  }

  /// Build the app bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
          backgroundColor: AppColors.cardBackground,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: () => _handleBackButton(context),
          ),
          title: Text(
        category.name,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
        _buildEditButton(context),
        _buildSettingsButton(context),
      ],
    );
  }

  /// Build edit/check button
  Widget _buildEditButton(BuildContext context) {
    return BlocBuilder<AzkarDetailCubit, AzkarDetailState>(
      builder: (context, detailState) {
        final isEditMode = context.read<AzkarDetailCubit>().isEditMode;
        return IconButton(
              icon: Icon(
            isEditMode ? Icons.check : Icons.edit,
                color: AppColors.white,
              ),
          onPressed: () => _handleEditButtonPress(context, isEditMode),
        );
      },
    );
  }

  /// Build settings button
  Widget _buildSettingsButton(BuildContext context) {
    return IconButton(
              icon: const Icon(Icons.settings, color: AppColors.white),
      onPressed: () => _showSettingsDialog(context),
    );
  }

  /// Build main body content
  Widget _buildBody(
    BuildContext context,
    SettingsState settingsState,
  ) {
    return BlocConsumer<AzkarDetailCubit, AzkarDetailState>(
      listener: (context, state) => _handleDetailStateChanges(context, state),
      builder: (context, detailState) {
        // Recalculate visible azkar on every rebuild
        final visibleAzkar = _getVisibleAzkar(settingsState);
        
        if (visibleAzkar.isEmpty) {
          return _buildEmptyState();
        }

        return settingsState.isHorizontal
            ? _buildHorizontalView(visibleAzkar)
            : _buildVerticalView(visibleAzkar);
      },
    );
  }

  /// Build empty state widget
  Widget _buildEmptyState() {
    return const Center(
                child: Text(
                  'لا توجد أذكار',
                  style: TextStyle(color: AppColors.white, fontSize: 18),
                ),
    );
  }

  /// Build horizontal (PageView) layout
  Widget _buildHorizontalView(List<dynamic> visibleAzkar) {
    return PageView.builder(
                    itemCount: visibleAzkar.length,
                    itemBuilder: (context, index) {
                      return Center(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AzkarDuaaCardBuilder(
                category: category,
                zikr: visibleAzkar[index],
              ),
                          ),
                        ),
                      );
                    },
    );
  }

  /// Build vertical (ListView) layout
  Widget _buildVerticalView(List<dynamic> visibleAzkar) {
    return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: visibleAzkar.length,
                    itemBuilder: (context, index) {
        return AzkarDuaaCardBuilder(
          category: category,
          zikr: visibleAzkar[index],
        );
      },
    );
  }

  /// Build floating action button
  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddZikrDialog(context),
          backgroundColor: AppColors.primaryGreen,
          child: const Icon(Icons.add, color: AppColors.white, size: 32),
    );
  }

  // ============= Event Handlers =============

  /// Handle back button press
  Future<void> _handleBackButton(BuildContext context) async {
    final settingsState = context.read<SettingsCubit>().state;
    final canPop = await _handleWillPop(context, settingsState);
    if (canPop && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  /// Handle will pop (exit confirmation)
  Future<bool> _handleWillPop(
    BuildContext context,
    SettingsState settings,
  ) async {
    return await AzkarExitDialog.show(
      context: context,
      confirmExit: settings.confirmExit,
      category: category,
    );
  }

  /// Handle edit button press
  void _handleEditButtonPress(BuildContext context, bool isEditMode) {
    if (isEditMode) {
      context.read<AzkarDetailCubit>().saveAndExitEditMode();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ التعديلات'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } else {
      context.read<AzkarDetailCubit>().toggleEditMode();
    }
  }

  /// Handle detail state changes (errors, success)
  void _handleDetailStateChanges(BuildContext context, AzkarDetailState state) {
    if (state is AzkarDetailError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    } else if (state is AzkarDetailZikrAdded ||
        state is AzkarDetailZikrUpdated ||
        state is AzkarDetailZikrDeleted) {
      Navigator.of(context).pop();
    }
  }

  // ============= Dialog Helpers =============

  /// Show settings dialog
  void _showSettingsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<SettingsCubit>(),
        child: const AzkarSettingsDialog(),
      ),
    );
  }

  /// Show add zikr dialog
  void _showAddZikrDialog(BuildContext context) {
    AzkarZikrDialogs.showAddZikrDialog(
      context: context,
      categoryName: category.name,
    );
  }
}
