import 'package:flutter/material.dart';

class AppColors {
  // Background layers
  static const Color bgPrimary = Color(0xFF0A0F1A);
  static const Color bgSecondary = Color(0xFF0D1422);
  static const Color bgCard = Color(0xFF111827);
  static const Color bgCardElevated = Color(0xFF161E2E);
  static const Color bgInput = Color(0xFF0D1422);
  static const Color bgSurface = Color(0xFF1A2235);

  // Cyan/Teal accent (primary CTA)
  static const Color accentCyan = Color(0xFF38BDF8);
  static const Color accentCyanDark = Color(0xFF0EA5E9);
  static const Color accentCyanLight = Color(0xFF7DD3FC);

  // Status colors
  static const Color statusApplied = Color(0xFF0EA5E9);
  static const Color statusInterview = Color(0xFF6B7280);
  static const Color statusHired = Color(0xFF6B7280);
  static const Color statusAppliedBg = Color(0xFF0C2340);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLabel = Color(0xFF6B7280);

  // Border
  static const Color border = Color(0xFF1E293B);
  static const Color borderLight = Color(0xFF263148);

  // Pipeline stages
  static const Color stageActive = Color(0xFFF59E0B);
  static const Color stageInactive = Color(0xFF374151);

  // Gradient for background
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A0F1A),
      Color(0xFF0D1828),
      Color(0xFF0A0F1A),
    ],
  );

  // Teal glow for login background
  static const RadialGradient loginTopGlow = RadialGradient(
    center: Alignment(-0.8, -0.8),
    radius: 1.5,
    colors: [
      Color(0x2506B6D4),
      Color(0x000A0F1A),
    ],
  );

  static const RadialGradient loginBottomGlow = RadialGradient(
    center: Alignment(0.8, 0.8),
    radius: 1.2,
    colors: [
      Color(0x1506B6D4),
      Color(0x000A0F1A),
    ],
  );
}
