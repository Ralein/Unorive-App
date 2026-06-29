import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unorive/core/theme/colors.dart';
import 'package:unorive/core/theme/spacing.dart';
import 'package:unorive/core/widgets/empty_state_view.dart';
import 'package:unorive/core/widgets/glass_card.dart';
import 'package:unorive/data/models/trip.dart';
import 'package:unorive/features/history/trip_history_provider.dart';

/// Screen listing past commute/trip logs, showing duration, arrived vs. cancelled status, and map previews.
class TripHistoryScreen extends ConsumerWidget {
  const TripHistoryScreen({super.key});

  String _getMapboxToken() {
    try {
      return dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
    } catch (_) {
      return '';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildThumbnail(Trip trip, String token) {
    final isPlaceholder = token.isEmpty || token.toLowerCase().contains('placeholder');
    if (isPlaceholder) {
      return _buildFallbackThumbnail();
    }

    final url = 'https://api.mapbox.com/styles/v1/mapbox/dark-v11/static/'
        'pin-s-marker+ff9f0a(${trip.longitude},${trip.latitude})/'
        '${trip.longitude},${trip.latitude},13/120x80?access_token=$token';

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(AppRadius.md),
        bottomLeft: Radius.circular(AppRadius.md),
      ),
      child: Image.network(
        url,
        width: 120,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackThumbnail(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 120,
            height: 80,
            color: Colors.white12,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFallbackThumbnail() {
    return Container(
      width: 120,
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.md),
          bottomLeft: Radius.circular(AppRadius.md),
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_rounded, color: Colors.white30, size: 24),
          SizedBox(height: 4),
          Text(
            'Map Preview',
            style: TextStyle(color: Colors.white30, fontSize: 10),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final history = ref.watch(tripHistoryProvider);
    final token = _getMapboxToken();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Trip History',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: history.isEmpty
            ? const EmptyStateView(
                title: 'No Commute Logs',
                description: 'Your completed or cancelled alarm runs will appear here.',
                icon: Icons.history_rounded,
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final trip = history[index];
                  final isArrived = trip.status == 'arrived';

                  return Dismissible(
                    key: Key(trip.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: AppSpacing.xl),
                      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 28),
                    ),
                    onDismissed: (_) {
                      ref.read(tripHistoryProvider.notifier).removeTrip(trip.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Trip log deleted'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      child: GlassCard(
                        child: Row(
                          children: [
                            // 1. Static Map Thumbnail Preview
                            _buildThumbnail(trip, token),
                            const SizedBox(width: AppSpacing.md),
                            
                            // 2. Info Details
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                  horizontal: AppSpacing.xs,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      trip.destinationName,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkTextPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDate(trip.createdAt),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: AppColors.darkTextSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        // Status Pill
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: (isArrived ? AppColors.success : AppColors.error)
                                                .withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            isArrived ? 'ARRIVED' : 'CANCELLED',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: isArrived ? AppColors.success : AppColors.error,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Duration Info
                                        Text(
                                          '${trip.durationMinutes ?? 0} mins',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: AppColors.darkTextSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
