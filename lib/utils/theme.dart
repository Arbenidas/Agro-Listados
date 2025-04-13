import 'package:flutter/material.dart';

// Vegetable market theme colors
const Color primaryGreen = Color(0xFF2E7D32); // Dark green
const Color lightGreen = Color(0xFF81C784); // Light green
const Color accentGreen = Color(0xFF66BB6A); // Medium green
const Color backgroundGreen = Color(0xFFE8F5E9); // Very light green
const Color textDarkGreen = Color(0xFF1B5E20); // Very dark green

final ThemeData veggieMarketTheme = ThemeData(
  primaryColor: primaryGreen,
  scaffoldBackgroundColor: backgroundGreen,
  colorScheme: ColorScheme.light(
    primary: primaryGreen,
    secondary: accentGreen,
    surface: backgroundGreen,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(
      color: textDarkGreen,
      fontWeight: FontWeight.bold,
      fontSize: 28,
    ),
    displayMedium: TextStyle(
      color: textDarkGreen,
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
    bodyLarge: TextStyle(color: textDarkGreen, fontSize: 16),
    bodyMedium: TextStyle(color: textDarkGreen, fontSize: 14),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      elevation: 3,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: primaryGreen,
      side: BorderSide(color: primaryGreen, width: 2),
      padding: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: lightGreen),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: primaryGreen, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: lightGreen),
    ),
    prefixIconColor: primaryGreen,
    suffixIconColor: primaryGreen,
    hintStyle: TextStyle(color: Colors.grey.shade400),
  ),
);
