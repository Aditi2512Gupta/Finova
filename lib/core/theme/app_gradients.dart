import 'package:flutter/material.dart';

class AppGradients {
  AppGradients._();

  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF5B4DFF),
      Color(0xFF8B5CF6),
    ],
  );

  static const expense = LinearGradient(
    colors: [
      Color(0xFFFF6B6B),
      Color(0xFFFF8E53),
    ],
  );

  static const income = LinearGradient(
    colors: [
      Color(0xFF00C853),
      Color(0xFF64DD17),
    ],
  );

  static const wallet = LinearGradient(
    colors: [
      Color(0xFF5E60CE),
      Color(0xFF7400B8),
    ],
  );

  static const receipt = LinearGradient(
    colors: [
      Color(0xFFF9A826),
      Color(0xFFF3722C),
    ],
  );
}