import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:unorive/app/router.dart';
import 'package:unorive/core/theme/colors.dart';
import 'package:unorive/core/theme/spacing.dart';
import 'package:unorive/core/widgets/app_button.dart';
import 'package:unorive/core/widgets/glass_card.dart';
import 'package:unorive/features/auth/auth_provider.dart';
import 'package:unorive/features/settings/settings_provider.dart';

/// User settings and permissions management dashboard.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> with WidgetsBindingObserver {
  bool _notificationGranted = true;
  bool _locationAlwaysGranted = true;
  bool _batteryOptimizationIgnored = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    try {
      final notificationStatus = await Permission.notification.status;
      final locationAlwaysStatus = await Permission.locationAlways.status;

      bool batteryIgnored = true;
      if (!kIsWeb && Platform.isAndroid) {
        batteryIgnored = await Permission.ignoreBatteryOptimizations.isGranted;
      }

      if (mounted) {
        setState(() {
          _notificationGranted = notificationStatus.isGranted;
          _locationAlwaysGranted = locationAlwaysStatus.isGranted;
          _batteryOptimizationIgnored = batteryIgnored;
        });
      }
    } catch (_) {
      // Keep defaults in case of platform channel issues in testing
    }
  }

  void _showPolicyDialog(BuildContext context, String title, String content) {
    showDialog<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: const BorderSide(color: AppColors.borderDark),
          ),
          title: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.darkTextSecondary,
                height: 1.5,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(color: theme.primaryColor)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: const BorderSide(color: AppColors.error),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error),
              SizedBox(width: 8),
              Text('Delete Account?', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'This action is irreversible. All of your saved places, trip logs, '
            'and custom configurations will be deleted from our cloud servers and this device.',
            style: TextStyle(color: AppColors.darkTextSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete Permanently', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      try {
        final user = ref.read(authRepositoryProvider).currentUser;
        if (user != null && !user.isAnonymous && Firebase.apps.isNotEmpty) {
          final uid = user.uid;
          
          // 1. Delete saved places from Firestore
          final savedPlacesCol = FirebaseFirestore.instance.collection('users').doc(uid).collection('saved_places');
          final savedPlacesDocs = await savedPlacesCol.get();
          for (var doc in savedPlacesDocs.docs) {
            await doc.reference.delete();
          }

          // 2. Delete trip history from Firestore
          final tripHistoryCol = FirebaseFirestore.instance.collection('users').doc(uid).collection('trip_history');
          final tripHistoryDocs = await tripHistoryCol.get();
          for (var doc in tripHistoryDocs.docs) {
            await doc.reference.delete();
          }

          // 3. Delete user document from Firestore if exists
          await FirebaseFirestore.instance.collection('users').doc(uid).delete();

          // 4. Delete Auth user from Firebase
          await FirebaseAuth.instance.currentUser?.delete();
        }

        // 5. Clear local storage Hive boxes
        await ref.read(localStorageServiceProvider).clear();

        // 6. Sign out locally and redirect
        await ref.read(authRepositoryProvider).signOut();

        messenger.showSnackBar(
          const SnackBar(content: Text('Your account and data have been successfully deleted.')),
        );

        if (mounted) {
          context.go(AppRouter.auth);
        }
      } catch (e) {
        // Handles re-authentication expectation dynamically
        if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Security Check: Please sign out and sign in again to verify identity before deleting.'),
              backgroundColor: AppColors.error,
            ),
          );
        } else {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Error deleting data: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<UnoriveColors>();
    final settings = ref.watch(settingsProvider);
    final user = ref.watch(authStateProvider).value;

    final isImperial = settings.distanceUnit == 'mi';
    final radiusText = isImperial
        ? '${(settings.defaultAlertRadius * 3.28084).round()} ft'
        : '${settings.defaultAlertRadius.round()} m';

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Settings',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. PREFERENCES SECTION
              _buildSectionHeader('PREFERENCES'),
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      // Sound Picker
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Alarm Sound', style: TextStyle(fontWeight: FontWeight.bold)),
                          DropdownButton<String>(
                            value: settings.alarmSound,
                            dropdownColor: AppColors.darkSurface,
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                            underline: const SizedBox.shrink(),
                            items: const [
                              DropdownMenuItem(value: 'assets/sounds/alarm.wav', child: Text('Classic Alarm')),
                              DropdownMenuItem(value: 'assets/sounds/beep.wav', child: Text('Digital Beep')),
                              DropdownMenuItem(value: 'assets/sounds/chime.wav', child: Text('Gentle Chime')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                ref.read(settingsProvider.notifier).updateAlarmSound(val);
                              }
                            },
                          ),
                        ],
                      ),
                      const Divider(color: AppColors.borderDark, height: 24),

                      // Default Alert Radius Slider
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Default Alert Radius', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(radiusText, style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Slider(
                            value: settings.defaultAlertRadius,
                            min: 100.0,
                            max: 2000.0,
                            divisions: 19,
                            onChanged: (val) {
                              ref.read(settingsProvider.notifier).updateDefaultAlertRadius(val);
                            },
                          ),
                        ],
                      ),
                      const Divider(color: AppColors.borderDark, height: 24),

                      // Distance Unit Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Distance Unit', style: TextStyle(fontWeight: FontWeight.bold)),
                          ToggleButtons(
                            borderRadius: BorderRadius.circular(8),
                            borderColor: AppColors.borderDark,
                            selectedBorderColor: theme.primaryColor,
                            selectedColor: Colors.white,
                            fillColor: theme.primaryColor.withOpacity(0.2),
                            constraints: const BoxConstraints(minWidth: 60, minHeight: 32),
                            isSelected: [settings.distanceUnit == 'km', settings.distanceUnit == 'mi'],
                            onPressed: (index) {
                              ref.read(settingsProvider.notifier).updateDistanceUnit(index == 0 ? 'km' : 'mi');
                            },
                            children: const [
                              Text('km'),
                              Text('mi'),
                            ],
                          ),
                        ],
                      ),
                      const Divider(color: AppColors.borderDark, height: 24),

                      // Theme Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Theme Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                          DropdownButton<String>(
                            value: settings.themeMode,
                            dropdownColor: AppColors.darkSurface,
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                            underline: const SizedBox.shrink(),
                            items: const [
                              DropdownMenuItem(value: 'light', child: Text('Light')),
                              DropdownMenuItem(value: 'dark', child: Text('Dark')),
                              DropdownMenuItem(value: 'system', child: Text('System')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                ref.read(settingsProvider.notifier).updateThemeMode(val);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 2. PERMISSIONS & RELIABILITY
              _buildSectionHeader('PERMISSION & RELIABILITY'),
              if (!_notificationGranted || !_locationAlwaysGranted || (!kIsWeb && Platform.isAndroid && !_batteryOptimizationIgnored)) ...[
                // Fix-it card
                GlassCard(
                  borderColor: AppColors.error.withOpacity(0.3),
                  backgroundColor: AppColors.error.withOpacity(0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: AppColors.error),
                            SizedBox(width: 8),
                            Text(
                              'Action Required for Reliability',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Some permissions are missing. To guarantee background geofence alarms work, '
                          'please allow Location Always, Notification access, and disable Battery Optimization.',
                          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.darkTextSecondary),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppButton.primary(
                          text: 'Open System Settings',
                          height: 48,
                          onPressed: () async {
                            await openAppSettings();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Current permissions status card list
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      _buildPermissionStatusRow('Notification Permission', _notificationGranted),
                      const Divider(color: AppColors.borderDark, height: 16),
                      _buildPermissionStatusRow('Always-On Location', _locationAlwaysGranted),
                      if (!kIsWeb && Platform.isAndroid) ...[
                        const Divider(color: AppColors.borderDark, height: 16),
                        _buildPermissionStatusRow('Unrestricted Battery Mode', _batteryOptimizationIgnored),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 3. ACCOUNT SECTION
              _buildSectionHeader('ACCOUNT'),
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Account ID / Email', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            user == null
                                ? 'Offline Guest'
                                : (user.isAnonymous ? 'Anonymous' : (user.email ?? 'Authenticated')),
                            style: TextStyle(color: customColors?.textMuted ?? AppColors.darkTextMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (user != null) ...[
                        AppButton.secondary(
                          text: 'Sign Out',
                          height: 48,
                          onPressed: () async {
                            await ref.read(authRepositoryProvider).signOut();
                            if (context.mounted) {
                              context.go(AppRouter.auth);
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextButton(
                          onPressed: () => _handleDeleteAccount(context),
                          child: const Text(
                            'Delete Account & Cloud Data',
                            style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ] else ...[
                        AppButton.primary(
                          text: 'Sign In / Sign Up',
                          height: 48,
                          onPressed: () => context.push(AppRouter.auth),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 4. ABOUT SECTION
              _buildSectionHeader('ABOUT UNORIVE'),
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Version', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('0.1.0+1', style: TextStyle(color: AppColors.darkTextSecondary)),
                        ],
                      ),
                      const Divider(color: AppColors.borderDark, height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Privacy Policy', style: TextStyle(fontSize: 14)),
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.darkTextSecondary),
                        onTap: () => _showPolicyDialog(
                          context,
                          'Privacy Policy',
                          'Unorive respects your privacy. To provide location-based alarms, '
                          'we collect location data in the background even when the app is closed. '
                          'This data is used purely on-device for geofencing, and is synchronized '
                          'to Firestore only when you are signed in. We do not sell or share '
                          'your location data with any third parties.',
                        ),
                      ),
                      const Divider(color: AppColors.borderDark, height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Terms of Use', style: TextStyle(fontSize: 14)),
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.darkTextSecondary),
                        onTap: () => _showPolicyDialog(
                          context,
                          'Terms of Use',
                          'Welcome to Unorive. By using our application, you agree to allow us '
                          'to access location updates in the background. Location-based geofences '
                          'are subject to GPS accuracy. Unorive is an alert assistant; '
                          'please remain alert and do not solely rely on the application for '
                          'critical commute safety.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 5. DEVELOPER PORTAL
              if (kDebugMode) ...[
                _buildSectionHeader('DEVELOPER TOOLS'),
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppButton.secondary(
                          text: 'Design Catalogue Screen',
                          height: 48,
                          onPressed: () => context.push(AppRouter.designCatalogue),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppButton.secondary(
                          text: 'Background Reliability Debug',
                          height: 48,
                          onPressed: () => context.push(AppRouter.backgroundReliability),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: AppColors.darkTextSecondary,
        ),
      ),
    );
  }

  Widget _buildPermissionStatusRow(String label, bool isGranted) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Row(
          children: [
            Text(
              isGranted ? 'GRANTED' : 'MISSING',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isGranted ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isGranted ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: isGranted ? AppColors.success : AppColors.error,
              size: 18,
            ),
          ],
        ),
      ],
    );
  }
}
