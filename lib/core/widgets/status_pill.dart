import 'package:flutter/material.dart';
import 'package:unorive/core/theme/colors.dart';
import 'package:unorive/core/theme/spacing.dart';

/// Semantic types of status tags in Unorive.
enum StatusType {
  /// Active trip, running service
  active,

  /// Arrived at destination
  arrived,

  /// Warning states
  warning,

  /// Error/Cancelled states
  error,

  /// Neutral, offline, or completed states
  neutral,
}

/// A compact, styled pill badge indicating status.
class StatusPill extends StatelessWidget {
  const StatusPill({
    required this.label,
    required this.type,
    super.key,
  });

  final String label;
  final StatusType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color color;
    switch (type) {
      case StatusType.active:
        color = theme.colorScheme.secondary;
      case StatusType.arrived:
        color = AppColors.success;
      case StatusType.warning:
        color = AppColors.warning;
      case StatusType.error:
        color = AppColors.error;
      case StatusType.neutral:
        color = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.circular),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
