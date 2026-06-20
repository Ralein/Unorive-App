// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// State notifier managing active trip transitions, coordinates updates,
/// and coordinating OS background service lifecycle.

@ProviderFor(TripController)
final tripControllerProvider = TripControllerProvider._();

/// State notifier managing active trip transitions, coordinates updates,
/// and coordinating OS background service lifecycle.
final class TripControllerProvider
    extends $NotifierProvider<TripController, TripState> {
  /// State notifier managing active trip transitions, coordinates updates,
  /// and coordinating OS background service lifecycle.
  TripControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tripControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tripControllerHash();

  @$internal
  @override
  TripController create() => TripController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TripState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TripState>(value),
    );
  }
}

String _$tripControllerHash() => r'b6896c30fd2909c6b504d9a305bd09481d42d755';

/// State notifier managing active trip transitions, coordinates updates,
/// and coordinating OS background service lifecycle.

abstract class _$TripController extends $Notifier<TripState> {
  TripState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TripState, TripState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TripState, TripState>,
              TripState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
