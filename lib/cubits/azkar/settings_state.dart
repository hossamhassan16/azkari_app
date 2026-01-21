part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final bool isHorizontal;
  final double fontSize;
  final bool vibrateAtZero;
  final bool hideAtZero;
  final bool tapOnCardToCount;
  final bool confirmExit;

  const SettingsState({
    required this.isHorizontal,
    required this.fontSize,
    required this.vibrateAtZero,
    required this.hideAtZero,
    required this.tapOnCardToCount,
    required this.confirmExit,
  });

  SettingsState copyWith({
    bool? isHorizontal,
    double? fontSize,
    bool? vibrateAtZero,
    bool? hideAtZero,
    bool? tapOnCardToCount,
    bool? confirmExit,
  }) {
    return SettingsState(
      isHorizontal: isHorizontal ?? this.isHorizontal,
      fontSize: fontSize ?? this.fontSize,
      vibrateAtZero: vibrateAtZero ?? this.vibrateAtZero,
      hideAtZero: hideAtZero ?? this.hideAtZero,
      tapOnCardToCount: tapOnCardToCount ?? this.tapOnCardToCount,
      confirmExit: confirmExit ?? this.confirmExit,
    );
  }

  @override
  List<Object?> get props => [
        isHorizontal,
        fontSize,
        vibrateAtZero,
        hideAtZero,
        tapOnCardToCount,
        confirmExit,
      ];
}
