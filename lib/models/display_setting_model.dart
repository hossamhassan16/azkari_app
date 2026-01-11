class DisplaySettingsModel {
  final DisplayOrientation orientation; // أفقي أو عامودي
  final double fontSize;
  final double fontSizeDay; // حجم خط أذكار اليوم والليلة
  final bool vibrateOnZero; // ارتجاج عند الصفر
  final bool hideOnZero; // اخفاء عند الصفر
  final bool tapToDecrement; // العد بالضغط على الذكر
  final bool confirmExit; // تأكيد الخروج

  DisplaySettingsModel({
    this.orientation = DisplayOrientation.vertical,
    this.fontSize = 24.0,
    this.fontSizeDay = 24.0,
    this.vibrateOnZero = true,
    this.hideOnZero = false,
    this.tapToDecrement = true,
    this.confirmExit = true,
  });

  factory DisplaySettingsModel.fromJson(Map<String, dynamic> json) {
    return DisplaySettingsModel(
      orientation: json['orientation'] == 'horizontal'
          ? DisplayOrientation.horizontal
          : DisplayOrientation.vertical,
      fontSize: json['fontSize']?.toDouble() ?? 24.0,
      fontSizeDay: json['fontSizeDay']?.toDouble() ?? 24.0,
      vibrateOnZero: json['vibrateOnZero'] ?? true,
      hideOnZero: json['hideOnZero'] ?? false,
      tapToDecrement: json['tapToDecrement'] ?? true,
      confirmExit: json['confirmExit'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orientation': orientation == DisplayOrientation.horizontal
          ? 'horizontal'
          : 'vertical',
      'fontSize': fontSize,
      'fontSizeDay': fontSizeDay,
      'vibrateOnZero': vibrateOnZero,
      'hideOnZero': hideOnZero,
      'tapToDecrement': tapToDecrement,
      'confirmExit': confirmExit,
    };
  }

  DisplaySettingsModel copyWith({
    DisplayOrientation? orientation,
    double? fontSize,
    double? fontSizeDay,
    bool? vibrateOnZero,
    bool? hideOnZero,
    bool? tapToDecrement,
    bool? confirmExit,
  }) {
    return DisplaySettingsModel(
      orientation: orientation ?? this.orientation,
      fontSize: fontSize ?? this.fontSize,
      fontSizeDay: fontSizeDay ?? this.fontSizeDay,
      vibrateOnZero: vibrateOnZero ?? this.vibrateOnZero,
      hideOnZero: hideOnZero ?? this.hideOnZero,
      tapToDecrement: tapToDecrement ?? this.tapToDecrement,
      confirmExit: confirmExit ?? this.confirmExit,
    );
  }
}

enum DisplayOrientation {
  horizontal, // أفقي
  vertical, // عامودي
}
