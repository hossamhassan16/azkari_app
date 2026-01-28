import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/quran_settings_service.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  final QuranSettingsService _settings = QuranSettingsService();

  int? currentSurahNumber;

  final ValueNotifier<Duration> positionNotifier = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> durationNotifier = ValueNotifier(Duration.zero);

  final ValueNotifier<int> currentAyahIndexNotifier = ValueNotifier(-1);

  List<Duration> ayahStartTimes = [];

  Stream<PlayerState> get playerStateStream => _player.onPlayerStateChanged;

  void selectSurah(int number) {
    currentSurahNumber = number;
  }

  Future<void> _loadAyahTimings() async {
    if (currentSurahNumber == null) return;
    final reader = _settings.selectedReader;
    if (reader == null) return;

    final url =
        'https://www.mp3quran.net/api/v3/ayat_timing?surah=$currentSurahNumber&read=${reader.id}';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) return;

    final List data = jsonDecode(response.body); // هنا List بدل Map

    ayahStartTimes = data.map<Duration>((ayahData) {
      final int startMs = ayahData['start_time'] is int
          ? ayahData['start_time']
          : int.tryParse(ayahData['start_time'].toString()) ?? 0;
      return Duration(milliseconds: startMs);
    }).toList()
      ..sort((a, b) => a.inMilliseconds.compareTo(b.inMilliseconds));
  }

  void _updateCurrentAyah(Duration position) {
    for (int i = 0; i < ayahStartTimes.length; i++) {
      if (position < ayahStartTimes[i]) {
        currentAyahIndexNotifier.value = i - 1;
        return;
      }
    }
    if (ayahStartTimes.isNotEmpty) {
      currentAyahIndexNotifier.value = ayahStartTimes.length - 1;
    }
  }

  Future<void> playCurrentSurah() async {
    if (currentSurahNumber == null) return;
    final reader = _settings.selectedReader;
    if (reader == null) return;

    if (_player.state == PlayerState.paused ||
        _player.state == PlayerState.playing) {
      await _player.resume();
      return;
    }

    await _loadAyahTimings();

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
      _updateCurrentAyah(position);
    });

    await _player.resume();
  }

  Future<void> pause() async => await _player.pause();

  Future<void> resume() async => await _player.resume();

  Future<void> stop() async {
    await _player.stop();
    positionNotifier.value = Duration.zero;
    currentAyahIndexNotifier.value = -1;
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
    positionNotifier.value = position;
  }
}
