import 'package:flutter/material.dart';

class MainTheme {
  static ThemeData mainThemeData(bool isDarkMode) {
    return ThemeData(
      scaffoldBackgroundColor: Colors.white,
      splashColor: Colors.grey.withValues(alpha: 0.11),
      highlightColor: Colors.grey.withValues(alpha: 0.11),

      // Add your main theme here
    );
  }
}
