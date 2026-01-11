import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../models/azkar_category_model.dart';
import '../../models/zikr_model.dart';
import '../../services/azkar_service.dart';
import '../../widgets/azkar/duaa_card.dart';
import '../../models/duaa_item_model.dart';
import 'add_zikr_dialog.dart';

class AzkarDetailScreen extends StatefulWidget {
  final AzkarCategoryModel category;

  const AzkarDetailScreen({
    super.key,
    required this.category,
  });

  @override
  State<AzkarDetailScreen> createState() => _AzkarDetailScreenState();
}

class _AzkarDetailScreenState extends State<AzkarDetailScreen> {
  final AzkarService _azkarService = AzkarService();
  bool _isEditMode = false;
  bool _isHorizontal = false;
  double _fontSize = 24.0;
  bool _vibrateAtZero = true;
  bool _hideAtZero = false;
  bool _tapOnCardToCount = false;
  bool _confirmExit = false;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _isHorizontal = _prefs?.getBool('azkar_is_horizontal') ?? false;
      _fontSize = _prefs?.getDouble('azkar_font_size') ?? 24.0;
      _vibrateAtZero = _prefs?.getBool('azkar_vibrate_at_zero') ?? true;
      _hideAtZero = _prefs?.getBool('azkar_hide_at_zero') ?? false;
      _tapOnCardToCount = _prefs?.getBool('azkar_tap_on_card') ?? false;
      _confirmExit = _prefs?.getBool('azkar_confirm_exit') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    await _prefs?.setBool('azkar_is_horizontal', _isHorizontal);
    await _prefs?.setDouble('azkar_font_size', _fontSize);
    await _prefs?.setBool('azkar_vibrate_at_zero', _vibrateAtZero);
    await _prefs?.setBool('azkar_hide_at_zero', _hideAtZero);
    await _prefs?.setBool('azkar_tap_on_card', _tapOnCardToCount);
    await _prefs?.setBool('azkar_confirm_exit', _confirmExit);
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  void _saveAndExitEditMode() {
    setState(() {
      _isEditMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ التعديلات'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  void _showSettingsDialog() {
    // Create local state variables for the dialog
    double tempFontSize = _fontSize;
    bool tempIsHorizontal = _isHorizontal;
    bool tempVibrateAtZero = _vibrateAtZero;
    bool tempHideAtZero = _hideAtZero;
    bool tempTapOnCard = _tapOnCardToCount;
    bool tempConfirmExit = _confirmExit;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
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
                  // خيارات العرض
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
                      _buildDisplayOption(
                        'عامودي',
                        !tempIsHorizontal,
                        () {
                          setDialogState(() {
                            tempIsHorizontal = false;
                          });
                        },
                      ),
                      _buildDisplayOption(
                        'أفقي',
                        tempIsHorizontal,
                        () {
                          setDialogState(() {
                            tempIsHorizontal = true;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // خيارات الخط
                  const Text(
                    'خيارات الخط',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'حجم الخط',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            '12',
                            style: TextStyle(color: AppColors.greyText),
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor: AppColors.primaryGreen,
                                inactiveTrackColor: AppColors.greyText.withOpacity(0.3),
                                thumbColor: AppColors.primaryGreen,
                                overlayColor: AppColors.primaryGreen.withOpacity(0.3),
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                                trackHeight: 4,
                              ),
                              child: Slider(
                                value: tempFontSize,
                                min: 12,
                                max: 60,
                                divisions: 48,
                                onChanged: (value) {
                                  setDialogState(() {
                                    tempFontSize = value;
                                  });
                                },
                              ),
                            ),
                          ),
                          const Text(
                            '60',
                            style: TextStyle(color: AppColors.greyText),
                          ),
                        ],
                      ),
                      Center(
                        child: Text(
                          '${tempFontSize.round()}',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ارتجاع عند الصفر
                  _buildCheckboxOption(
                    'ارتجاع عند الصفر',
                    'تفعيل هذا الخيار سيفعل الارتجاج عند وصول العداد للصفر في صفحة أذكار اليوم والليلة',
                    tempVibrateAtZero,
                    (value) {
                      setDialogState(() {
                        tempVibrateAtZero = value ?? true;
                      });
                    },
                  ),

                  // اخفاء عند الصفر
                  _buildCheckboxOption(
                    'اخفاء عند الصفر',
                    'بتفعيل هذا الخيار سيختفي الذكر عند وصول العداد للصفر في صفحة أذكار اليوم والليلة',
                    tempHideAtZero,
                    (value) {
                      setDialogState(() {
                        tempHideAtZero = value ?? false;
                      });
                    },
                  ),

                  // العد بالضغط على الذكر
                  _buildCheckboxOption(
                    'العد بالضغط على الذكر',
                    'بتفعيل هذا الخيار يمكنك الضغط على اي مكان على الذكر للعد',
                    tempTapOnCard,
                    (value) {
                      setDialogState(() {
                        tempTapOnCard = value ?? false;
                      });
                    },
                  ),

                  // تأكيد الخروج
                  _buildCheckboxOption(
                    'تأكيد الخروج',
                    'تفعيل هذا الخيار سيمنع الخروج بالخطأ من اذكار اليوم و الليلة اثناء قراءتها في حال لم تنهي كل الأذكار و سيسألك قبل الخروج',
                    tempConfirmExit,
                    (value) {
                      setDialogState(() {
                        tempConfirmExit = value ?? false;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _fontSize = tempFontSize;
                          _isHorizontal = tempIsHorizontal;
                          _vibrateAtZero = tempVibrateAtZero;
                          _hideAtZero = tempHideAtZero;
                          _tapOnCardToCount = tempTapOnCard;
                          _confirmExit = tempConfirmExit;
                        });
                        _saveSettings();
                        Navigator.pop(context);
                      },
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
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDisplayOption(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.white, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primaryGreen : AppColors.greyText,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxOption(
    String title,
    String description,
    bool value,
    Function(bool?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.primaryGreen,
              ),
              Expanded(
                child: Text(
                  description,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppColors.greyText,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddZikrDialog() {
    showDialog(
      context: context,
      builder: (context) => AddZikrDialog(
        categoryName: widget.category.name,
        onAdd: (zikr) async {
          await _azkarService.addCustomZikr(widget.category.name, zikr);
          setState(() {});
        },
      ),
    );
  }

  void _showEditZikrDialog(ZikrModel zikr) {
    showDialog(
      context: context,
      builder: (context) => AddZikrDialog(
        categoryName: widget.category.name,
        existingZikr: zikr,
        onAdd: (updatedZikr) async {
          await _azkarService.updateZikr(widget.category.name, updatedZikr);
          setState(() {});
        },
        onDelete: () async {
          await _azkarService.deleteZikr(widget.category.name, zikr.id);
          setState(() {});
        },
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_confirmExit) {
      return true;
    }

    // Check if any azkar are incomplete
    final hasIncomplete = widget.category.azkar.any((z) => z.currentCount > 0);
    if (!hasIncomplete) {
      return true;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'تأكيد الخروج',
          style: TextStyle(color: AppColors.white),
          textAlign: TextAlign.right,
        ),
        content: const Text(
          'لم تنهي جميع الأذكار، هل تريد الخروج؟',
          style: TextStyle(color: AppColors.white),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: AppColors.greyText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'خروج',
              style: TextStyle(color: AppColors.primaryGreen),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // Filter out completed azkar if hideAtZero is enabled
    final visibleAzkar = _hideAtZero
        ? widget.category.azkar.where((z) => z.currentCount > 0).toList()
        : widget.category.azkar;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          backgroundColor: AppColors.cardBackground,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () async {
              final canPop = await _onWillPop();
              if (canPop && mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(
            widget.category.name,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isEditMode ? Icons.check : Icons.edit,
                color: AppColors.white,
              ),
              onPressed: _isEditMode ? _saveAndExitEditMode : _toggleEditMode,
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: AppColors.white),
              onPressed: _showSettingsDialog,
            ),
          ],
        ),
        body: visibleAzkar.isEmpty
            ? const Center(
                child: Text(
                  'لا توجد أذكار',
                  style: TextStyle(color: AppColors.white, fontSize: 18),
                ),
              )
            : _isHorizontal
                ? PageView.builder(
                    itemCount: visibleAzkar.length,
                    itemBuilder: (context, index) {
                      final zikrIndex = widget.category.azkar.indexOf(visibleAzkar[index]);
                      return Center(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildDuaaCard(zikrIndex),
                          ),
                        ),
                      );
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: visibleAzkar.length,
                    itemBuilder: (context, index) {
                      final zikrIndex = widget.category.azkar.indexOf(visibleAzkar[index]);
                      return _buildDuaaCard(zikrIndex);
                    },
                  ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddZikrDialog,
          backgroundColor: AppColors.primaryGreen,
          child: const Icon(Icons.add, color: AppColors.white, size: 32),
        ),
      ),
    );
  }

  Widget _buildDuaaCard(int index) {
    final zikr = widget.category.azkar[index];
    final duaItem = DuaItemModel(
      id: zikr.id,
      content: zikr.content,
      reference: zikr.description,
      count: zikr.initialCount,
      currentCount: zikr.currentCount,
    );

    return GestureDetector(
      onTap: _tapOnCardToCount && !_isEditMode
          ? () async {
              if (zikr.currentCount > 0) {
                final newCount = zikr.currentCount - 1;
                await _azkarService.saveProgress(
                  widget.category.name,
                  zikr.id,
                  newCount,
                );
                
                // Vibrate at zero if enabled
                if (newCount == 0 && _vibrateAtZero) {
                  HapticFeedback.heavyImpact();
                }
                
                setState(() {});
              }
            }
          : null,
      child: DuaCard(
        dua: duaItem,
        isHorizontal: _isHorizontal,
        fontSize: _fontSize,
        onCounterTap: () async {
          if (zikr.currentCount > 0) {
            final newCount = zikr.currentCount - 1;
            await _azkarService.saveProgress(
              widget.category.name,
              zikr.id,
              newCount,
            );
            
            // Vibrate at zero if enabled
            if (newCount == 0 && _vibrateAtZero) {
              HapticFeedback.heavyImpact();
            }
            
            setState(() {});
          }
        },
        onEdit: _isEditMode ? () => _showEditZikrDialog(zikr) : null,
      ),
    );
  }
}
