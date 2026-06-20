import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:unorive/core/theme/colors.dart';
import 'package:unorive/core/theme/spacing.dart';
import 'package:unorive/core/widgets/app_button.dart';

/// Types of permissions that require priming.
enum PermissionPrimingType {
  location,
  notification,
}

/// A premium, plain-language explanation screen displayed prior to requesting
/// native OS permissions. Necessary for user experience and store compliance.
class PermissionPrimingScreen extends StatefulWidget {
  const PermissionPrimingScreen({
    required this.type,
    required this.onDone,
    super.key,
  });

  final PermissionPrimingType type;
  final VoidCallback onDone;

  @override
  State<PermissionPrimingScreen> createState() => _PermissionPrimingScreenState();
}

class _PermissionPrimingScreenState extends State<PermissionPrimingScreen> {
  bool _isRequesting = false;

  Future<void> _requestPermission() async {
    setState(() {
      _isRequesting = true;
    });

    try {
      if (widget.type == PermissionPrimingType.location) {
        // Request Location When In Use first (as standard practice before Always)
        final status = await Permission.location.request();
        if (status.isGranted) {
          // Request always/background location if needed (we'll request it later, or request it now)
          await Permission.locationAlways.request();
        }
      } else {
        await Permission.notification.request();
      }
    } catch (_) {
      // Gracefully handle errors or exceptions in platform channels
    } finally {
      if (mounted) {
        setState(() {
          _isRequesting = false;
        });
        widget.onDone();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<UnoriveColors>();

    final bool isLocation = widget.type == PermissionPrimingType.location;
    final String title = isLocation ? 'Access Location' : 'Get Alerts';
    final String description = isLocation
        ? 'Unorive uses your location in the background (even when the app is closed or not in use) to calculate remaining distance and trigger your alarm exactly when you enter your target radius.'
        : 'Allow notifications so Unorive can wake you up and send critical arrival alerts even when your phone is locked or the app is minimized.';

    final IconData icon = isLocation ? Icons.location_on_rounded : Icons.notifications_active_rounded;
    final Color iconColor = isLocation
        ? (customColors?.arrivalAccent ?? AppColors.darkAccent)
        : theme.colorScheme.secondary;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 64,
                    color: iconColor,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SpaceGrotesk',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              AppButton.primary(
                text: isLocation ? 'Allow Location Access' : 'Enable Notifications',
                isLoading: _isRequesting,
                onPressed: _requestPermission,
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton.secondary(
                text: 'Not Now',
                isEnabled: !_isRequesting,
                onPressed: widget.onDone,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
