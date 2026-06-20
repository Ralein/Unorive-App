import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unorive/data/models/user_profile.dart';
import 'package:unorive/features/auth/auth_provider.dart';
import 'package:unorive/features/auth/auth_screen.dart';
import 'package:unorive/features/home_map/home_screen.dart';
import 'package:unorive/features/onboarding/onboarding_screen.dart';
import 'package:unorive/features/onboarding/splash_screen.dart';
import 'package:unorive/features/settings/background_reliability_screen.dart';
import 'package:unorive/features/settings/design_catalogue_screen.dart';
import 'package:unorive/features/alarm_screen/alarm_screen_placeholder.dart';
import 'package:unorive/features/trip_tracking/trip_provider.dart';
import 'package:unorive/features/trip_tracking/trip_summary_screen.dart';

part 'router.g.dart';

/// App route path constants.
class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String designCatalogue = '/design-catalogue';
  static const String backgroundReliability = '/background-reliability';
  static const String alarm = '/alarm';
  static const String tripSummary = '/trip-summary';

  /// Root navigator key for global context operations.
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
}

/// A custom [ChangeNotifier] that listens to multiple Riverpod providers and
/// triggers GoRouter redirects whenever they change.
class RouterRefreshListenable extends ChangeNotifier {
  RouterRefreshListenable(Ref ref) {
    // Listen to changes in auth state, guest mode, and onboarding completion
    ref.listen<AsyncValue<UserProfile?>>(
      authStateProvider,
      (_, __) => notifyListeners(),
    );
    ref.listen<bool>(
      onboardingControllerProvider,
      (_, __) => notifyListeners(),
    );
    ref.listen<bool>(
      guestModeControllerProvider,
      (_, __) => notifyListeners(),
    );
    ref.listen<TripState>(
      tripControllerProvider,
      (_, __) => notifyListeners(),
    );
  }
}

/// Provides the reactive [GoRouter] instance.
@riverpod
GoRouter router(Ref ref) {
  final refreshListenable = RouterRefreshListenable(ref);

  return GoRouter(
    navigatorKey: AppRouter.rootNavigatorKey,
    initialLocation: AppRouter.splash,
    refreshListenable: refreshListenable,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final matchedLocation = state.matchedLocation;

      final isGoingToSplash = matchedLocation == AppRouter.splash;
      final isGoingToOnboarding = matchedLocation == AppRouter.onboarding;
      final isGoingToAuth = matchedLocation == AppRouter.auth;
      final isGoingToHome = matchedLocation == AppRouter.home;
      final isGoingToDesign = matchedLocation == AppRouter.designCatalogue;
      final isGoingToReliability = matchedLocation == AppRouter.backgroundReliability;
      final isGoingToAlarm = matchedLocation == AppRouter.alarm;
      final isGoingToSummary = matchedLocation == AppRouter.tripSummary;

      // Allow debugging routes to pass through unconditionally
      if (isGoingToDesign || isGoingToReliability) return null;

      // Never redirect while on the splash screen to allow the intro animation to play
      if (isGoingToSplash) return null;

      final hasCompletedOnboarding = ref.read(onboardingControllerProvider);
      final isAuthenticated = ref.read(authStateProvider).value != null;
      final isGuestMode = ref.read(guestModeControllerProvider);

      // Guard: Onboarding complete check
      if (!hasCompletedOnboarding) {
        if (!isGoingToOnboarding) {
          return AppRouter.onboarding;
        }
        return null;
      }

      // Guard: Authenticated check (or guest mode check)
      if (!isAuthenticated && !isGuestMode) {
        if (!isGoingToAuth) {
          return AppRouter.auth;
        }
        return null;
      }

      final isArrived = ref.read(tripControllerProvider).status == TripStatus.arrived;

      // Guard: Arrived check (force alarm screen)
      if (isArrived) {
        if (!isGoingToAlarm) {
          return AppRouter.alarm;
        }
        return null;
      }

      // Guard: Not arrived check (prevent access to alarm screen, redirect completed trip to summary, active trip to home)
      if (isGoingToAlarm) {
        final tripState = ref.read(tripControllerProvider);
        if (tripState.status == TripStatus.idle) {
          final dest = tripState.destination;
          if (dest != null) {
            final duration = tripState.startTime != null
                ? DateTime.now().difference(tripState.startTime!).inMinutes
                : 0;
            return '${AppRouter.tripSummary}?name=${Uri.encodeComponent(dest.name)}&duration=$duration';
          }
        }
        return AppRouter.home;
      }

      // If user is authenticated or in guest mode, prevent visiting onboarding or auth screens
      if (isGoingToOnboarding || isGoingToAuth) {
        return AppRouter.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRouter.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRouter.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRouter.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRouter.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRouter.designCatalogue,
        builder: (context, state) => const DesignCatalogueScreen(),
      ),
      GoRoute(
        path: AppRouter.backgroundReliability,
        builder: (context, state) => const BackgroundReliabilityScreen(),
      ),
      GoRoute(
        path: AppRouter.alarm,
        builder: (context, state) => const AlarmScreenPlaceholder(),
      ),
      GoRoute(
        path: AppRouter.tripSummary,
        builder: (context, state) {
          final name = state.uri.queryParameters['name'] ?? 'Destination';
          final durationStr = state.uri.queryParameters['duration'] ?? '0';
          final duration = int.tryParse(durationStr) ?? 0;
          return TripSummaryScreen(
            destinationName: name,
            durationMinutes: duration,
          );
        },
      ),
    ],
  );
}
