import 'package:azkari_app/models/display_setting_model.dart';
import 'package:azkari_app/services/setting_service.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SettingsDialog extends StatefulWidget {
  final DisplaySettingsModel settings;

  const SettingsDialog({
    super.key,
    required this.settings,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late DisplaySettingsModel _settings;
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  Future<void> _saveSettings() async {
    await _settingsService.saveSettings(_settings);
    if (!mounted) return;
    Navigator.of(context).pop(_settings);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkBackground,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'خيارات العرض',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Orientation selection
              const Text(
                'خيارات العرض',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<DisplayOrientation>(
                      title: const Text(
                        'أفقي',
                        style: TextStyle(color: AppColors.white),
                      ),
                      value: DisplayOrientation.horizontal,
                      groupValue: _settings.orientation,
                      activeColor: AppColors.primaryGreen,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _settings = _settings.copyWith(orientation: value);
                          });
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<DisplayOrientation>(
                      title: const Text(
                        'عامودي',
                        style: TextStyle(color: AppColors.white),
                      ),
                      value: DisplayOrientation.vertical,
                      groupValue: _settings.orientation,
                      activeColor: AppColors.primaryGreen,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _settings = _settings.copyWith(orientation: value);
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Font size options
              const Text(
                'خيارات الخط',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),

              // Font size slider
              Row(
                children: [
                  const Icon(Icons.text_fields,
                      color: AppColors.white, size: 20),
                  Expanded(
                    child: Slider(
                      value: _settings.fontSize,
                      min: 16,
                      max: 36,
                      divisions: 10,
                      activeColor: AppColors.primaryGreen,
                      label: _settings.fontSize.round().toString(),
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(fontSize: value);
                        });
                      },
                    ),
                  ),
                  const Icon(Icons.text_fields,
                      color: AppColors.white, size: 32),
                ],
              ),

              Text(
                'خط أذكار اليوم والليلة',
                style: const TextStyle(
                  color: AppColors.greyText,
                  fontSize: 14,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.text_fields,
                      color: AppColors.white, size: 20),
                  Expanded(
                    child: Slider(
                      value: _settings.fontSizeDay,
                      min: 16,
                      max: 36,
                      divisions: 10,
                      activeColor: AppColors.primaryGreen,
                      label: _settings.fontSizeDay.round().toString(),
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(fontSizeDay: value);
                        });
                      },
                    ),
                  ),
                  const Icon(Icons.text_fields,
                      color: AppColors.white, size: 32),
                ],
              ),

              const SizedBox(height: 24),

              // Vibrate on zero
              const Text(
                'ارتجاج عند الصفر',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text(
                  'تفعيل هذا الخيار سيفعل الارتجاج عند وصول العداد للصفر في صفحة أذكار اليوم والليلة',
                  style: TextStyle(color: AppColors.greyText, fontSize: 12),
                ),
                value: _settings.vibrateOnZero,
                activeColor: AppColors.primaryGreen,
                onChanged: (value) {
                  setState(() {
                    _settings = _settings.copyWith(vibrateOnZero: value);
                  });
                },
              ),

              const SizedBox(height: 16),

              // Hide on zero
              const Text(
                'اخفاء عند الصفر',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text(
                  'تفعيل هذا الخيار سيختفي الذكر عند وصول العداد للصفر في صفحة أذكار اليوم والليلة',
                  style: TextStyle(color: AppColors.greyText, fontSize: 12),
                ),
                value: _settings.hideOnZero,
                activeColor: AppColors.primaryGreen,
                onChanged: (value) {
                  setState(() {
                    _settings = _settings.copyWith(hideOnZero: value);
                  });
                },
              ),

              const SizedBox(height: 16),

              // Tap to decrement
              const Text(
                'العد بالضغط على الذكر',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text(
                  'بتفعيل هذا الخيار يمكنك الضغط على أي مكان على الذكر للعد',
                  style: TextStyle(color: AppColors.greyText, fontSize: 12),
                ),
                value: _settings.tapToDecrement,
                activeColor: AppColors.primaryGreen,
                onChanged: (value) {
                  setState(() {
                    _settings = _settings.copyWith(tapToDecrement: value);
                  });
                },
              ),

              const SizedBox(height: 16),

              // Confirm exit
              const Text(
                'تأكيد الخروج',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text(
                  'تفعيل هذا الخيار سيمنع الخروج بالخطأ من اذكار اليوم و الليلة اثناء قراءتها في حال لم تنهي كل الأذكار و سيسألك قبل الخروج',
                  style: TextStyle(color: AppColors.greyText, fontSize: 12),
                ),
                value: _settings.confirmExit,
                activeColor: AppColors.primaryGreen,
                onChanged: (value) {
                  setState(() {
                    _settings = _settings.copyWith(confirmExit: value);
                  });
                },
              ),

              const SizedBox(height: 32),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(
                        color: AppColors.greyText,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'حفظ',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
