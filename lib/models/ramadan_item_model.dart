import 'package:flutter/material.dart';

class RamadanItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? badge;

  const RamadanItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.badge,
  });
}
