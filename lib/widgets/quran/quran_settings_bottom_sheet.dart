import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/quran_settings_service.dart';
import '../../models/quran_reader_model.dart';

class QuranSettingsBottomSheet extends StatefulWidget {
  final Function() onSettingsChanged;

  const QuranSettingsBottomSheet({
    super.key,
    required this.onSettingsChanged,
  });

  @override
  State<QuranSettingsBottomSheet> createState() => _QuranSettingsBottomSheetState();
}

class _QuranSettingsBottomSheetState extends State<QuranSettingsBottomSheet> {
  final QuranSettingsService _settingsService = QuranSettingsService();
  late VerseDisplayMode _selectedDisplayMode;
  late double _fontSize;
  late QuranReaderModel _selectedReader;
  late bool _readVerseOnLaunch;

  @override
  void initState() {
    super.initState();
    _selectedDisplayMode = _settingsService.displayMode;
    _fontSize = _settingsService.fontSize;
    _selectedReader = _settingsService.selectedReader ?? _settingsService.readers[0];
    _readVerseOnLaunch = _settingsService.readVerseOnLaunch;
  }

  void _applySettings() {
    _settingsService.setDisplayMode(_selectedDisplayMode);
    _settingsService.setFontSize(_fontSize);
    _settingsService.setSelectedReader(_selectedReader);
    _settingsService.setReadVerseOnLaunch(_readVerseOnLaunch);
    widget.onSettingsChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle indicator
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // نمط عرض الايات (Display Mode)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'نمط عرض الايات',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _DisplayModeButton(
                        icon: Icons.view_module_rounded,
                        label: 'صفحة',
                        isSelected: _selectedDisplayMode == VerseDisplayMode.page,
                        onTap: () {
                          setState(() {
                            _selectedDisplayMode = VerseDisplayMode.page;
                            _applySettings();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _DisplayModeButton(
                        icon: Icons.view_list_rounded,
                        label: 'قائمة',
                        isSelected: _selectedDisplayMode == VerseDisplayMode.list,
                        onTap: () {
                          setState(() {
                            _selectedDisplayMode = VerseDisplayMode.list;
                            _applySettings();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // خيارات الخط (Font Options)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_fontSize.round()}',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'حجم الخط',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.primaryGreen,
                    inactiveTrackColor: AppColors.greyText.withOpacity(0.3),
                    thumbColor: AppColors.primaryGreen,
                    overlayColor: AppColors.primaryGreen.withOpacity(0.2),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _fontSize,
                    min: 12,
                    max: 60,
                    divisions: 48,
                    onChanged: (value) {
                      setState(() {
                        _fontSize = value;
                      });
                    },
                    onChangeEnd: (value) {
                      _applySettings();
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '٦٠',
                      style: TextStyle(
                        color: AppColors.greyText.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '١٢',
                      style: TextStyle(
                        color: AppColors.greyText.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // القارئ (Reader)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'القارئ',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<QuranReaderModel>(
                      value: _selectedReader,
                      isExpanded: true,
                      dropdownColor: AppColors.cardBackground,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.primaryGreen,
                      ),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                      ),
                      items: _settingsService.readers.map((reader) {
                        return DropdownMenuItem<QuranReaderModel>(
                          value: reader,
                          child: Text(
                            reader.name,
                            style: const TextStyle(
                              color: AppColors.white,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (QuranReaderModel? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedReader = newValue;
                            _applySettings();
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // قراءة اية عند فتح التطبيق (Read verse on launch)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: InkWell(
              onTap: () {
                setState(() {
                  _readVerseOnLaunch = !_readVerseOnLaunch;
                  _applySettings();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Checkbox(
                      value: _readVerseOnLaunch,
                      onChanged: (value) {
                        setState(() {
                          _readVerseOnLaunch = value ?? false;
                          _applySettings();
                        });
                      },
                      activeColor: AppColors.primaryGreen,
                      checkColor: AppColors.white,
                    ),
                    const Expanded(
                      child: Text(
                        'بتفعيل هذه الميزة ستظهر اية من القرأن بالتسلسل عند بدء تشغيل التطبيق',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Title for the checkbox
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'قراءة اية عند فتح التطبيق',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _DisplayModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DisplayModeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen.withOpacity(0.1) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGreen : AppColors.greyText.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: AppColors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              icon,
              color: isSelected ? AppColors.primaryGreen : AppColors.white,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primaryGreen : AppColors.white,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


