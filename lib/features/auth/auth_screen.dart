import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unorive/core/theme/colors.dart';
import 'package:unorive/core/theme/spacing.dart';
import 'package:unorive/core/widgets/app_button.dart';
import 'package:unorive/features/auth/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;
  bool _isGuestLoading = false;

  bool get _isLoading => _isGoogleLoading || _isAppleLoading || _isGuestLoading;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign in with Google: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isAppleLoading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithApple();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign in with Apple: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAppleLoading = false);
    }
  }

  Future<void> _handleGuestAccess() async {
    setState(() => _isGuestLoading = true);
    try {
      // First, try anonymous sign-in via auth repository
      await ref.read(authRepositoryProvider).signInAnonymously();
      // Set local guest mode setting to true
      await ref.read(guestModeControllerProvider.notifier).setGuestMode(active: true);
    } catch (e) {
      // If Firebase anonymous sign-in fails or is disabled, fallback to local guest mode only
      try {
        await ref.read(guestModeControllerProvider.notifier).setGuestMode(active: true);
      } catch (innerError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to initialize guest mode: $innerError')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isGuestLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<UnoriveColors>();

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
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_person_rounded,
                    size: 56,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                "Let's get started",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SpaceGrotesk',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Sign in to sync your saved places and trip history across devices.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),

              // Google Sign In
              AppButton.secondary(
                text: 'Continue with Google',
                isLoading: _isGoogleLoading,
                isEnabled: !_isLoading,
                icon: Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                  width: 20,
                  height: 20,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.g_mobiledata_rounded,
                    size: 24,
                  ),
                ),
                onPressed: _handleGoogleSignIn,
              ),
              const SizedBox(height: AppSpacing.md),

              // Apple Sign In
              AppButton.primary(
                text: 'Continue with Apple',
                isLoading: _isAppleLoading,
                isEnabled: !_isLoading,
                icon: const Icon(Icons.apple, size: 20),
                onPressed: _handleAppleSignIn,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Guest mode
              TextButton(
                onPressed: _isLoading ? null : _handleGuestAccess,
                child: _isGuestLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Continue as Guest',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
