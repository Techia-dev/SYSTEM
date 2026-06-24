import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    switch (status.toLowerCase()) {
      case 'applied':
        bg = const Color(0xFFDBEAFE); text = const Color(0xFF1D4ED8);
      case 'interview':
        bg = const Color(0xFFFEF3C7); text = const Color(0xFFB45309);
      case 'accepted':
      case 'hired':
        bg = const Color(0xFFD1FAE5); text = const Color(0xFF047857);
      case 'rejected':
        bg = const Color(0xFFFEE2E2); text = const Color(0xFFB91C1C);
      default:
        bg = const Color(0xFFF3F4F6); text = const Color(0xFF6B7280);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(status[0].toUpperCase() + status.substring(1), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: text)),
    );
  }
}

class LevelBadge extends StatelessWidget {
  final String level;
  const LevelBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (level.toLowerCase()) {
      case 'junior': color = const Color(0xFF6B7280); break;
      case 'mid': color = const Color(0xFF3B82F6); break;
      case 'senior': color = const Color(0xFFF59E0B); break;
      case 'lead': color = const Color(0xFF8B5CF6); break;
      default: color = const Color(0xFF6B7280);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(level, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color)),
    );
  }
}

class CandidateAvatar extends StatelessWidget {
  final String name;
  final double size;
  const CandidateAvatar({super.key, required this.name, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final initials = name.split(' ').take(2).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: AppColors.accentEmerald.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(size / 3),
      ),
      alignment: Alignment.center,
      child: Text(initials, style: TextStyle(fontSize: size * 0.38, fontWeight: FontWeight.w600, color: AppColors.accentEmerald)),
    );
  }
}

class AppOutlinedButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? color;
  const AppOutlinedButton({super.key, required this.label, this.icon, this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon!, size: 16) : const SizedBox.shrink(),
      label: Text(label, style: TextStyle(fontSize: 13, color: color ?? AppColors.accentEmerald)),
      style: OutlinedButton.styleFrom(
        foregroundColor: color ?? AppColors.accentEmerald,
        side: BorderSide(color: (color ?? AppColors.accentEmerald).withValues(alpha: 0.4)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}

class AppPrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  const AppPrimaryButton({super.key, required this.label, this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon!, size: 18) : const SizedBox.shrink(),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentEmerald,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class LabeledDivider extends StatelessWidget {
  final String label;
  const LabeledDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(width: 12),
        const Expanded(child: Divider(color: AppColors.border, height: 1)),
      ],
    );
  }
}

class SectionChip extends StatelessWidget {
  final String label;
  const SectionChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accentEmerald.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: AppColors.accentEmerald, fontWeight: FontWeight.w500)),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? trailing;
  const InfoRow({super.key, required this.label, this.value, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted))),
          const SizedBox(width: 8),
          Expanded(child: trailing ?? Text(value ?? '—', style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }
}

String formatDate(String dateStr) {
  if (dateStr.isEmpty) return '—';
  try {
    final dt = DateTime.parse(dateStr);
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  } catch (_) {
    return dateStr;
  }
}

Widget buildError(BuildContext context, String message) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.errorBg,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: AppColors.error, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(message, style: const TextStyle(color: AppColors.error))),
      ],
    ),
  );
}

Widget buildEmpty(BuildContext context, String message) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.inbox_outlined, size: 48, color: AppColors.textMuted),
      const SizedBox(height: 12),
      Text(message, style: TextStyle(color: AppColors.textMuted)),
    ],
  );
}
