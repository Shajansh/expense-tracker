import 'package:flutter/material.dart';

class AppColors {
  // Primary Gradient (Cool Blue to Teal - Eye Cooling)
  static const Color primary = Color(0xFF0891B2); // Cool Cyan
  static const Color primaryDark = Color(0xFF0E7490); // Deep Teal
  static const Color accent = Color(0xFF06B6D4); // Bright Cyan
  static const Color accentLight = Color(0xFF22D3EE); // Light Cyan

  // Semantic Colors
  static const Color success = Color(0xFF14B8A6); // Mint Green
  static const Color warning = Color(0xFF8B5CF6); // Cool Purple
  static const Color error = Color(0xFF38BDF8); // Soft Blue
  static const Color info = Color(0xFF3B82F6); // Cool Blue

  // Neutral Colors
  static const Color darkBg = Color(0xFF0C2D3D); // Deep Teal Navy
  static const Color cardBg = Color(0xFF164E63); // Dark Cool Teal
  static const Color borderColor = Color(0xFF155E75); // Cool Slate
  static const Color textPrimary = Color(0xFFCFFAFE); // Cool White
  static const Color textSecondary = Color(0xFFA5F3FC); // Light Cyan
  static const Color textHint = Color(0xFF67E8F9); // Medium Cyan

  // Light Theme
  static const Color lightBg = Color(0xFFF0F9FF); // Very Light Sky
  static const Color lightCard = Color(0xFFE0F2FE); // Soft Sky
  static const Color lightBorder = Color(0xFFBAE6FD); // Light Sky
  static const Color lightText = Color(0xFF0C3C54); // Dark Teal
  static const Color lightTextSecondary = Color(0xFF0E7490); // Teal

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [primaryDark, Color(0xFF067E8A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [success, Color(0xFF0D9488)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [error, Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
