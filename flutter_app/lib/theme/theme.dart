import 'package:flutter/material.dart';

class AppTheme {
  static const gradient = LinearGradient(
    colors: [Color(0xFF6D28D9), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxDecoration glassDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(24),
    color: Colors.white.withOpacity(0.08),
  );
}