import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unorive/core/theme/colors.dart';
import 'package:unorive/core/theme/spacing.dart';
import 'package:unorive/core/widgets/app_button.dart';
import 'package:unorive/features/trip_tracking/trip_provider.dart';

class BackgroundReliabilityScreen extends ConsumerStatefulWidget {
  const BackgroundReliabilityScreen({super.key});

  @override
  ConsumerState<BackgroundReliabilityScreen> createState() => _BackgroundReliabilityScreenState();
}

class _BackgroundReliabilityScreenState extends ConsumerState<BackgroundReliabilityScreen> {
  bool _isServiceRunning = false;
  Timer? _statusTimer;
  double _simulatedDistance = 1500.0; // Starts at 1.5km

  @override
  void initState() {
    super.initState();
    _checkServiceStatus();
    // Poll service status every second to keep UI synced
    _statusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkServiceStatus();
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkServiceStatus() async {
    final running = await FlutterBackgroundService().isRunning();
    if (mounted && running != _isServiceRunning) {
      setState(() {
        _isServiceRunning = running;
      });
    }
  }

  void _simulateLocationUpdate() {
    final tripState = ref.read(tripControllerProvider);
    if (tripState.status != TripStatus.active || tripState.destination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please start a trip first before simulating updates!')),
      );
      return;
    }

    final dest = tripState.destination!;
    // Subtract 300 meters on each simulate press
    setState(() {
      _simulatedDistance = (_simulatedDistance - 300.0).clamp(0.0, 10000.0);
    });

    final double latOffset = (_simulatedDistance / 111000.0); // Rough approximation of meters to lat

    // Broadcast update simulation
    FlutterBackgroundService().invoke('update', {
      'latitude': dest.latitude + latOffset,
      'longitude': dest.longitude,
      'remainingDistance': _simulatedDistance,
      'etaMinutes': (_simulatedDistance / 11.0 / 60).round(),
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Check geofence
    if (_simulatedDistance <= tripState.targetRadius) {
      ref.read(tripControllerProvider.notifier).arrive();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Simulated entry into geofence! Target: ${tripState.targetRadius}m'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _resetSimulation() {
    setState(() {
      _simulatedDistance = 2500.0; // Reset to 2.5km
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Simulation distance reset to 2.5 km.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<UnoriveColors>();
    final tripState = ref.watch(tripControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Background Reliability Debug'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: customColors?.glassSurface ?? AppColors.darkSurfaceGlass,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                side: BorderSide(
                  color: _isServiceRunning ? AppColors.success : theme.colorScheme.error,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Icon(
                      _isServiceRunning
                          ? Icons.check_circle_outline_rounded
                          : Icons.error_outline_rounded,
                      size: 48,
                      color: _isServiceRunning ? AppColors.success : theme.colorScheme.error,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Background Service Status',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isServiceRunning ? 'RUNNING (Foreground Lock Active)' : 'STOPPED',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: _isServiceRunning ? AppColors.success : theme.colorScheme.error,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Live State Monitor
            Text(
              'ACTIVE STATE',
              style: theme.textTheme.labelMedium?.copyWith(
                color: customColors?.textMuted ?? AppColors.darkTextMuted,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              color: customColors?.glassSurface ?? AppColors.darkSurfaceGlass,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                side: BorderSide(color: customColors?.border ?? AppColors.borderDark),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    _buildStateRow('Trip Status', tripState.status.name.toUpperCase()),
                    _buildStateRow(
                      'Target Name',
                      tripState.destination?.name ?? 'None',
                    ),
                    _buildStateRow(
                      'Target Lat/Lng',
                      tripState.destination != null
                          ? '${tripState.destination!.latitude.toStringAsFixed(4)}, ${tripState.destination!.longitude.toStringAsFixed(4)}'
                          : 'N/A',
                    ),
                    _buildStateRow(
                      'Remaining Distance',
                      tripState.remainingDistance != null
                          ? '${tripState.remainingDistance!.toStringAsFixed(1)} m'
                          : 'N/A',
                    ),
                    _buildStateRow(
                      'Warning Radius',
                      '${tripState.targetRadius.round()} m',
                    ),
                    _buildStateRow(
                      'ETA Approximation',
                      tripState.etaMinutes != null ? '${tripState.etaMinutes} mins' : 'N/A',
                    ),
                    _buildStateRow(
                      'Last Isolate Ping',
                      tripState.lastLocationUpdate != null
                          ? tripState.lastLocationUpdate!.toLocal().toIso8601String().substring(11, 19)
                          : 'N/A',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Simulation Controls
            Text(
              'SIMULATION UTILITIES',
              style: theme.textTheme.labelMedium?.copyWith(
                color: customColors?.textMuted ?? AppColors.darkTextMuted,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Use these controls to simulate coordinates ticks step-by-step for radius entry tests.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: customColors?.textMuted ?? AppColors.darkTextMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton.primary(
              text: 'Simulate Step update (-300m)',
              icon: const Icon(Icons.navigation_rounded),
              onPressed: _simulateLocationUpdate,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton.secondary(
              text: 'Reset Simulated Dist (2.5 km)',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _resetSimulation,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildStateRow(String label, String value) {
    final theme = Theme.of(context);
    final customColors = theme.extension<UnoriveColors>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: customColors?.textMuted ?? AppColors.darkTextMuted,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
