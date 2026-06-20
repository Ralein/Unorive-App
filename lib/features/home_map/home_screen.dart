import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unorive/app/router.dart';
import 'package:unorive/core/theme/colors.dart';

/// The main dashboard screen housing the interactive map and search controls.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<UnoriveColors>();

    return Scaffold(
      body: Stack(
        children: [
          // Simulated 3D Map Background
          Positioned.fill(
            child: ColoredBox(
              color: AppColors.darkBackground,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.explore_rounded,
                      size: 80,
                      color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '3D Map Canvas Placeholder',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                    Text(
                      '(Mapbox integration to load in Phase 3)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Glassmorphic Search Bar Card (Top)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: customColors?.glassSurface ?? AppColors.darkSurfaceGlass,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: customColors?.border ?? AppColors.borderDark,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Where are you arriving to?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.mic_rounded,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Action Buttons (Map zoom, controls, settings)
          Positioned(
            bottom: 32,
            right: 16,
            child: Column(
              children: [
                _FloatingMapButton(
                  icon: Icons.my_location_rounded,
                  onPressed: () {},
                ),
                const SizedBox(height: 12),
                _FloatingMapButton(
                  icon: Icons.settings_rounded,
                  onPressed: () => context.push(AppRouter.designCatalogue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingMapButton extends StatelessWidget {
  const _FloatingMapButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<UnoriveColors>();

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: customColors?.glassSurface ?? AppColors.darkSurfaceGlass,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: customColors?.border ?? AppColors.borderDark,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
