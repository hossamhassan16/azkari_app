import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences prefs;

  SettingsCubit(this.prefs)
      : super(SettingsState(
          isHorizontal: prefs.getBool('azkar_is_horizontal') ?? false,
          fontSize: prefs.getDouble('azkar_font_size') ?? 24.0,
          vibrateAtZero: prefs.getBool('azkar_vibrate_at_zero') ?? true,
          hideAtZero: prefs.getBool('azkar_hide_at_zero') ?? false,
          tapOnCardToCount: prefs.getBool('azkar_tap_on_card') ?? false,
          confirmExit: prefs.getBool('azkar_confirm_exit') ?? false,
        ));

  /// Toggle display mode between horizontal and vertical
  Future<void> toggleDisplayMode() async {
    final newValue = !state.isHorizontal;
    await prefs.setBool('azkar_is_horizontal', newValue);
    emit(state.copyWith(isHorizontal: newValue));
  }

  /// Update font size
  Future<void> updateFontSize(double fontSize) async {
    await prefs.setDouble('azkar_font_size', fontSize);
    emit(state.copyWith(fontSize: fontSize));
  }

  /// Toggle vibrate at zero
  Future<void> toggleVibrateAtZero() async {
    final newValue = !state.vibrateAtZero;
    await prefs.setBool('azkar_vibrate_at_zero', newValue);
    emit(state.copyWith(vibrateAtZero: newValue));
  }

  /// Toggle hide at zero
  Future<void> toggleHideAtZero() async {
    final newValue = !state.hideAtZero;
    await prefs.setBool('azkar_hide_at_zero', newValue);
    emit(state.copyWith(hideAtZero: newValue));
  }

  /// Toggle tap on card to count
  Future<void> toggleTapOnCard() async {
    final newValue = !state.tapOnCardToCount;
    await prefs.setBool('azkar_tap_on_card', newValue);
    emit(state.copyWith(tapOnCardToCount: newValue));
  }

  /// Toggle confirm exit
  Future<void> toggleConfirmExit() async {
    final newValue = !state.confirmExit;
    await prefs.setBool('azkar_confirm_exit', newValue);
    emit(state.copyWith(confirmExit: newValue));
  }

  /// Update multiple settings at once
  Future<void> updateSettings({
    bool? isHorizontal,
    double? fontSize,
    bool? vibrateAtZero,
    bool? hideAtZero,
    bool? tapOnCardToCount,
    bool? confirmExit,
  }) async {
    if (isHorizontal != null) {
      await prefs.setBool('azkar_is_horizontal', isHorizontal);
    }
    if (fontSize != null) {
      await prefs.setDouble('azkar_font_size', fontSize);
    }
    if (vibrateAtZero != null) {
      await prefs.setBool('azkar_vibrate_at_zero', vibrateAtZero);
    }
    if (hideAtZero != null) {
      await prefs.setBool('azkar_hide_at_zero', hideAtZero);
    }
    if (tapOnCardToCount != null) {
      await prefs.setBool('azkar_tap_on_card', tapOnCardToCount);
    }
    if (confirmExit != null) {
      await prefs.setBool('azkar_confirm_exit', confirmExit);
    }

    emit(state.copyWith(
      isHorizontal: isHorizontal ?? state.isHorizontal,
      fontSize: fontSize ?? state.fontSize,
      vibrateAtZero: vibrateAtZero ?? state.vibrateAtZero,
      hideAtZero: hideAtZero ?? state.hideAtZero,
      tapOnCardToCount: tapOnCardToCount ?? state.tapOnCardToCount,
      confirmExit: confirmExit ?? state.confirmExit,
    ));
  }
}
