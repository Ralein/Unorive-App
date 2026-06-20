import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unorive/app/router.dart';
import 'package:unorive/core/theme/colors.dart';
import 'package:unorive/core/theme/spacing.dart';
import 'package:unorive/core/widgets/glass_card.dart';

/// A dashboard display showing final statistics for a completed trip.
class TripSummaryScreen extends StatelessWidget {
  const TripSummaryScreen({
    required this.destinationName,
    required this.durationMinutes,
    super.key,
  });

  final String destinationName;
  final int durationMinutes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          // Background decorative gradient glow
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.darkPrimary.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.darkSecondary.withOpacity(0.12),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppPadding.lg,
                vertical: AppPadding.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  // Arrived Icon & Animation representation
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 72,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppGap.xl),
                  Center(
                    child: Text(
                      'Trip Completed!',
                      style: textTheme.headlineLarge?.copyWith(
                        color: AppColors.darkTextPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppGap.sm),
                  Center(
                    child: Text(
                      'You have safely arrived at your destination.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.darkTextSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Spacer(),
                  // Trip Summary details in a GlassCard
                  GlassCard(
                    padding: const EdgeInsets.all(AppPadding.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TRIP DETAILS',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.darkSecondary,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppGap.md),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: AppColors.darkTextSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: AppGap.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    destinationName,
                                    style: textTheme.titleMedium?.copyWith(
                                      color: AppColors.darkTextPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Destination',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: AppColors.darkTextMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(
                          color: AppColors.borderDark,
                          height: 32,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              color: AppColors.darkTextSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: AppGap.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$durationMinutes mins',
                                    style: textTheme.titleMedium?.copyWith(
                                      color: AppColors.darkTextPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Duration',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: AppColors.darkTextMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Action Button back to home
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => context.go(AppRouter.home),
                      child: Text(
                        'Back to Home Map',
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
