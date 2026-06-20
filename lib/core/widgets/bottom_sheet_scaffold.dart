import 'package:flutter/material.dart';
import 'package:unorive/core/theme/colors.dart';
import 'package:unorive/core/theme/spacing.dart';

/// A draggable bottom sheet scaffold panel designed to snap to sizes
/// and display floating over a background map.
class BottomSheetScaffold extends StatelessWidget {
  const BottomSheetScaffold({
    required this.builder,
    super.key,
    this.initialChildSize = 0.35,
    this.minChildSize = 0.15,
    this.maxChildSize = 0.85,
  });

  /// The builder providing the scroll controller for content scroll synchronization.
  final ScrollableWidgetBuilder builder;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<UnoriveColors>();

    final defaultBg = customColors?.glassSurface ?? AppColors.darkSurfaceGlass;
    final defaultBorder = customColors?.border ?? AppColors.borderDark;

    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      snap: true,
      snapSizes: [minChildSize, initialChildSize, maxChildSize],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: defaultBg,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
            border: Border(
              top: BorderSide(color: defaultBorder),
              left: BorderSide(color: defaultBorder),
              right: BorderSide(color: defaultBorder),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.sm),
              // Draggable Handle Pill
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: customColors?.textMuted.withValues(alpha: 0.4) ??
                        AppColors.darkTextMuted.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppRadius.circular),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              
              // Bottom Sheet Content List
              Expanded(
                child: builder(context, scrollController),
              ),
            ],
          ),
        );
      },
    );
  }
}
