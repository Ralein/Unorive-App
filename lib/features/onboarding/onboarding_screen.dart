import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unorive/app/router.dart';
import 'package:unorive/core/theme/colors.dart';
import 'package:unorive/core/theme/spacing.dart';
import 'package:unorive/core/widgets/app_button.dart';
import 'package:unorive/features/auth/auth_provider.dart';
import 'package:unorive/features/onboarding/permission_priming_screen.dart';

/// Step indicators for Onboarding + Priming flow.
enum OnboardingStep {
  walkthrough,
  locationPriming,
  notificationPriming,
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  OnboardingStep _currentStep = OnboardingStep.walkthrough;
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPageIndex < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToStep(OnboardingStep.locationPriming);
    }
  }

  void _goToStep(OnboardingStep step) {
    setState(() {
      _currentStep = step;
    });
  }

  Future<void> _completeFlow() async {
    // Save onboarding completion state in Hive
    await ref.read(onboardingControllerProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go(AppRouter.auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentStep) {
      case OnboardingStep.walkthrough:
        return _buildWalkthrough(context);
      case OnboardingStep.locationPriming:
        return PermissionPrimingScreen(
          type: PermissionPrimingType.location,
          onDone: () => _goToStep(OnboardingStep.notificationPriming),
        );
      case OnboardingStep.notificationPriming:
        return PermissionPrimingScreen(
          type: PermissionPrimingType.notification,
          onDone: _completeFlow,
        );
    }
  }

  Widget _buildWalkthrough(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<UnoriveColors>();

    final pages = [
      _OnboardingPageData(
        title: 'Search Destination',
        description: 'Set your arrival point by searching a destination or dropping a pin on our 3D interactive map.',
        icon: Icons.map_rounded,
        iconColor: theme.colorScheme.primary,
      ),
      _OnboardingPageData(
        title: 'Define Radius',
        description: 'Choose your alert radius. Whether it is 500 meters or 5 kilometers, we keep you in control.',
        icon: Icons.track_changes_rounded,
        iconColor: theme.colorScheme.secondary,
      ),
      _OnboardingPageData(
        title: 'Arrive Awake',
        description: 'Sleep, read, or listen to music. Unorive wakes you up before you reach your destination.',
        icon: Icons.alarm_on_rounded,
        iconColor: customColors?.arrivalAccent ?? AppColors.darkAccent,
      ),
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top action bar (Skip button)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _goToStep(OnboardingStep.locationPriming),
                  child: Text(
                    'Skip',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            ),

            // PageView content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPageIndex = index;
                  });
                },
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: page.iconColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page.icon,
                            size: 72,
                            color: page.iconColor,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          page.title,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'SpaceGrotesk',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          page.description,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dot indicators & CTA button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                children: [
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPageIndex == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPageIndex == index
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppRadius.circular),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Next / Get Started button
                  AppButton.primary(
                    text: _currentPageIndex == 2 ? 'Get Started' : 'Next',
                    onPressed: _nextPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  _OnboardingPageData({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
}
