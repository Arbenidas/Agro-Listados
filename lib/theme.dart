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
  colorScheme: const ColorScheme.light(
    primary: primaryGreen,
    secondary: accentGreen,
    surface: backgroundGreen,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(
      color: textDarkGreen,
      fontWeight: FontWeight.bold,
    ),
    bodyLarge: TextStyle(color: textDarkGreen),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: lightGreen),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: primaryGreen, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: lightGreen),
    ),
  ),
);
