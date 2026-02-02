import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Modern, vibrant theme for StrayCare Connect
/// Following Material 3 design principles with custom colors
class AppTheme {
  // Brand Colors - Vibrant and Emotional
  static const Color primaryOrange = Color(0xFFFF6B35); // Warm, urgent
  static const Color primaryDeep = Color(0xFF2D3142); // Professional dark
  static const Color accentGreen = Color(0xFF4ECDC4); // Success, safe
  static const Color warningRed = Color(0xFFFF5252); // Critical
  static const Color warningOrange = Color(0xFFFFAB40); // Medium urgency
  static const Color softBeige = Color(0xFFF7F7F2); // Background
  static const Color cardWhite = Color(0xFFFFFFFF);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient criticalGradient = LinearGradient(
    colors: [Color(0xFFFF5252), Color(0xFFFF6B6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Color Scheme
    colorScheme: ColorScheme.light(
      primary: primaryOrange,
      secondary: accentGreen,
      tertiary: primaryDeep,
      error: warningRed,
      surface: cardWhite,
      surfaceContainerHighest: softBeige,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: primaryDeep,
    ),
    
    // Scaffold
    scaffoldBackgroundColor: softBeige,
    
    // AppBar Theme
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Colors.transparent,
      foregroundColor: primaryDeep,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: primaryDeep,
      ),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: cardWhite,
      shadowColor: Colors.black.withOpacity(0.1),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: primaryOrange, width: 2),
        foregroundColor: primaryOrange,
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryOrange,
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryOrange,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryOrange, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: warningRed, width: 2),
      ),
      labelStyle: TextStyle(
        fontFamily: 'Roboto',
        color: Colors.grey.shade700,
        fontSize: 14,
      ),
      hintStyle: TextStyle(
        fontFamily: 'Roboto',
        color: Colors.grey.shade400,
        fontSize: 14,
      ),
    ),
    
    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: softBeige,
      selectedColor: primaryOrange,
      labelStyle: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardWhite,
      selectedItemColor: primaryOrange,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 12,
      ),
    ),
    
    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: primaryDeep,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: primaryDeep,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: primaryDeep,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primaryDeep,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryDeep,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryDeep,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryDeep,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryDeep,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16,
        color: primaryDeep,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
        color: primaryDeep,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 12,
        color: Colors.grey,
      ),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    colorScheme: ColorScheme.dark(
      primary: primaryOrange,
      secondary: accentGreen,
      tertiary: primaryDeep,
      error: warningRed,
      surface: const Color(0xFF1A1A2E),
      surfaceContainerHighest: const Color(0xFF16213E),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),
    
    scaffoldBackgroundColor: const Color(0xFF0F0F1E),
    
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: const Color(0xFF1A1A2E),
    ),
    
    // Similar configurations for dark theme...
  );

  // Utility methods
  static Color getEmergencyColor(String level) {
    switch (level.toLowerCase()) {
      case 'critical':
        return warningRed;
      case 'medium':
        return warningOrange;
      case 'low':
        return accentGreen;
      default:
        return Colors.grey;
    }
  }

  static IconData getAnimalIcon(String type) {
    switch (type.toLowerCase()) {
      case 'dog':
        return Icons.pets;
      case 'cat':
        return Icons.pets;
      case 'cow':
        return Icons.agriculture;
      case 'bird':
        return Icons.flutter_dash;
      default:
        return Icons.pets;
    }
  }
}
