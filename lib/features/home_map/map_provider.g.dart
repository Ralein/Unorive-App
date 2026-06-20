// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier holding the active MapboxMap controller.

@ProviderFor(MapController)
final mapControllerProvider = MapControllerProvider._();

/// Notifier holding the active MapboxMap controller.
final class MapControllerProvider
    extends $NotifierProvider<MapController, MapboxMap?> {
  /// Notifier holding the active MapboxMap controller.
  MapControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapControllerHash();

  @$internal
  @override
  MapController create() => MapController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MapboxMap? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MapboxMap?>(value),
    );
  }
}

String _$mapControllerHash() => r'7fc329055aa44b88eb3a6ef26705434a0c277c2f';

/// Notifier holding the active MapboxMap controller.

abstract class _$MapController extends $Notifier<MapboxMap?> {
  MapboxMap? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MapboxMap?, MapboxMap?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MapboxMap?, MapboxMap?>,
              MapboxMap?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Notifier holding the currently selected destination.

@ProviderFor(SelectedDestination)
final selectedDestinationProvider = SelectedDestinationProvider._();

/// Notifier holding the currently selected destination.
final class SelectedDestinationProvider
    extends $NotifierProvider<SelectedDestination, Destination?> {
  /// Notifier holding the currently selected destination.
  SelectedDestinationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedDestinationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedDestinationHash();

  @$internal
  @override
  SelectedDestination create() => SelectedDestination();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Destination? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Destination?>(value),
    );
  }
}

String _$selectedDestinationHash() =>
    r'beb204ccf3c38f5b39ecd343d376c17fd9a44aa9';

/// Notifier holding the currently selected destination.

abstract class _$SelectedDestination extends $Notifier<Destination?> {
  Destination? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Destination?, Destination?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Destination?, Destination?>,
              Destination?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Notifier holding the current search input text.

@ProviderFor(DestinationSearchQuery)
final destinationSearchQueryProvider = DestinationSearchQueryProvider._();

/// Notifier holding the current search input text.
final class DestinationSearchQueryProvider
    extends $NotifierProvider<DestinationSearchQuery, String> {
  /// Notifier holding the current search input text.
  DestinationSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'destinationSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$destinationSearchQueryHash();

  @$internal
  @override
  DestinationSearchQuery create() => DestinationSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$destinationSearchQueryHash() =>
    r'17746136c7496f25c6ecf1966f7528f8a980554b';

/// Notifier holding the current search input text.

abstract class _$DestinationSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Fetches search autocomplete suggestions from Mapbox Search Box API,
/// falling back to mock results if offline or if the token is a placeholder.

@ProviderFor(searchSuggestions)
final searchSuggestionsProvider = SearchSuggestionsProvider._();

/// Fetches search autocomplete suggestions from Mapbox Search Box API,
/// falling back to mock results if offline or if the token is a placeholder.

final class SearchSuggestionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SearchSuggestion>>,
          List<SearchSuggestion>,
          FutureOr<List<SearchSuggestion>>
        >
    with
        $FutureModifier<List<SearchSuggestion>>,
        $FutureProvider<List<SearchSuggestion>> {
  /// Fetches search autocomplete suggestions from Mapbox Search Box API,
  /// falling back to mock results if offline or if the token is a placeholder.
  SearchSuggestionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchSuggestionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchSuggestionsHash();

  @$internal
  @override
  $FutureProviderElement<List<SearchSuggestion>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SearchSuggestion>> create(Ref ref) {
    return searchSuggestions(ref);
  }
}

String _$searchSuggestionsHash() => r'1eeb4093bf0c294feff07b70afc3f1622a3b91fc';

/// Fetches geocoding details (latitude/longitude) for a specific suggestion.

@ProviderFor(SuggestionGeocoder)
final suggestionGeocoderProvider = SuggestionGeocoderProvider._();

/// Fetches geocoding details (latitude/longitude) for a specific suggestion.
final class SuggestionGeocoderProvider
    extends $AsyncNotifierProvider<SuggestionGeocoder, Destination?> {
  /// Fetches geocoding details (latitude/longitude) for a specific suggestion.
  SuggestionGeocoderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'suggestionGeocoderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$suggestionGeocoderHash();

  @$internal
  @override
  SuggestionGeocoder create() => SuggestionGeocoder();
}

String _$suggestionGeocoderHash() =>
    r'c20bdbc95e86f2adad7430ced83bb6bc7530669a';

/// Fetches geocoding details (latitude/longitude) for a specific suggestion.

abstract class _$SuggestionGeocoder extends $AsyncNotifier<Destination?> {
  FutureOr<Destination?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Destination?>, Destination?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Destination?>, Destination?>,
              AsyncValue<Destination?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Fetches a route polyline from Mapbox Directions API or computes an offline mock path.

@ProviderFor(routeCoordinates)
final routeCoordinatesProvider = RouteCoordinatesFamily._();

/// Fetches a route polyline from Mapbox Directions API or computes an offline mock path.

final class RouteCoordinatesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<List<double>>>,
          List<List<double>>,
          FutureOr<List<List<double>>>
        >
    with
        $FutureModifier<List<List<double>>>,
        $FutureProvider<List<List<double>>> {
  /// Fetches a route polyline from Mapbox Directions API or computes an offline mock path.
  RouteCoordinatesProvider._({
    required RouteCoordinatesFamily super.from,
    required ({double startLat, double startLng, double endLat, double endLng})
    super.argument,
  }) : super(
         retry: null,
         name: r'routeCoordinatesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$routeCoordinatesHash();

  @override
  String toString() {
    return r'routeCoordinatesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<List<double>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<List<double>>> create(Ref ref) {
    final argument =
        this.argument
            as ({
              double startLat,
              double startLng,
              double endLat,
              double endLng,
            });
    return routeCoordinates(
      ref,
      startLat: argument.startLat,
      startLng: argument.startLng,
      endLat: argument.endLat,
      endLng: argument.endLng,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RouteCoordinatesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$routeCoordinatesHash() => r'f2728e6abde9ad1bc7acebfa892038dc90d0bc8e';

/// Fetches a route polyline from Mapbox Directions API or computes an offline mock path.

final class RouteCoordinatesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<List<double>>>,
          ({double startLat, double startLng, double endLat, double endLng})
        > {
  RouteCoordinatesFamily._()
    : super(
        retry: null,
        name: r'routeCoordinatesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches a route polyline from Mapbox Directions API or computes an offline mock path.

  RouteCoordinatesProvider call({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) => RouteCoordinatesProvider._(
    argument: (
      startLat: startLat,
      startLng: startLng,
      endLat: endLat,
      endLng: endLng,
    ),
    from: this,
  );

  @override
  String toString() => r'routeCoordinatesProvider';
}
