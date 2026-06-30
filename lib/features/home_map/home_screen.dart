import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:unorive/app/router.dart';
import 'package:unorive/core/theme/colors.dart';
import 'package:unorive/core/theme/spacing.dart';
import 'package:unorive/core/widgets/app_button.dart';
import 'package:unorive/core/widgets/glass_card.dart';
import 'package:unorive/features/home_map/map_provider.dart';
import 'package:unorive/features/trip_tracking/trip_provider.dart';
import 'package:unorive/features/trip_tracking/trip_tracking_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  MapboxMap? _mapboxMap;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSuggestionsVisible = false;

  // Default coordinate if GPS is unavailable: London
  static const double defaultLat = 51.5074;
  static const double defaultLng = -0.1278;

  double _userLat = defaultLat;
  double _userLng = defaultLng;

  bool get _isRunningInTests {
    if (kIsWeb) return false;
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _initUserLocation();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSuggestionsVisible = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initUserLocation() async {
    try {
      final status = await Permission.location.status;
      if (status.isGranted) {
        final pos = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.high,
        );
        if (mounted) {
          setState(() {
            _userLat = pos.latitude;
            _userLng = pos.longitude;
          });
        }
      }
    } catch (_) {
      // Keep defaults
    }
  }

  void _onMapCreated(MapboxMap controller) {
    _mapboxMap = controller;
    ref.read(mapControllerProvider.notifier).setController(controller);

    // Enable location component puck
    try {
      controller.location.updateSettings(
        LocationComponentSettings(
          enabled: true,
          pulsingEnabled: true,
          showAccuracyRing: true,
        ),
      );
    } catch (_) {}

    // Intro fly-to camera animation (globe down to user's tilted 3D street level location)
    Future<void>.delayed(const Duration(milliseconds: 600), () {
      if (mounted && _mapboxMap != null) {
        _mapboxMap!.flyTo(
          CameraOptions(
            center: Point(coordinates: Position(_userLng, _userLat)),
            zoom: 14.5,
            pitch: 55.0,
            bearing: 0,
          ),
          MapAnimationOptions(duration: 2500, startDelay: 0),
        );
      }
    });

    // Draw active route on startup if a trip is already in progress
    final tripState = ref.read(tripControllerProvider);
    if (tripState.status == TripStatus.active && tripState.destination != null) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _drawRoute(tripState.destination!);
        }
      });
    }

    final selectedDest = ref.read(selectedDestinationProvider);
    if (selectedDest != null && tripState.status != TripStatus.active) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _drawRoute(selectedDest);
        }
      });
    }
  }

  Future<void> _drawRoute(Destination dest) async {
    if (_isRunningInTests || _mapboxMap == null) return;

    // Fetch coordinates from route provider
    final route = await ref.read(
      routeCoordinatesProvider(
        startLat: _userLat,
        startLng: _userLng,
        endLat: dest.latitude,
        endLng: dest.longitude,
      ).future,
    );

    if (route.isNotEmpty && _mapboxMap != null) {
      final lineString = LineString(
        coordinates: route.map((c) => Position(c[0], c[1])).toList(),
      );

      final sourceId = 'route_source';
      final layerId = 'route_layer';
      final markerSourceId = 'dest_marker_source';
      final markerLayerId = 'dest_marker_layer';

      try {
        final style = _mapboxMap!.style;

        // Clean up previous layers/sources if they exist
        if (await style.styleLayerExists(layerId)) {
          await style.removeStyleLayer(layerId);
        }
        if (await style.styleSourceExists(sourceId)) {
          await style.removeStyleSource(sourceId);
        }
        if (await style.styleLayerExists(markerLayerId)) {
          await style.removeStyleLayer(markerLayerId);
        }
        if (await style.styleSourceExists(markerSourceId)) {
          await style.removeStyleSource(markerSourceId);
        }

        // Draw Route Polyline
        await style.addSource(GeoJsonSource(
          id: sourceId,
          data: jsonEncode(lineString.toJson()),
        ));
        await style.addLayer(LineLayer(
          id: layerId,
          sourceId: sourceId,
          lineColor: AppColors.darkPrimary.value,
          lineWidth: 5.0,
        ));

        // Draw Destination marker circle
        final markerGeoJson = {
          'type': 'Feature',
          'geometry': {
            'type': 'Point',
            'coordinates': [dest.longitude, dest.latitude]
          }
        };
        await style.addSource(GeoJsonSource(
          id: markerSourceId,
          data: jsonEncode(markerGeoJson),
        ));
        await style.addLayer(CircleLayer(
          id: markerLayerId,
          sourceId: markerSourceId,
          circleColor: AppColors.darkAccent.value,
          circleRadius: 10.0,
          circleStrokeWidth: 3.0,
          circleStrokeColor: Colors.white.value,
        ));

        // Fit camera bounds to route - 4 positional arguments allowed
        final cameraOptions = await _mapboxMap!.cameraForGeometry(
          lineString.toJson(),
          MbxEdgeInsets(top: 100, left: 50, bottom: 250, right: 50),
          null,
          null,
        );
        await _mapboxMap!.easeTo(cameraOptions, MapAnimationOptions(duration: 1000));
      } catch (_) {}
    }
  }

  void _clearSelection() {
    ref.read(selectedDestinationProvider.notifier).clear();
    ref.read(destinationSearchQueryProvider.notifier).updateQuery('');
    _searchController.clear();
    _searchFocusNode.unfocus();
    _removeRoute();
  }

  Future<void> _removeRoute() async {
    if (_mapboxMap == null) return;
    try {
      final style = _mapboxMap!.style;
      if (await style.styleLayerExists('route_layer')) {
        await style.removeStyleLayer('route_layer');
      }
      if (await style.styleSourceExists('route_source')) {
        await style.removeStyleSource('route_source');
      }
      if (await style.styleLayerExists('dest_marker_layer')) {
        await style.removeStyleLayer('dest_marker_layer');
      }
      if (await style.styleSourceExists('dest_marker_source')) {
        await style.removeStyleSource('dest_marker_source');
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<UnoriveColors>();
    
    final selectedDest = ref.watch(selectedDestinationProvider);
    final suggestionsAsync = ref.watch(searchSuggestionsProvider);
    final tripState = ref.watch(tripControllerProvider);
    final isTripActive = tripState.status == TripStatus.active;

    ref.listen<TripState>(tripControllerProvider, (previous, next) {
      if (previous?.status == TripStatus.active && next.status == TripStatus.cancelled) {
        _clearSelection();
      } else if (previous?.status == TripStatus.active && next.status == TripStatus.arrived) {
        _clearSelection();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have arrived at your destination!')),
        );
      }
    });

    ref.listen<Destination?>(selectedDestinationProvider, (previous, next) {
      if (next != null) {
        _drawRoute(next);
      } else {
        _removeRoute();
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Map Layer (Native Mapbox or Testing Fallback)
          Positioned.fill(
            child: _isRunningInTests
                ? _buildSimulatedMap(context)
                : MapWidget(
                    key: const ValueKey('mapbox_map_widget'),
                    styleUri: 'mapbox://styles/mapbox/standard',
                    onMapCreated: _onMapCreated,
                    onLongTapListener: (context) {
                      if (isTripActive) return;
                      final point = context.point;
                      final lat = point.coordinates.lat.toDouble();
                      final lng = point.coordinates.lng.toDouble();
                      
                      final destination = Destination(
                        name: 'Dropped Pin',
                        address: 'Coordinates: ${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
                        latitude: lat,
                        longitude: lng,
                      );

                      ref.read(selectedDestinationProvider.notifier).select(destination);
                      _drawRoute(destination);
                    },
                    cameraOptions: CameraOptions(
                      center: Point(coordinates: Position(0.0, 20.0)),
                      zoom: 1.5,
                      pitch: 0,
                      bearing: 0,
                    ),
                  ),
          ),

          // Autocomplete suggestions popup overlay
          if (!isTripActive && _isSuggestionsVisible && _searchController.text.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              left: 16,
              right: 16,
              child: suggestionsAsync.when(
                data: (suggestions) {
                  if (suggestions.isEmpty) return const SizedBox.shrink();
                  return GlassCard(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 250),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: suggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = suggestions[index];
                          return ListTile(
                            key: ValueKey('suggestion_${suggestion.id}'),
                            title: Text(
                              suggestion.name,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              suggestion.description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            onTap: () async {
                              _searchController.text = suggestion.name;
                              _searchFocusNode.unfocus();
                              setState(() {
                                _isSuggestionsVisible = false;
                              });

                              final destination = await ref
                                  .read(suggestionGeocoderProvider.notifier)
                                  .geocode(suggestion);

                              if (destination != null) {
                                ref.read(selectedDestinationProvider.notifier).select(destination);
                                _drawRoute(destination);
                              }
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
                loading: () => const GlassCard(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                ),
                error: (e, _) => GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      'Failed to load search results',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                ),
              ),
            ),

          // Search Bar floating overlay (Top)
          if (!isTripActive)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              child: SafeArea(
                top: false,
                bottom: false,
                child: Container(
                  decoration: BoxDecoration(
                    color: customColors?.glassSurface ?? AppColors.darkSurfaceGlass,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
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
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Search destination...',
                      hintStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: theme.colorScheme.secondary,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: _clearSelection,
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md + 2,
                      ),
                    ),
                    onChanged: (val) {
                      ref.read(destinationSearchQueryProvider.notifier).updateQuery(val);
                      setState(() {});
                    },
                  ),
                ),
              ),
            ),

          // Floating Action Buttons (My Location, Settings Catalog)
          Positioned(
            bottom: isTripActive
                ? 320
                : (selectedDest == null ? 32 : 240),
            right: 16,
            child: Column(
              children: [
                _FloatingMapButton(
                  icon: Icons.my_location_rounded,
                  onPressed: () {
                    if (_mapboxMap != null) {
                      _mapboxMap!.flyTo(
                        CameraOptions(
                          center: Point(coordinates: Position(_userLng, _userLat)),
                          zoom: 15.0,
                          pitch: 45.0,
                        ),
                        MapAnimationOptions(duration: 1500),
                      );
                    }
                  },
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 12),
                  _FloatingMapButton(
                    key: const ValueKey('debug_reliability_button'),
                    icon: Icons.bug_report_rounded,
                    onPressed: () => context.push(AppRouter.backgroundReliability),
                  ),
                ],
                if (!isTripActive) ...[
                  const SizedBox(height: 12),
                  _FloatingMapButton(
                    key: const ValueKey('saved_places_button'),
                    icon: Icons.bookmark_rounded,
                    onPressed: () => context.push(AppRouter.savedPlaces),
                  ),
                  const SizedBox(height: 12),
                  _FloatingMapButton(
                    key: const ValueKey('trip_history_button'),
                    icon: Icons.history_rounded,
                    onPressed: () => context.push(AppRouter.tripHistory),
                  ),
                ],
                const SizedBox(height: 12),
                _FloatingMapButton(
                  key: const ValueKey('settings_button'),
                  icon: Icons.settings_rounded,
                  onPressed: () => context.push(AppRouter.settings),
                ),
              ],
            ),
          ),

          // Floating Destination Detail Card & Start Trip CTA (Bottom)
          if (!isTripActive && selectedDest != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: SafeArea(
                child: GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: (customColors?.arrivalAccent ?? AppColors.darkAccent)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: Icon(
                                Icons.place_rounded,
                                color: customColors?.arrivalAccent ?? AppColors.darkAccent,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedDest.name,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    selectedDest.address,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: _clearSelection,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppButton.primary(
                          key: const ValueKey('start_trip_button'),
                          text: 'Start Trip',
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              await ref.read(tripControllerProvider.notifier).startTrip(selectedDest);
                              _drawRoute(selectedDest);
                            } catch (e) {
                              messenger.showSnackBar(
                                SnackBar(content: Text('Failed to start trip: $e')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Active Trip Bottom Sheet overlay
          if (isTripActive)
            const TripTrackingSheet(
              key: ValueKey('trip_tracking_sheet'),
            ),
        ],
      ),
    );
  }

  // A mock map widget for running UI widget tests cleanly without loading platform view MapWidget
  Widget _buildSimulatedMap(BuildContext context) {
    final theme = Theme.of(context);
    final selectedDest = ref.watch(selectedDestinationProvider);
    final tripState = ref.watch(tripControllerProvider);
    final isTripActive = tripState.status == TripStatus.active;
    final activeDest = tripState.destination;

    return GestureDetector(
      onLongPressDown: (details) {
        if (isTripActive) return; // Disallow drops when trip is active
        // Drop a pin relative to screen click offset
        final destination = Destination(
          name: 'Dropped Pin (Simulated)',
          address: 'Simulated location coordinates',
          latitude: 51.5074,
          longitude: -0.1278,
        );
        ref.read(selectedDestinationProvider.notifier).select(destination);
      },
      child: Container(
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
                isTripActive
                    ? 'Map: Active Trip Tracking'
                    : (selectedDest != null ? 'Map: Route rendering active' : 'Simulated 3D Map Canvas'),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
              if (isTripActive && activeDest != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Tracking route to ${activeDest.name}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
              ] else if (selectedDest != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Route draws to ${selectedDest.name}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
              ] else ...[
                Text(
                  '(Long-press to drop a pin)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingMapButton extends StatelessWidget {
  const _FloatingMapButton({
    required this.icon,
    required this.onPressed,
    super.key,
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
