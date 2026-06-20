import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_provider.g.dart';

/// Safely retrieves the Mapbox access token, guarding against unit test environments.
String _getMapboxToken() {
  try {
    return dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
  } catch (_) {
    return '';
  }
}

/// Class representing a geocoded destination result.
class Destination {
  const Destination({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address = '',
  });

  final String name;
  final double latitude;
  final double longitude;
  final String address;

  Map<String, dynamic> toJson() => {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
      };
}

/// Class representing autocomplete suggestions for map search.
class SearchSuggestion {
  const SearchSuggestion({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;
}

/// Notifier holding the active MapboxMap controller.
@riverpod
class MapController extends _$MapController {
  @override
  MapboxMap? build() => null;

  void setController(MapboxMap controller) {
    state = controller;
  }
}

/// Notifier holding the currently selected destination.
@riverpod
class SelectedDestination extends _$SelectedDestination {
  @override
  Destination? build() => null;

  void select(Destination destination) {
    state = destination;
  }

  void clear() {
    state = null;
  }
}

/// Notifier holding the current search input text.
@riverpod
class DestinationSearchQuery extends _$DestinationSearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }
}

/// Fetches search autocomplete suggestions from Mapbox Search Box API,
/// falling back to mock results if offline or if the token is a placeholder.
@riverpod
Future<List<SearchSuggestion>> searchSuggestions(Ref ref) async {
  final query = ref.watch(destinationSearchQueryProvider);
  if (query.trim().isEmpty) return const [];

  final token = _getMapboxToken();
  final isPlaceholder = token.isEmpty || token.toLowerCase().contains('placeholder');

  if (isPlaceholder) {
    // Return mock suggestions for local testing
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return [
      SearchSuggestion(
        id: 'mock_1',
        name: '${query.trim()} Central Station',
        description: 'Transit Hub, Downtown Area',
      ),
      SearchSuggestion(
        id: 'mock_2',
        name: '${query.trim()} International Airport',
        description: 'Terminal 1, Boulevard Expressway',
      ),
      SearchSuggestion(
        id: 'mock_3',
        name: '${query.trim()} City Park',
        description: 'Recreation Center, Greenway District',
      ),
    ];
  }

  try {
    final url = Uri.parse(
      'https://api.mapbox.com/search/searchbox/v1/suggest?q=${Uri.encodeComponent(query)}&access_token=$token&limit=5',
    );
    final response = await http.get(url).timeout(const Duration(seconds: 4));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final suggestions = data['suggestions'] as List<dynamic>? ?? [];
      return suggestions.map((item) {
        final map = item as Map<String, dynamic>;
        return SearchSuggestion(
          id: map['mapbox_id'] as String? ?? '',
          name: map['name'] as String? ?? '',
          description: map['full_address'] as String? ?? map['place_formatted'] as String? ?? '',
        );
      }).toList();
    }
  } catch (_) {
    // Fail silently and return empty or standard fallbacks
  }

  return [
    SearchSuggestion(
      id: 'fallback_1',
      name: '${query.trim()} (Offline Fallback)',
      description: 'Check your internet connection',
    ),
  ];
}

/// Fetches geocoding details (latitude/longitude) for a specific suggestion.
@riverpod
class SuggestionGeocoder extends _$SuggestionGeocoder {
  @override
  FutureOr<Destination?> build() => null;

  Future<Destination?> geocode(SearchSuggestion suggestion) async {
    state = const AsyncValue.loading();
    final token = _getMapboxToken();
    final isPlaceholder = token.isEmpty || token.toLowerCase().contains('placeholder');

    if (isPlaceholder || suggestion.id.startsWith('mock') || suggestion.id.startsWith('fallback')) {
      // Mock coordinates (e.g. slight offsets from a central coordinate)
      final destination = Destination(
        name: suggestion.name,
        address: suggestion.description,
        latitude: 51.5074 + (suggestion.id.hashCode % 100) * 0.001,
        longitude: -0.1278 + (suggestion.id.hashCode % 100) * 0.001,
      );
      state = AsyncValue.data(destination);
      return destination;
    }

    try {
      final url = Uri.parse(
        'https://api.mapbox.com/search/searchbox/v1/retrieve/${suggestion.id}?access_token=$token',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final features = data['features'] as List<dynamic>? ?? [];
        if (features.isNotEmpty) {
          final first = features.first as Map<String, dynamic>;
          final geometry = first['geometry'] as Map<String, dynamic>;
          final coordinates = geometry['coordinates'] as List<dynamic>;
          final properties = first['properties'] as Map<String, dynamic>;
          
          final destination = Destination(
            name: properties['name'] as String? ?? suggestion.name,
            address: properties['full_address'] as String? ?? suggestion.description,
            latitude: coordinates[1] as double,
            longitude: coordinates[0] as double,
          );
          state = AsyncValue.data(destination);
          return destination;
        }
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
    return null;
  }
}

/// Fetches a route polyline from Mapbox Directions API or computes an offline mock path.
@riverpod
Future<List<List<double>>> routeCoordinates(
  Ref ref, {
  required double startLat,
  required double startLng,
  required double endLat,
  required double endLng,
}) async {
  final token = _getMapboxToken();
  final isPlaceholder = token.isEmpty || token.toLowerCase().contains('placeholder');

  if (isPlaceholder) {
    // Generate an offline mock route (3 points: start, mid-point offset, end)
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final midLat = (startLat + endLat) / 2 + 0.005;
    final midLng = (startLng + endLng) / 2 + 0.005;
    return [
      [startLng, startLat],
      [midLng, midLat],
      [endLng, endLat],
    ];
  }

  try {
    final url = Uri.parse(
      'https://api.mapbox.com/directions/v5/mapbox/driving/$startLng,$startLat;$endLng,$endLat?geometries=geojson&access_token=$token',
    );
    final response = await http.get(url).timeout(const Duration(seconds: 4));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final routes = data['routes'] as List<dynamic>? ?? [];
      if (routes.isNotEmpty) {
        final firstRoute = routes.first as Map<String, dynamic>;
        final geometry = firstRoute['geometry'] as Map<String, dynamic>;
        final coords = geometry['coordinates'] as List<dynamic>;
        return coords.map((c) => (c as List<dynamic>).map((v) => (v as num).toDouble()).toList()).toList();
      }
    }
  } catch (_) {
    // Fallback to straight line on error
  }

  return [
    [startLng, startLat],
    [endLng, endLat],
  ];
}
