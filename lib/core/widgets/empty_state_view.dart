import 'package:flutter/material.dart';
import 'package:unorive/core/theme/colors.dart';
import 'package:unorive/core/theme/spacing.dart';
import 'package:unorive/core/widgets/app_button.dart';

/// A reusable empty/error state widget designed to display when listing is empty or loading failed.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    required this.title,
    required this.description,
    super.key,
    this.icon,
    this.actionText,
    this.onActionPressed,
  });

  final String title;
  final String description;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<UnoriveColors>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon illustration placeholder
            if (icon != null) ...[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Title
            Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),

            // Description
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: customColors?.textMuted ?? AppColors.darkTextMuted,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            // Optional Action CTA
            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton.primary(
                text: actionText!,
                onPressed: onActionPressed,
                width: 240,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
