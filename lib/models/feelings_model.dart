class FeelingModel {
  final String feeling;
  final List<String> duas;
  final String emoji;

  FeelingModel({
    required this.feeling,
    required this.duas,
    String? emoji,
  }) : emoji = emoji ?? _getEmojiForFeeling(feeling);

  factory FeelingModel.fromJson(Map<String, dynamic> json) {
    return FeelingModel(
      feeling: json['feeling'],
      duas: List<String>.from(json['duas']),
      emoji: json['emoji'],
    );
  }

  static String _getEmojiForFeeling(String feeling) {
    switch (feeling) {
      case 'سعادة':
        return '😊';
      case 'الحزن':
        return '😢';
      case 'غضب':
        return '😠';
      case 'قلق':
        return '😰';
      case 'حيرة':
        return '🤔';
      case 'فضول':
        return '🧐';
      case 'حب':
        return '❤️';
      case 'خوف':
        return '😨';
      case 'أمل':
        return '🤲';
      case 'شكر':
        return '🙏';
      case 'ندم':
        return '😔';
      case 'صبر':
        return '💪';
      case 'طمأنينة':
        return '😌';
      default:
        return '🤲';
    }
  }
}
