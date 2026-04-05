import 'package:flutter/material.dart';

/// One entry in the bottom navigation bar.
class AppNavItem {
  const AppNavItem({
    required this.route,
    required this.label,
    required this.icon,
  });

  final String route;
  final String label;
  final IconData icon;
}
