import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unorive/core/theme/colors.dart';
import 'package:unorive/core/theme/spacing.dart';
import 'package:unorive/core/widgets/app_button.dart';
import 'package:unorive/core/widgets/glass_card.dart';
import 'package:unorive/features/trip_tracking/trip_provider.dart';

class AlarmScreenPlaceholder extends ConsumerWidget {
  const AlarmScreenPlaceholder({super.key});

  bool _isRunningInTests() {
    if (kIsWeb) return false;
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final customColors = theme.extension<UnoriveColors>();
    final tripState = ref.watch(tripControllerProvider);
    final isTesting = _isRunningInTests();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Pulsing Ambient Red Glow Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.error.withOpacity(0.4),
                    Colors.black,
                  ],
                  radius: 1.2,
                ),
              ),
            )
                .animate(
                  onPlay: isTesting
                      ? null
                      : (controller) => controller.repeat(reverse: true),
                )
                .scaleXY(
                  begin: 0.9,
                  end: 1.1,
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInOut,
                )
                .fadeIn(duration: const Duration(seconds: 2)),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),

                  // Icon & Pulse
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.error.withOpacity(0.2),
                        border: Border.all(color: AppColors.error, width: 2),
                      ),
                      child: const Icon(
                        Icons.alarm_rounded,
                        color: AppColors.error,
                        size: 64,
                      ),
                    )
                        .animate(
                          onPlay: isTesting
                              ? null
                              : (controller) => controller.repeat(),
                        )
                        .scaleXY(
                          begin: 0.95,
                          end: 1.1,
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.elasticOut,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Header
                  Text(
                    'YOU HAVE ARRIVED',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().shake(hz: 4, duration: const Duration(milliseconds: 800)),

                  const SizedBox(height: AppSpacing.md),

                  // Message
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: [
                          Text(
                            tripState.destination?.name ?? 'Target Geofence',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (tripState.destination?.address != null &&
                              tripState.destination!.address.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              tripState.destination!.address,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: customColors?.textMuted ?? AppColors.darkTextMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Actions
                  AppButton.primary(
                    key: const ValueKey('dismiss_alarm_button'),
                    text: 'Dismiss Alarm',
                    icon: const Icon(Icons.alarm_off_rounded),
                    onPressed: () async {
                      await ref.read(tripControllerProvider.notifier).dismissAlarm();
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
