import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/ayah_model.dart';
import '../../models/tafseer_model.dart';
import '../../services/tafseer_service.dart';

class TafseerScreen extends StatefulWidget {
  final AyahModel ayah;

  const TafseerScreen({
    super.key,
    required this.ayah,
  });

  @override
  State<TafseerScreen> createState() => _TafseerScreenState();
}

class _TafseerScreenState extends State<TafseerScreen> {
  final TafseerService _tafseerService = TafseerService();
  List<TafseerInfo> _tafseerList = [];
  TafseerInfo? _selectedTafseer;
  TafseerContent? _currentTafseer;
  bool _isLoadingTafseers = true;
  bool _isLoadingContent = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTafseerList();
  }

  Future<void> _loadTafseerList() async {
    try {
      final tafseers = await _tafseerService.getAllTafseers();
      if (!mounted) return;
      
      setState(() {
        _tafseerList = tafseers;
        _selectedTafseer = tafseers.isNotEmpty ? tafseers[0] : null;
        _isLoadingTafseers = false;
      });

      if (_selectedTafseer != null) {
        _loadTafseerContent(_selectedTafseer!);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoadingTafseers = false;
      });
    }
  }

  Future<void> _loadTafseerContent(TafseerInfo tafseerInfo) async {
    setState(() {
      _isLoadingContent = true;
      _error = null;
    });

    try {
      final content = await _tafseerService.getTafseerForAyah(
        tafseerId: tafseerInfo.id,
        surahNumber: widget.ayah.surahNumber,
        ayahNumber: widget.ayah.number,
      );

      if (!mounted) return;
      setState(() {
        _currentTafseer = content;
        _isLoadingContent = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoadingContent = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'تفسير الآية',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoadingTafseers
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
              ),
            )
          : _error != null && _tafseerList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'حدث خطأ في تحميل التفاسير',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTafseerList,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                        ),
                        child: const Text(
                          'إعادة المحاولة',
                          style: TextStyle(color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Tafseer selector
                      if (_tafseerList.isNotEmpty) ...[
                        _buildTafseerSelector(),
                      ],

                      // Ayah text
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryGreen.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.ayah.text,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontFamily: 'AmiriQuran',
                            color: AppColors.white,
                            fontSize: 24,
                            height: 2,
                          ),
                        ),
                      ),

                      // Divider
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        height: 1,
                        color: AppColors.greyText.withOpacity(0.3),
                      ),

                      // Tafseer title
                      if (_selectedTafseer != null)
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _selectedTafseer!.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      // Tafseer content
                      if (_isLoadingContent)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        )
                      else if (_error != null && _currentTafseer == null)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'حدث خطأ في تحميل التفسير',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.greyText,
                              fontSize: 16,
                            ),
                          ),
                        )
                      else if (_currentTafseer != null)
                        Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _currentTafseer!.text,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              height: 2,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildTafseerSelector() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TafseerInfo>(
          value: _selectedTafseer,
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
          items: _tafseerList.map((tafseer) {
            return DropdownMenuItem<TafseerInfo>(
              value: tafseer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tafseer.name,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'المؤلف: ${tafseer.author}',
                    style: TextStyle(
                      color: AppColors.greyText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (TafseerInfo? newValue) {
            if (newValue != null && newValue != _selectedTafseer) {
              setState(() {
                _selectedTafseer = newValue;
              });
              _loadTafseerContent(newValue);
            }
          },
        ),
      ),
    );
  }
}
