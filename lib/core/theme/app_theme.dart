import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    colorSchemeSeed: Colors.deepPurple,

    scaffoldBackgroundColor: const Color(0xffF6F7FB),

    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black,
    ),

    cardTheme: CardThemeData(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      elevation: 8,
      height: 72,

      indicatorColor: const Color(0xffE9E5FF),

      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        return TextStyle(
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.bold
              : FontWeight.w500,
        );
      }),

      iconTheme: WidgetStateProperty.resolveWith((states) {
        return IconThemeData(
          size: 26,
          color: states.contains(WidgetState.selected)
              ? const Color(0xff5B4DFF)
              : Colors.grey,
        );
      }),
    ),
  );
}
