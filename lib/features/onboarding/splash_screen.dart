import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:unorive/app/router.dart';

/// A splash screen that shows the app brand and routes to onboarding.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.go(AppRouter.onboarding);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Name with Display font
            Text(
              'UNORIVE',
              style: theme.textTheme.displayLarge?.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            )
                .animate()
                .fadeIn(duration: 800.ms, curve: Curves.easeOutQuad)
                .scale(
                  begin: const Offset(0.85, 0.85),
                  end: const Offset(1, 1),
                  duration: 800.ms,
                  curve: Curves.easeOutBack,
                ),
            const SizedBox(height: 8),
            // Tagline
            Text(
              'You know when to arrive.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                letterSpacing: 0.5,
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms, curve: Curves.easeOutQuad)
                .slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 600.ms,
                  curve: Curves.easeOutQuad,
                ),
          ],
        ),
      ),
    );
  }
}
