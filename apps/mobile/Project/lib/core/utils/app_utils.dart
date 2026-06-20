import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateUtils {
  static String formatDateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(isoString);
      return DateFormat('M/d/yyyy, h:mm:ss a').format(dt);
    } catch (_) {
      return isoString;
    }
  }

  static String formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(isoString);
      return DateFormat('M/d/yyyy').format(dt);
    } catch (_) {
      return isoString;
    }
  }

  static String formatSynced(DateTime dt) {
    return 'Synced ${DateFormat('M/d/yyyy, h:mm:ss a').format(dt)}';
  }
}

extension StringExtensions on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';

  String get initials {
    final parts = trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

extension ContextExtensions on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;

  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}
