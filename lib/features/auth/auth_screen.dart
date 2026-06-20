import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unorive/app/router.dart';

/// Screen providing social and guest auth paths.
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Icon(
                  Icons.lock_person_rounded,
                  size: 100,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 36),
              Text(
                'Let\'s get started',
                style: theme.textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to sync your saved places and trip history across devices.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              
              // Google Sign In (Mock)
              ElevatedButton.icon(
                onPressed: () => context.go(AppRouter.home),
                icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                label: const Text('Continue with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Apple Sign In (Mock)
              ElevatedButton.icon(
                onPressed: () => context.go(AppRouter.home),
                icon: const Icon(Icons.apple_rounded, size: 28),
                label: const Text('Continue with Apple'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Guest mode
              TextButton(
                onPressed: () => context.go(AppRouter.home),
                child: Text(
                  'Continue as Guest',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
