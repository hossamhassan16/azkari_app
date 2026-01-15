import 'package:flutter/material.dart';

enum StoryType {
  hadith,
  duaa,
  ayah,
}

class StoryModel {
  final String id;
  final StoryType type;
  final String title;
  final String content;
  final IconData icon;
  final DateTime lastUpdated;
  final bool isViewed;

  StoryModel({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.icon,
    required this.lastUpdated,
    this.isViewed = false,
  });

  // Get display title based on type
  String get displayTitle {
    switch (type) {
      case StoryType.hadith:
        return 'حديث اليوم';
      case StoryType.duaa:
        return 'دعاء اليوم';
      case StoryType.ayah:
        return 'آية اليوم';
    }
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'title': title,
      'content': content,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isViewed': isViewed,
    };
  }

  // Create from JSON
  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'],
      type: StoryType.values[json['type']],
      title: json['title'],
      content: json['content'],
      icon: _getIconForType(StoryType.values[json['type']]),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      isViewed: json['isViewed'] ?? false,
    );
  }

  // Copy with new values
  StoryModel copyWith({
    String? id,
    StoryType? type,
    String? title,
    String? content,
    IconData? icon,
    DateTime? lastUpdated,
    bool? isViewed,
  }) {
    return StoryModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      icon: icon ?? this.icon,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isViewed: isViewed ?? this.isViewed,
    );
  }

  static IconData _getIconForType(StoryType type) {
    switch (type) {
      case StoryType.hadith:
        return Icons.menu_book;
      case StoryType.duaa:
        return Icons.pan_tool_alt;
      case StoryType.ayah:
        return Icons.chrome_reader_mode;
    }
  }
}
