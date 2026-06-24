import 'package:flutter/material.dart';

class AppColors {
  // Background layers
  static const Color bgPrimary = Color(0xFFFAFAFA);
  static const Color bgSecondary = Color(0xFFF4F4F5);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgCardElevated = Color(0xFFF9FAFB);
  static const Color bgInput = Color(0xFFFFFFFF);
  static const Color bgSurface = Color(0xFFF4F4F5);

  // Emerald accent (primary CTA)
  static const Color accentEmerald = Color(0xFF059669);
  static const Color accentEmeraldDark = Color(0xFF047857);
  static const Color accentEmeraldLight = Color(0xFF34D399);

  // Sidebar
  static const Color sidebarBg = Color(0xFFFFFFFF);
  static const Color sidebarHover = Color(0xFFF4F4F5);
  static const Color sidebarActive = Color(0xFFF0FDF4);
  static const Color sidebarActiveText = Color(0xFF059669);

  // Status colors
  static const Color statusAccepted = Color(0xFF059669);
  static const Color statusRejected = Color(0xFFDC2626);
  static const Color statusActive = Color(0xFF059669);
  static const Color statusPaid = Color(0xFF059669);
  static const Color statusPending = Color(0xFFD97706);
  static const Color statusInactive = Color(0xFFA1A1AA);

  // Text
  static const Color textPrimary = Color(0xFF18181B);
  static const Color textSecondary = Color(0xFF52525B);
  static const Color textMuted = Color(0xFFA1A1AA);
  static const Color textLabel = Color(0xFF71717A);

  // Border
  static const Color border = Color(0xFFE4E4E7);
  static const Color borderLight = Color(0xFFF4F4F5);

  // Chart colors
  static const Color chartAccepted = Color(0xFF059669);
  static const Color chartRejected = Color(0xFFDC2626);
  static const Color chartPaid = Color(0xFF3B82F6);
  static const Color chartPending = Color(0xFFD97706);

  // Semantic aliases
  static const Color error = statusRejected;
  static const Color errorBg = Color(0xFFFEE2E2);

  // Level colors
  static const Color levelJunior = Color(0xFF059669);
  static const Color levelMid = Color(0xFF3B82F6);
  static const Color levelSenior = Color(0xFFD97706);
  static const Color levelLead = Color(0xFF7C3AED);
}
