import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unorive/features/auth/auth_screen.dart';
import 'package:unorive/features/home_map/home_screen.dart';
import 'package:unorive/features/onboarding/onboarding_screen.dart';
import 'package:unorive/features/onboarding/splash_screen.dart';
import 'package:unorive/features/settings/design_catalogue_screen.dart';

/// Unorive Route configuration defining navigation flows.
class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String designCatalogue = '/design-catalogue';

  /// Root navigator key for global context operations.
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  /// Configured [GoRouter] instance.
  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: auth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: designCatalogue,
        builder: (context, state) => const DesignCatalogueScreen(),
      ),
    ],
  );
}
