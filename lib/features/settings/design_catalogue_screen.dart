import 'package:flutter/material.dart';
import 'package:unorive/core/theme/colors.dart';
import 'package:unorive/core/theme/spacing.dart';
import 'package:unorive/core/widgets/app_button.dart';
import 'package:unorive/core/widgets/bottom_sheet_scaffold.dart';
import 'package:unorive/core/widgets/empty_state_view.dart';
import 'package:unorive/core/widgets/glass_card.dart';
import 'package:unorive/core/widgets/status_pill.dart';

/// Internal Design System Catalog screen to visually QA typography, colors, and widgets.
class DesignCatalogueScreen extends StatelessWidget {
  const DesignCatalogueScreen({super.key});

  Future<void> _showBottomSheetDemo(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BottomSheetScaffold(
          builder: (context, scrollController) {
            return ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: 20,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text('Bottom Sheet Item ${index + 1}'),
                  subtitle: const Text('Draggable scrolling synchronization'),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<UnoriveColors>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Catalog'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color Palette Showcase
            const _SectionHeader(title: 'Color Palette'),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _ColorCard(
                  name: 'Primary (Indigo)',
                  color: theme.colorScheme.primary,
                  textColor: theme.colorScheme.onPrimary,
                ),
                _ColorCard(
                  name: 'Secondary (Cyan)',
                  color: theme.colorScheme.secondary,
                  textColor: Colors.black,
                ),
                _ColorCard(
                  name: 'Surface',
                  color: theme.colorScheme.surface,
                  textColor: theme.colorScheme.onSurface,
                ),
                _ColorCard(
                  name: 'Background',
                  color: theme.scaffoldBackgroundColor,
                  textColor: theme.colorScheme.onSurface,
                ),
                const _ColorCard(
                  name: 'Success',
                  color: AppColors.success,
                  textColor: Colors.white,
                ),
                const _ColorCard(
                  name: 'Warning',
                  color: AppColors.warning,
                  textColor: Colors.black,
                ),
                const _ColorCard(
                  name: 'Error',
                  color: AppColors.error,
                  textColor: Colors.white,
                ),
                if (customColors != null) ...[
                  _ColorCard(
                    name: 'Glass Surface',
                    color: customColors.glassSurface,
                    textColor: theme.colorScheme.onSurface,
                  ),
                  _ColorCard(
                    name: 'Arrival Accent',
                    color: customColors.arrivalAccent,
                    textColor: Colors.black,
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Typography Showcase
            const _SectionHeader(title: 'Typography Hierarchy'),
            _TextRow(label: 'Display Large (56px)', style: theme.textTheme.displayLarge),
            _TextRow(label: 'Display Medium (40px)', style: theme.textTheme.displayMedium),
            _TextRow(label: 'Display Small (32px)', style: theme.textTheme.displaySmall),
            _TextRow(label: 'Headline Large (28px)', style: theme.textTheme.headlineLarge),
            _TextRow(label: 'Headline Medium (24px)', style: theme.textTheme.headlineMedium),
            _TextRow(label: 'Headline Small (20px)', style: theme.textTheme.headlineSmall),
            _TextRow(label: 'Title Large (18px)', style: theme.textTheme.titleLarge),
            _TextRow(label: 'Title Medium (16px)', style: theme.textTheme.titleMedium),
            _TextRow(label: 'Title Small (14px)', style: theme.textTheme.titleSmall),
            _TextRow(label: 'Body Large (16px)', style: theme.textTheme.bodyLarge),
            _TextRow(label: 'Body Medium (14px)', style: theme.textTheme.bodyMedium),
            _TextRow(label: 'Body Small (12px)', style: theme.textTheme.bodySmall),
            _TextRow(label: 'Label Large (14px)', style: theme.textTheme.labelLarge),
            _TextRow(label: 'Label Medium (12px)', style: theme.textTheme.labelMedium),
            _TextRow(label: 'Label Small (10px)', style: theme.textTheme.labelSmall),
            const SizedBox(height: AppSpacing.xl),

            // Interactive Buttons Showcase
            const _SectionHeader(title: 'App Buttons (Scale Animation & Haptics)'),
            AppButton.primary(
              text: 'Primary Button',
              onPressed: () {},
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton.secondary(
              text: 'Secondary Button',
              onPressed: () {},
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: AppButton.primary(
                    text: 'Loading',
                    onPressed: () {},
                    isLoading: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton.primary(
                    text: 'Disabled',
                    onPressed: null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Status Pills Showcase
            const _SectionHeader(title: 'Status Pills'),
            const Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                StatusPill(label: 'Active Trip', type: StatusType.active),
                StatusPill(label: 'Arrived', type: StatusType.arrived),
                StatusPill(label: 'Warning', type: StatusType.warning),
                StatusPill(label: 'Cancelled', type: StatusType.error),
                StatusPill(label: 'Offline Cache', type: StatusType.neutral),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Glass Card Showcase
            const _SectionHeader(title: 'Glassmorphic Overlay Card'),
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Frosted Glass Container',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Translucent card with BackdropFilter blur overlaying the map background.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: customColors?.textMuted ?? AppColors.darkTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Draggable Bottom Sheet Demo Button
            const _SectionHeader(title: 'Interactive Sheets'),
            AppButton.secondary(
              text: 'Open Bottom Sheet Scaffold Demo',
              onPressed: () => _showBottomSheetDemo(context),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Empty State Showcase
            const _SectionHeader(title: 'Empty State Template'),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: customColors?.border ?? AppColors.borderDark),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: EmptyStateView(
                title: 'No Saved Places Yet',
                description: 'Favorites make starting trips much quicker. Pin a location to get started.',
                icon: Icons.bookmark_border_rounded,
                actionText: 'Add Favorite',
                onActionPressed: () {},
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const Divider(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _ColorCard extends StatelessWidget {
  const _ColorCard({
    required this.name,
    required this.color,
    required this.textColor,
  });

  final String name;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 105,
      height: 70,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            name,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
            style: TextStyle(
              color: textColor.withValues(alpha: 0.7),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

class _TextRow extends StatelessWidget {
  const _TextRow({
    required this.label,
    required this.style,
  });

  final String label;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .extension<UnoriveColors>()
                        ?.textMuted
                        .withValues(alpha: 0.7),
                  ),
            ),
          ),
          Expanded(
            child: Text(
              'Unorive Title',
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
