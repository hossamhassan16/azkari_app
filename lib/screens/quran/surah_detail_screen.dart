import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/constants/app_colors.dart';
import '../../models/surah_model.dart';
import '../../models/ayah_model.dart';
import '../../widgets/quran/ayah_item.dart';
import '../../widgets/quran/page_view_mode.dart';
import '../../widgets/quran/quran_settings_bottom_sheet.dart';
import '../../services/saved_verses_service.dart';
import '../../services/quran_api_service.dart';
import '../../services/quran_settings_service.dart';
import '../../services/audio_service.dart';

class SurahDetailScreen extends StatefulWidget {
  final SurahModel surah;

  const SurahDetailScreen({super.key, required this.surah});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final SavedVersesService _savedVersesService = SavedVersesService();
  final QuranApiService _apiService = QuranApiService();
  final QuranSettingsService _settingsService = QuranSettingsService();
  final AudioService _audioService = AudioService();

  bool _isDragging = false;
  double _dragValue = 0;

  List<AyahModel> _ayahs = [];
  bool _isLoading = true;
  String? _error;
  int? _juzNumber;

  @override
  void initState() {
    super.initState();
    _loadAyahs();
    _audioService.selectSurah(widget.surah.number);
  }

  Future<void> _loadAyahs() async {
    try {
      final ayahs = await _apiService.getSurahAyahs(widget.surah.number);
      if (!mounted) return;

      if (ayahs.isNotEmpty) _juzNumber = ayahs.first.juz;

      final savedAyahs = ayahs.map((ayah) {
        final isSaved = _savedVersesService.isVerseSaved(ayah);
        return ayah.copyWith(isSaved: isSaved);
      }).toList();

      setState(() {
        _ayahs = savedAyahs;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSettingsChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.surah.arabicName,
          style: const TextStyle(
            fontFamily: 'AmiriQuran',
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => QuranSettingsBottomSheet(
                  onSettingsChanged: _onSettingsChanged,
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primaryGreen))
              : _buildMainContent(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildMiniAudioPlayer(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_error != null) return _buildErrorWidget();

    return Column(
      children: [
        if (_juzNumber != null) _buildJuzIndicator(),
        Expanded(
          child: _settingsService.displayMode == VerseDisplayMode.list
              ? _buildListView()
              : PageViewMode(
                  ayahs: _ayahs, fontSize: _settingsService.fontSize),
        ),
        StreamBuilder<PlayerState>(
          stream: _audioService.playerStateStream,
          builder: (context, snapshot) {
            return snapshot.data != null && snapshot.data != PlayerState.stopped
                ? const SizedBox(height: 90)
                : const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildJuzIndicator() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: AppColors.cardBackground,
        child: Text(
          'الجزء $_juzNumber',
          style: const TextStyle(color: AppColors.white, fontSize: 16),
          textAlign: TextAlign.right,
        ),
      );

  Widget _buildListView() => ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _ayahs.length,
        itemBuilder: (context, index) {
          final ayah = _ayahs[index];
          return AyahItem(
            ayah: ayah,
            onBookmarkTap: () {
              setState(() {
                if (ayah.isSaved) {
                  _savedVersesService.removeVerse(ayah);
                } else {
                  _savedVersesService.saveVerse(ayah);
                }
                _ayahs[index] = ayah.copyWith(isSaved: !ayah.isSaved);
              });
            },
          );
        },
      );

  Widget _buildMiniAudioPlayer() {
    return StreamBuilder<PlayerState>(
      stream: _audioService.playerStateStream,
      builder: (context, stateSnapshot) {
        final state = stateSnapshot.data;
        if (state == null || state == PlayerState.stopped)
          return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildProgressBar(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        state == PlayerState.playing
                            ? Icons.pause_circle
                            : Icons.play_circle,
                        color: AppColors.primaryGreen,
                        size: 35,
                      ),
                      onPressed: () => state == PlayerState.playing
                          ? _audioService.pause()
                          : _audioService.playCurrentSurah(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.surah.arabicName,
                              style: const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold)),
                          Text(_settingsService.selectedReader?.name ?? "",
                              style: const TextStyle(
                                  color: AppColors.primaryGreen, fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.close, color: Colors.grey, size: 20),
                      onPressed: () async {
                        await _audioService.stop();
                        if (mounted) setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar() {
    return ValueListenableBuilder<Duration>(
      valueListenable: _audioService.durationNotifier,
      builder: (context, duration, _) {
        final maxDuration = duration.inMilliseconds.toDouble();
        return ValueListenableBuilder<Duration>(
          valueListenable: _audioService.positionNotifier,
          builder: (context, position, _) {
            double currentValue =
                _isDragging ? _dragValue : position.inMilliseconds.toDouble();
            if (maxDuration <= 0)
              currentValue = 0.0;
            else
              currentValue = currentValue.clamp(0.0, maxDuration);

            return SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: AppColors.primaryGreen,
                inactiveTrackColor: Colors.grey.withOpacity(0.3),
                thumbColor: AppColors.primaryGreen,
              ),
              child: Slider(
                min: 0.0,
                max: maxDuration > 0 ? maxDuration : 1.0,
                value: currentValue,
                onChangeStart: (_) => setState(() => _isDragging = true),
                onChanged: (value) => setState(() => _dragValue = value),
                onChangeEnd: (value) async {
                  await _audioService
                      .seek(Duration(milliseconds: value.toInt()));
                  setState(() => _isDragging = false);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildErrorWidget() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('حدث خطأ في تحميل البيانات',
                style: TextStyle(color: AppColors.white)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAyahs,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
}
