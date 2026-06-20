import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unorive/core/theme/colors.dart';
import 'package:unorive/core/theme/spacing.dart';
import 'package:unorive/core/widgets/app_button.dart';
import 'package:unorive/core/widgets/bottom_sheet_scaffold.dart';
import 'package:unorive/core/widgets/status_pill.dart';
import 'package:unorive/features/trip_tracking/trip_provider.dart';

/// Draggable tracking dashboard showing progress to active destination.
class TripTrackingSheet extends ConsumerWidget {
  const TripTrackingSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final customColors = theme.extension<UnoriveColors>();
    final tripState = ref.watch(tripControllerProvider);

    if (tripState.status != TripStatus.active || tripState.destination == null) {
      return const SizedBox.shrink();
    }

    final dest = tripState.destination!;
    final remainingDist = tripState.remainingDistance;
    final eta = tripState.etaMinutes;

    // Formatting distance string
    String distanceStr = 'Calculating...';
    if (remainingDist != null) {
      distanceStr = remainingDist >= 1000
          ? '${(remainingDist / 1000).toStringAsFixed(1)} km'
          : '${remainingDist.round()} m';
    }

    // Formatting ETA string
    final String etaStr = eta != null ? '$eta mins' : 'Calculating...';

    // Estimate progress bar percentage (dynamic from 1.0 down to 0.0, cap at 100%)
    // Since we don't save initial distance, let's show a beautiful pulsing progress bar,
    // or calculate progress relative to a 5km starting radius.
    double progress = 0.5; // Default centered progress
    if (remainingDist != null) {
      final double geofenceRadius = tripState.targetRadius;
      if (remainingDist <= geofenceRadius) {
        progress = 1.0;
      } else {
        // Assume maximum trip distance tracking start at 5km for visual representation
        final double maxExpectedDist = geofenceRadius + 5000.0;
        final double clampedDist = remainingDist.clamp(geofenceRadius, maxExpectedDist);
        progress = 1.0 - ((clampedDist - geofenceRadius) / 5000.0);
      }
    }

    return BottomSheetScaffold(
      initialChildSize: 0.38,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          children: [
            Row(
              children: [
                const StatusPill(
                  label: 'ACTIVE TRIP',
                  type: StatusType.active,
                ),
                const Spacer(),
                if (tripState.lastLocationUpdate != null)
                  Text(
                    'Updated: ${tripState.lastLocationUpdate!.toLocal().toIso8601String().substring(11, 19)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: customColors?.textMuted ?? AppColors.darkTextMuted,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Big Destination and Distance
            Text(
              dest.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'SpaceGrotesk',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              dest.address,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Metrics Display (Distance + ETA)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DISTANCE LEFT',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: customColors?.textMuted ?? AppColors.darkTextMuted,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        distanceStr,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                          fontFamily: 'SpaceGrotesk',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: customColors?.border ?? AppColors.borderDark,
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'APPROX. ETA',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: customColors?.textMuted ?? AppColors.darkTextMuted,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        etaStr,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.secondary,
                          fontFamily: 'SpaceGrotesk',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: (customColors?.border ?? AppColors.borderDark).withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Alert Radius: ${tripState.targetRadius.round()}m',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: customColors?.textMuted ?? AppColors.darkTextMuted,
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}% Completed',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Actions
            AppButton.secondary(
              text: 'Cancel Trip',
              icon: Icon(
                Icons.cancel_outlined,
                color: theme.colorScheme.error,
              ),
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                await ref.read(tripControllerProvider.notifier).cancelTrip();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Trip cancelled.')),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        );
      },
    );
  }
}
