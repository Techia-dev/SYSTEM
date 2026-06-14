import 'package:flutter/material.dart';
import 'package:techia_ats/core/theme/app_colors.dart';
import 'package:techia_ats/core/theme/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;

  const StatusBadge({
    super.key,
    required this.label,
    this.color,
    this.textColor,
  });

  Color get _bgColor {
    if (color != null) return color!;
    switch (label.toLowerCase()) {
      case 'applied':
        return AppColors.bgSecondary;
      case 'accepted':
        return AppColors.accentEmerald.withValues(alpha: 0.1);
      case 'rejected':
        return AppColors.statusRejected.withValues(alpha: 0.1);
      case 'paid':
        return AppColors.accentEmerald.withValues(alpha: 0.1);
      case 'pending':
        return AppColors.statusPending.withValues(alpha: 0.1);
      case 'active':
        return AppColors.accentEmerald.withValues(alpha: 0.1);
      default:
        return AppColors.bgSecondary;
    }
  }

  Color get _textColor {
    if (textColor != null) return textColor!;
    switch (label.toLowerCase()) {
      case 'applied':
        return AppColors.textSecondary;
      case 'accepted':
        return AppColors.accentEmerald;
      case 'rejected':
        return AppColors.statusRejected;
      case 'paid':
        return AppColors.accentEmerald;
      case 'pending':
        return AppColors.statusPending;
      case 'active':
        return AppColors.accentEmerald;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label[0].toUpperCase() + label.substring(1),
        style: AppTextStyles.bodySmall.copyWith(
          color: _textColor,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),
    );
  }
}

class CandidateAvatar extends StatelessWidget {
  final String name;
  final double size;

  const CandidateAvatar({
    super.key,
    required this.name,
    this.size = 40,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: size * 0.35,
          fontWeight: FontWeight.w700,
          fontFamily: AppTextStyles.fontFamily,
        ),
      ),
    );
  }
}

class AppOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;

  const AppOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textSecondary,
                ),
              )
            : Text(label),
      ),
    );
  }
}

class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final IconData? icon;

  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16),
                    const SizedBox(width: 6),
                  ],
                  Text(label),
                ],
              ),
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
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label, style: AppTextStyles.bodySmall),
        ),
        const Expanded(child: Divider()),
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
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.labelMedium),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.titleSmall),
      ],
    );
  }
}
