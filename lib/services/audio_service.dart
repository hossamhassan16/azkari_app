import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../services/quran_settings_service.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  final QuranSettingsService _settings = QuranSettingsService();

  int? currentSurahNumber;

  // ValueNotifier لضمان تحديث واجهة المستخدم تلقائيًا
  final ValueNotifier<Duration> positionNotifier = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> durationNotifier = ValueNotifier(Duration.zero);
  Stream<PlayerState> get playerStateStream => _player.onPlayerStateChanged;

  void selectSurah(int number) {
    currentSurahNumber = number;
  }

  Future<void> playCurrentSurah() async {
    if (currentSurahNumber == null) return;
    final reader = _settings.selectedReader;
    if (reader == null) return;

    // لو السورة نفسها مش شغالة بالفعل
    if (_player.state == PlayerState.paused ||
        _player.state == PlayerState.playing) {
      // لو هي متوقفة مؤقتًا وعايز تكمل
      await _player.resume();
      return;
    }

    String baseUrl = reader.moshaf[0].server;
    String formattedNumber = currentSurahNumber.toString().padLeft(3, '0');
    String finalUrl = "$baseUrl$formattedNumber.mp3";

    await _player.stop();
    await _player.setSourceUrl(finalUrl);

    _player.onDurationChanged.listen((duration) {
      durationNotifier.value = duration;
    });

    _player.onPositionChanged.listen((position) {
      positionNotifier.value = position;
    });

    await _player.resume();
  }
final ValueNotifier<int> currentAyahIndexNotifier = ValueNotifier(-1);

// نفترض عندك قائمة أزمنة الآيات (بالثواني) مثلًا
List<Duration> ayahStartTimes = []; // طول القائمة = عدد الآيات

void _updateCurrentAyah(Duration position) {
  for (int i = 0; i < ayahStartTimes.length; i++) {
    if (position < ayahStartTimes[i]) {
      currentAyahIndexNotifier.value = i - 1;
      return;
    }
  }
  currentAyahIndexNotifier.value = ayahStartTimes.length - 1;
}

void _listenPosition() {
  _player.onPositionChanged.listen((position) {
    positionNotifier.value = position;
    _updateCurrentAyah(position);
  });
}

  Future<void> pause() async => await _player.pause();
  Future<void> resume() async => await _player.resume();
  Future<void> stop() async {
    await _player.stop();
    positionNotifier.value = Duration.zero;
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
    positionNotifier.value = position;
  }
}
