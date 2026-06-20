import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unorive/core/theme/colors.dart';
import 'package:unorive/core/theme/spacing.dart';
import 'package:unorive/core/widgets/app_button.dart';
import 'package:unorive/core/widgets/glass_card.dart';
import 'package:unorive/features/trip_tracking/trip_provider.dart';

/// Full-screen premium alarm overlay shown when a user arrives at their destination.
class AlarmScreenPlaceholder extends ConsumerStatefulWidget {
  const AlarmScreenPlaceholder({super.key});

  @override
  ConsumerState<AlarmScreenPlaceholder> createState() => _AlarmScreenPlaceholderState();
}

class _AlarmScreenPlaceholderState extends ConsumerState<AlarmScreenPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool _isRunningInTests() {
    if (kIsWeb) return false;
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    final isTesting = _isRunningInTests();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    if (!isTesting) {
      _pulseController.repeat();
      _pulseController.addStatusListener((status) {
        if (status == AnimationStatus.forward) {
          HapticFeedback.heavyImpact().catchError((_) {});
        }
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<UnoriveColors>();
    final tripState = ref.watch(tripControllerProvider);

    final duration = tripState.startTime != null
        ? DateTime.now().difference(tripState.startTime!).inMinutes
        : 0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background ambient red glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.error.withOpacity(0.3),
                    Colors.black,
                  ],
                  radius: 1.2,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  const Spacer(),

                  // Pulsing halos & center icon
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer Pulsing Halo
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                width: 120 * _scaleAnimation.value,
                                height: 120 * _scaleAnimation.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.error.withOpacity(_opacityAnimation.value * 0.4),
                                  border: Border.all(
                                    color: AppColors.error.withOpacity(_opacityAnimation.value),
                                    width: 2,
                                  ),
                                ),
                              );
                            },
                          ),

                          // Inner Pulsing Halo (offset by 50% cycle)
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              final offsetValue = (_pulseController.value + 0.5) % 1.0;
                              final scale = 1.0 + (0.5 * offsetValue);
                              final opacity = 0.6 * (1.0 - offsetValue);
                              return Container(
                                width: 120 * scale,
                                height: 120 * scale,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.error.withOpacity(opacity * 0.3),
                                  border: Border.all(
                                    color: AppColors.error.withOpacity(opacity),
                                    width: 1.5,
                                  ),
                                ),
                              );
                            },
                          ),

                          // Center Alarm Ring Button representation
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.error,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.error.withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.alarm_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Header title
                  Text(
                    'YOU HAVE ARRIVED',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Destination Details card
                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          tripState.destination?.name ?? 'Target Destination',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppColors.darkTextPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (tripState.destination?.address != null &&
                            tripState.destination!.address.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            tripState.destination!.address,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: customColors?.textMuted ?? AppColors.darkTextMuted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const Divider(
                          color: AppColors.borderDark,
                          height: 24,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              color: AppColors.darkTextSecondary,
                              size: 18,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Travel Time: $duration mins',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.darkTextSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Actions
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppButton.primary(
                        key: const ValueKey('dismiss_alarm_button'),
                        text: 'Dismiss Alarm',
                        icon: const Icon(Icons.alarm_off_rounded),
                        onPressed: () async {
                          await ref.read(tripControllerProvider.notifier).dismissAlarm();
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppButton.secondary(
                        key: const ValueKey('snooze_alarm_button'),
                        text: 'Snooze (5m)',
                        icon: const Icon(Icons.snooze_rounded),
                        onPressed: () async {
                          await ref.read(tripControllerProvider.notifier).snooze(minutes: 5);
                        },
                      ),
                    ],
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
