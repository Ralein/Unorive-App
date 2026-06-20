// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geofence_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(geofenceService)
final geofenceServiceProvider = GeofenceServiceProvider._();

final class GeofenceServiceProvider
    extends
        $FunctionalProvider<GeofenceService, GeofenceService, GeofenceService>
    with $Provider<GeofenceService> {
  GeofenceServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'geofenceServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$geofenceServiceHash();

  @$internal
  @override
  $ProviderElement<GeofenceService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GeofenceService create(Ref ref) {
    return geofenceService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeofenceService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeofenceService>(value),
    );
  }
}

String _$geofenceServiceHash() => r'4c5b7ddb1de2199150ddeb0eb2a36a5f39aa2152';
