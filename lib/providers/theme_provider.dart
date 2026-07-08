import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  int _accentIndex = 0;

  final FirestoreService _firestoreService = FirestoreService();

  final List<Color> accentColors = const [
    Color(0xFF6C4CF1), // Purple (Default)
    Color(0xFF2563EB), // Blue
    Color(0xFF10B981), // Green
    Color(0xFFF59E0B), // Orange
    Color(0xFFEC4899), // Pink
  ];

  final List<String> accentNames = const [
    "Purple",
    "Blue",
    "Green",
    "Orange",
    "Pink",
  ];

  ThemeProvider() {
    loadUserPreferences();
  }

  bool get isDarkMode => _isDarkMode;
  int get accentIndex => _accentIndex;
  Color get primaryColor => accentColors[_accentIndex];

  Color get secondaryColor {
    // Return a slightly lighter variant or shade of the primary color
    final primary = primaryColor;
    return primary.withOpacity(0.8);
  }

  Color get backgroundColor {
    return _isDarkMode ? const Color(0xFF0C0E1B) : const Color(0xFFF6F7FB);
  }

  Color get surfaceColor {
    return _isDarkMode ? const Color(0xFF16192E) : Colors.white;
  }

  Color get textPrimary {
    return _isDarkMode ? Colors.white : const Color(0xFF1F2937);
  }

  Color get textSecondary {
    return _isDarkMode ? Colors.grey.shade400 : const Color(0xFF6B7280);
  }

  Color get borderColor {
    return _isDarkMode
        ? Colors.white.withOpacity(0.06)
        : Colors.black.withOpacity(0.04);
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestoreService.saveUserPreferences(
        uid: user.uid,
        isDarkMode: _isDarkMode,
        accentIndex: _accentIndex,
      );
    } catch (e) {
      debugPrint("Failed to save theme: $e");
    }
  }

  Future<void> setAccentColor(int index) async {
    if (index < 0 || index >= accentColors.length) return;

    _accentIndex = index;
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestoreService.saveUserPreferences(
        uid: user.uid,
        isDarkMode: _isDarkMode,
        accentIndex: _accentIndex,
      );
    } catch (e) {
      debugPrint("Failed to save accent color: $e");
    }
  }

  Future<void> loadUserPreferences() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final prefs = await _firestoreService.getUserPreferences(user.uid);

    _isDarkMode = prefs['isDarkMode'] ?? false;
    _accentIndex = prefs['accentIndex'] ?? 0;

    notifyListeners();
  }
}
