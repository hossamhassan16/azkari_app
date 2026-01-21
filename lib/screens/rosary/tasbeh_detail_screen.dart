import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../models/tasbeh_item_model.dart';
import '../../services/tasbeh_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum RosaryInterface {
  defaultInterface, // الواجهة الافتراضية
  circularRosary, // مسبحة دائرية
  horizontalRosary, // مسبحة افقية
  fullScreenTap, // الضغط على كل الشاشة
  increaseDecreaseButtons, // ازرار زيادة و انقاص
}

class TasbehDetailScreen extends StatefulWidget {
  final String tasbehId;

  const TasbehDetailScreen({super.key, required this.tasbehId});

  @override
  State<TasbehDetailScreen> createState() => _TasbehDetailScreenState();
}

class _TasbehDetailScreenState extends State<TasbehDetailScreen>
    with SingleTickerProviderStateMixin {
  final TasbehService _tasbehService = TasbehService();
  TasbehItemModel? _tasbeh;
  RosaryInterface _currentInterface = RosaryInterface.defaultInterface;
  bool _vibrationEnabled = true;
  Color _beadColor = const Color(0xFFD4A373); // Default brown/gold color

  AnimationController? _animationController;
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadTasbeh();
    _loadSettings();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentInterface = RosaryInterface
          .values[prefs.getInt('rosary_interface_${widget.tasbehId}') ?? 0];
      _vibrationEnabled =
          prefs.getBool('rosary_vibration_${widget.tasbehId}') ?? true;
      final colorValue = prefs.getInt('rosary_bead_color_${widget.tasbehId}');
      if (colorValue != null) {
        _beadColor = Color(colorValue);
      }
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        'rosary_interface_${widget.tasbehId}', _currentInterface.index);
    await prefs.setBool(
        'rosary_vibration_${widget.tasbehId}', _vibrationEnabled);
    await prefs.setInt(
        'rosary_bead_color_${widget.tasbehId}', _beadColor.value);
  }

  Future<void> _loadTasbeh() async {
    final tasbeh = _tasbehService.getTasbehById(widget.tasbehId);
    if (tasbeh != null) {
      setState(() {
        _tasbeh = tasbeh;
      });
    }
  }

  Future<void> _increment() async {
    await _tasbehService.incrementCount(widget.tasbehId);
    await _loadTasbeh();

    if (_vibrationEnabled) {
      HapticFeedback.lightImpact();
    }

    // Animate for circular rosary
    _animationController?.forward(from: 0);

    // Auto-scroll horizontal rosary
    if (_currentInterface == RosaryInterface.horizontalRosary &&
        _horizontalScrollController.hasClients) {
      final currentPosition = _horizontalScrollController.position.pixels;
      _horizontalScrollController.animateTo(
        currentPosition + 48, // 40 (bead width) + 8 (margin)
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _decrement() async {
    await _tasbehService.decrementCount(widget.tasbehId);
    await _loadTasbeh();

    if (_vibrationEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  void _showOptionsMenu() {
    final isCustomTasbeh = _tasbeh?.id.startsWith('custom_') ?? false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.greyText.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _buildMenuItem(
              icon: Icons.info_outline,
              label: 'الفائدة',
              onTap: () {
                Navigator.pop(context);
                _showBenefitDialog();
              },
            ),
            _buildMenuItem(
              icon: Icons.refresh,
              label: 'تصفير الحالي',
              onTap: () async {
                Navigator.pop(context);
                await _tasbehService.resetCurrent(widget.tasbehId);
                await _loadTasbeh();
              },
            ),
            _buildMenuItem(
              icon: Icons.refresh_outlined,
              label: 'تصفير الكل',
              onTap: () async {
                Navigator.pop(context);
                await _tasbehService.resetAll(widget.tasbehId);
                await _loadTasbeh();
              },
            ),
            _buildMenuItem(
              icon: Icons.settings_outlined,
              label: 'واجهة المسبحة',
              onTap: () {
                Navigator.pop(context);
                _showInterfaceSettings();
              },
            ),
            if (isCustomTasbeh)
              _buildMenuItem(
                icon: Icons.delete_outline,
                label: 'حذف التسبيحة',
                onTap: () async {
                  Navigator.pop(context);
                  _showDeleteConfirmation();
                },
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              icon,
              color: AppColors.primaryGreen,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  void _showBenefitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'الفائدة',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.right,
        ),
        content: SingleChildScrollView(
          child: Text(
            _tasbeh?.benefit ?? 'لا توجد فائدة محفوظة',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              height: 1.8,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'تم',
              style: TextStyle(color: AppColors.primaryGreen, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'حذف التسبيحة',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.right,
        ),
        content: const Text(
          'هل أنت متأكد من حذف هذه التسبيحة؟',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 16,
          ),
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: AppColors.greyText, fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _tasbehService.deleteTasbeh(widget.tasbehId);
              if (mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حذف التسبيحة'),
                    backgroundColor: AppColors.primaryGreen,
                  ),
                );
              }
            },
            child: const Text(
              'حذف',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showInterfaceSettings() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'واجهة المسبحة',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Interface options
                _buildInterfaceOption(
                  'ازرار زيادة و انقاص',
                  RosaryInterface.increaseDecreaseButtons,
                  setDialogState,
                ),
                _buildInterfaceOption(
                  'الضغط على كل الشاشة',
                  RosaryInterface.fullScreenTap,
                  setDialogState,
                ),
                _buildInterfaceOption(
                  'مسبحة دائرية',
                  RosaryInterface.circularRosary,
                  setDialogState,
                ),
                _buildInterfaceOption(
                  'مسبحة افقية',
                  RosaryInterface.horizontalRosary,
                  setDialogState,
                ),
                _buildInterfaceOption(
                  'الواجهة الافتراضية',
                  RosaryInterface.defaultInterface,
                  setDialogState,
                ),
                const SizedBox(height: 24),
                const Divider(color: AppColors.greyText),
                const SizedBox(height: 16),
                // Vibration toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Switch(
                      value: _vibrationEnabled,
                      onChanged: (value) {
                        setDialogState(() {
                          _vibrationEnabled = value;
                        });
                        setState(() {
                          _vibrationEnabled = value;
                        });
                        _saveSettings();
                      },
                      activeColor: AppColors.primaryGreen,
                    ),
                    const Text(
                      'الاهتزاز',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Bead color picker
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'لون الخرزة',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.end,
                      children: [
                        _buildColorOption(const Color(0xFFD4A373),
                            setDialogState), // Brown/Gold
                        _buildColorOption(
                            const Color(0xFF2196F3), setDialogState), // Blue
                        _buildColorOption(
                            const Color(0xFF4CAF50), setDialogState), // Green
                        _buildColorOption(
                            const Color(0xFF000000), setDialogState), // Black
                        _buildColorOption(
                            const Color(0xFFFFFFFF), setDialogState), // White
                        _buildColorOption(const Color(0xFF8B4513),
                            setDialogState), // Saddle Brown
                        _buildColorOption(
                            const Color(0xFFFF0000), setDialogState), // Red
                        _buildColorOption(
                            const Color(0xFFCD853F), setDialogState), // Peru
                        _buildColorOption(
                            const Color(0xFFDC143C), setDialogState), // Crimson
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'تم',
                style: TextStyle(color: AppColors.primaryGreen, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterfaceOption(
    String label,
    RosaryInterface interface,
    StateSetter setDialogState,
  ) {
    final isSelected = _currentInterface == interface;
    return InkWell(
      onTap: () {
        setDialogState(() {
          _currentInterface = interface;
        });
        setState(() {
          _currentInterface = interface;
        });
        _saveSettings();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (isSelected)
              const Icon(
                Icons.check,
                color: AppColors.primaryGreen,
                size: 24,
              )
            else
              const SizedBox(width: 24),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primaryGreen : AppColors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color, StateSetter setDialogState) {
    final isSelected = _beadColor.value == color.value;
    return GestureDetector(
      onTap: () async {
        setDialogState(() {
          _beadColor = color;
        });
        setState(() {
          _beadColor = color;
        });
        await _saveSettings();
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.greyText,
            width: isSelected ? 3 : 1,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_tasbeh == null) {
      return const Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'المسبحة',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.white),
            onPressed: _showOptionsMenu,
          ),
        ],
      ),
      body: _buildInterfaceWidget(),
    );
  }

  Widget _buildInterfaceWidget() {
    switch (_currentInterface) {
      case RosaryInterface.circularRosary:
        return _buildCircularRosary();
      case RosaryInterface.horizontalRosary:
        return _buildHorizontalRosary();
      case RosaryInterface.fullScreenTap:
        return _buildFullScreenTap();
      case RosaryInterface.increaseDecreaseButtons:
        return _buildIncreaseDecreaseButtons();
      case RosaryInterface.defaultInterface:
      default:
        return _buildDefaultInterface();
    }
  }

  Widget _buildDefaultInterface() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Tasbeh name
            Text(
              _tasbeh!.name,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Counter display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      'عدد الحبات',
                      style: TextStyle(
                        color: AppColors.greyText,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_tasbeh!.beadsCount}',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'عدد المرات الاجمالي',
                      style: TextStyle(
                        color: AppColors.greyText,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_tasbeh!.totalCount}',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Circular rosary image (simplified)
            GestureDetector(
              onTap: _increment,
              child: Container(
                width: 200,
                height: 200,
                // decoration: BoxDecoration(
                //   shape: BoxShape.circle,
                //   image: _tasbeh!.currentCount == 0
                //       ? null
                //       : const DecorationImage(
                //           image: AssetImage(''),
                //           fit: BoxFit.contain,
                //         ),
                // ),
                child: Center(
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryGreen,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Bottom info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'العدد الكلي: ${_tasbeh!.totalCount}',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'دورة: ${_tasbeh!.cycleCount}',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'مرر للأعلى \\ مرر لليمين للزيادة \\ \\ مرر لليسار للانقاص',
              style: TextStyle(
                color: AppColors.greyText,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularRosary() {
    return GestureDetector(
      onTap: _increment,
      onLongPress: _decrement,
      behavior: HitTestBehavior.opaque, // Makes entire screen tappable
      child: Container(
        color: Colors.transparent, // Ensures full screen is tappable
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Tasbeh name
            Text(
              _tasbeh!.name,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Counter
            Text(
              '${_tasbeh!.currentCount} / ${_tasbeh!.beadsCount}',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 60),
            // Circular rosary with beads and connecting lines
            SizedBox(
              width: 350,
              height: 350,
              child: CustomPaint(
                painter: RosaryPainter(
                  beadsCount: _tasbeh!.beadsCount,
                  currentCount: _tasbeh!.currentCount,
                  beadColor: _beadColor,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Bottom info
            Text(
              'العدد الكلي: ${_tasbeh!.totalCount}',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'مرر لليمين للزيادة \\ مرر لليسار للانقاص',
              style: TextStyle(
                color: AppColors.greyText,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalRosary() {
    return GestureDetector(
      onTap: _increment,
      onLongPress: _decrement,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _tasbeh!.name,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Text(
            '${_tasbeh!.currentCount} / ${_tasbeh!.beadsCount}',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 60),
          // Horizontal beads
          SizedBox(
            height: 80,
            child: ListView.builder(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: _tasbeh!.beadsCount,
              itemBuilder: (context, index) {
                final isActive = index < _tasbeh!.currentCount;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primaryGreen : _beadColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'العدد الكلي: ${_tasbeh!.totalCount}',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                ),
              ),
              Text(
                'دورة: ${_tasbeh!.cycleCount}',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'اضغط في اي مكان للزيادة \\ اضغط مطولا للانقاص',
            style: TextStyle(
              color: AppColors.greyText,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFullScreenTap() {
    return GestureDetector(
      onTap: _increment,
      onLongPress: _decrement,
      child: Container(
        color: AppColors.darkBackground,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _tasbeh!.name,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 80),
              Text(
                '${_tasbeh!.currentCount} / ${_tasbeh!.beadsCount}',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 60),
              Text(
                'عدد المرات الاجمالي',
                style: TextStyle(
                  color: AppColors.greyText,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${_tasbeh!.totalCount}',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 60),
              Text(
                'اضغط في اي مكان للزيادة \\ اضغط مطولا للانقاص',
                style: TextStyle(
                  color: AppColors.greyText,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncreaseDecreaseButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _tasbeh!.name,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  'عدد الحبات',
                  style: TextStyle(
                    color: AppColors.greyText,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_tasbeh!.beadsCount}',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  'عدد المرات الاجمالي',
                  style: TextStyle(
                    color: AppColors.greyText,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_tasbeh!.totalCount}',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  'العدد الحالي',
                  style: TextStyle(
                    color: AppColors.greyText,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_tasbeh!.currentCount}',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  'دورة',
                  style: TextStyle(
                    color: AppColors.greyText,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_tasbeh!.cycleCount}',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 60),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Decrease button
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: _decrement,
                icon: const Icon(
                  Icons.remove,
                  color: AppColors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(width: 40),
            // Counter display
            Text(
              '${_tasbeh!.totalCount}',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 56,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 40),
            // Increase button
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: _increment,
                icon: const Icon(
                  Icons.add,
                  color: AppColors.white,
                  size: 40,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Custom painter for the rosary with connecting lines
class RosaryPainter extends CustomPainter {
  final int beadsCount;
  final int currentCount;
  final Color beadColor;

  RosaryPainter({
    required this.beadsCount,
    required this.currentCount,
    required this.beadColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 40;
    final beadRadius = 10.0; // Smaller bead size

    // Draw connecting lines between beads
    final linePaint = Paint()
      ..color = beadColor.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < beadsCount; i++) {
      final angle1 = (2 * math.pi / beadsCount) * i - math.pi / 2;
      final angle2 =
          (2 * math.pi / beadsCount) * ((i + 1) % beadsCount) - math.pi / 2;

      final x1 = center.dx + radius * math.cos(angle1);
      final y1 = center.dy + radius * math.sin(angle1);
      final x2 = center.dx + radius * math.cos(angle2);
      final y2 = center.dy + radius * math.sin(angle2);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
    }

    // Draw beads
    for (int i = 0; i < beadsCount; i++) {
      final angle = (2 * math.pi / beadsCount) * i - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      // Determine bead color
      Color currentBeadColor;
      if (i == currentCount % beadsCount) {
        // Current position - green
        currentBeadColor = AppColors.primaryGreen;
      } else {
        // Other beads - gold/brown
        currentBeadColor = beadColor;
      }

      // Draw bead shadow
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(x + 2, y + 2), beadRadius, shadowPaint);

      // Draw bead
      final beadPaint = Paint()
        ..color = currentBeadColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), beadRadius, beadPaint);

      // Draw bead border for current position
      if (i == currentCount % beadsCount) {
        final borderPaint = Paint()
          ..color = AppColors.primaryGreen
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(Offset(x, y), beadRadius + 1, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(RosaryPainter oldDelegate) {
    return oldDelegate.currentCount != currentCount ||
        oldDelegate.beadsCount != beadsCount ||
        oldDelegate.beadColor != beadColor;
  }
}
