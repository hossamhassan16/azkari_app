import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../cubits/azkar/settings_cubit.dart';
import 'azkar_settings_widgets.dart';

/// Settings dialog for Azkar display preferences
class AzkarSettingsDialog extends StatefulWidget {
  const AzkarSettingsDialog({super.key});

  @override
  State<AzkarSettingsDialog> createState() => _AzkarSettingsDialogState();
}

class _AzkarSettingsDialogState extends State<AzkarSettingsDialog> {
  late double tempFontSize;
  late bool tempIsHorizontal;
  late bool tempVibrateAtZero;
  late bool tempHideAtZero;
  late bool tempTapOnCard;
  late bool tempConfirmExit;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsCubit>().state;
    tempFontSize = settings.fontSize;
    tempIsHorizontal = settings.isHorizontal;
    tempVibrateAtZero = settings.vibrateAtZero;
    tempHideAtZero = settings.hideAtZero;
    tempTapOnCard = settings.tapOnCardToCount;
    tempConfirmExit = settings.confirmExit;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildDisplayOptionsSection(),
            const SizedBox(height: 24),
            _buildFontOptionsSection(),
            const SizedBox(height: 24),
            _buildBehaviorOptionsSection(),
            const SizedBox(height: 24),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'خيارات العرض',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            DisplayOptionWidget(
              label: 'عامودي',
              isSelected: !tempIsHorizontal,
              onTap: () => setState(() => tempIsHorizontal = false),
            ),
            DisplayOptionWidget(
              label: 'أفقي',
              isSelected: tempIsHorizontal,
              onTap: () => setState(() => tempIsHorizontal = true),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFontOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'خيارات الخط',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        FontSizeSliderWidget(
          fontSize: tempFontSize,
          onChanged: (value) => setState(() => tempFontSize = value),
        ),
      ],
    );
  }

  Widget _buildBehaviorOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CheckboxOptionWidget(
          title: 'ارتجاع عند الصفر',
          description:
              'تفعيل هذا الخيار سيفعل الارتجاج عند وصول العداد للصفر في صفحة أذكار اليوم والليلة',
          value: tempVibrateAtZero,
          onChanged: (value) => setState(() => tempVibrateAtZero = value ?? true),
        ),
        CheckboxOptionWidget(
          title: 'اخفاء عند الصفر',
          description:
              'بتفعيل هذا الخيار سيختفي الذكر عند وصول العداد للصفر في صفحة أذكار اليوم والليلة',
          value: tempHideAtZero,
          onChanged: (value) => setState(() => tempHideAtZero = value ?? false),
        ),
        CheckboxOptionWidget(
          title: 'العد بالضغط على الذكر',
          description: 'بتفعيل هذا الخيار يمكنك الضغط على اي مكان على الذكر للعد',
          value: tempTapOnCard,
          onChanged: (value) => setState(() => tempTapOnCard = value ?? false),
        ),
        CheckboxOptionWidget(
          title: 'تأكيد الخروج',
          description:
              'تفعيل هذا الخيار سيمنع الخروج بالخطأ من اذكار اليوم و الليلة اثناء قراءتها في حال لم تنهي كل الأذكار و سيسألك قبل الخروج',
          value: tempConfirmExit,
          onChanged: (value) => setState(() => tempConfirmExit = value ?? false),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'حفظ',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _saveSettings() {
    context.read<SettingsCubit>().updateSettings(
          fontSize: tempFontSize,
          isHorizontal: tempIsHorizontal,
          vibrateAtZero: tempVibrateAtZero,
          hideAtZero: tempHideAtZero,
          tapOnCardToCount: tempTapOnCard,
          confirmExit: tempConfirmExit,
        );
    Navigator.pop(context);
  }
}
