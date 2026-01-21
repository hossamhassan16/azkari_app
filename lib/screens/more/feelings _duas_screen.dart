import 'package:azkari_app/models/duaa_item_model.dart';
import 'package:azkari_app/models/feelings_model.dart';
import 'package:azkari_app/widgets/azkar/duaa_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

class FeelingDuasScreen extends StatefulWidget {
  final List<FeelingModel> feelings;
  final int initialFeelingIndex;

  const FeelingDuasScreen({
    super.key,
    required this.feelings,
    this.initialFeelingIndex = 0,
  });

  @override
  State<FeelingDuasScreen> createState() => _FeelingDuasScreenState();
}

class _FeelingDuasScreenState extends State<FeelingDuasScreen> {
  late int _currentFeelingIndex;
  late Map<int, List<DuaItemModel>> _duasMap;

  @override
  void initState() {
    super.initState();
    _currentFeelingIndex = widget.initialFeelingIndex;
    _duasMap = {};
    _initializeAllDuas();
  }

  void _initializeAllDuas() {
    for (int i = 0; i < widget.feelings.length; i++) {
      _duasMap[i] = widget.feelings[i].duas.asMap().entries.map((entry) {
        return DuaItemModel(
          id: '${widget.feelings[i].feeling}_${entry.key}',
          content: entry.value,
          count: 1,
          currentCount: 1,
        );
      }).toList();
    }
  }

  List<DuaItemModel> get _currentDuas => _duasMap[_currentFeelingIndex] ?? [];
  FeelingModel get _currentFeeling => widget.feelings[_currentFeelingIndex];

  void _decrementCounter(int index) {
    final currentDuas = _currentDuas;
    if (currentDuas[index].currentCount <= 0) return;

    setState(() {
      _duasMap[_currentFeelingIndex]![index] = currentDuas[index].copyWith(
        currentCount: currentDuas[index].currentCount - 1,
      );
    });

    // Vibrate on reaching zero
    if (_duasMap[_currentFeelingIndex]![index].currentCount == 0) {
      HapticFeedback.mediumImpact();
    }
  }

  void _resetCounters() {
    setState(() {
      _duasMap[_currentFeelingIndex] =
          _duasMap[_currentFeelingIndex]!.map((dua) {
        return dua.copyWith(currentCount: dua.count);
      }).toList();
    });
  }

  void _changeFeelingIndex(int? newIndex) {
    if (newIndex != null && newIndex != _currentFeelingIndex) {
      setState(() {
        _currentFeelingIndex = newIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedCount =
        _currentDuas.where((d) => d.currentCount == 0).length;
    final allCompleted = completedCount == _currentDuas.length;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primaryGreen),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _currentFeelingIndex,
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.white),
              dropdownColor: AppColors.cardBackground,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              items: widget.feelings.asMap().entries.map((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key,
                  child: Row(
                    children: [
                      Text(
                        entry.value.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(entry.value.feeling),
                    ],
                  ),
                );
              }).toList(),
              onChanged: _changeFeelingIndex,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.white),
            onPressed: _resetCounters,
          ),
        ],
      ),
      body: allCompleted
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentFeeling.emoji,
                    style: const TextStyle(fontSize: 80),
                  ),
                  const SizedBox(height: 16),
                  const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.primaryGreen,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'أحسنت! أنهيت جميع الأدعية',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _resetCounters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'إعادة البدء',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _currentDuas.length,
              itemBuilder: (context, index) {
                return DuaCard(
                  dua: _currentDuas[index],
                  onCounterTap: () => _decrementCounter(index),
                );
              },
            ),
    );
  }
}
