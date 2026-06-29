// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider exposing the [TripHistoryRepository] implementation.

@ProviderFor(tripHistoryRepository)
final tripHistoryRepositoryProvider = TripHistoryRepositoryProvider._();

/// Provider exposing the [TripHistoryRepository] implementation.

final class TripHistoryRepositoryProvider
    extends
        $FunctionalProvider<
          TripHistoryRepository,
          TripHistoryRepository,
          TripHistoryRepository
        >
    with $Provider<TripHistoryRepository> {
  /// Provider exposing the [TripHistoryRepository] implementation.
  TripHistoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tripHistoryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tripHistoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<TripHistoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TripHistoryRepository create(Ref ref) {
    return tripHistoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TripHistoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TripHistoryRepository>(value),
    );
  }
}

String _$tripHistoryRepositoryHash() =>
    r'583a8a27530a187ca4c49667b9baeb64ea05c025';

/// Notifier managing the active list of trip history records and their sync.

@ProviderFor(TripHistory)
final tripHistoryProvider = TripHistoryProvider._();

/// Notifier managing the active list of trip history records and their sync.
final class TripHistoryProvider
    extends $NotifierProvider<TripHistory, List<Trip>> {
  /// Notifier managing the active list of trip history records and their sync.
  TripHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tripHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tripHistoryHash();

  @$internal
  @override
  TripHistory create() => TripHistory();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Trip> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Trip>>(value),
    );
  }
}

String _$tripHistoryHash() => r'51593db9403ead6f9ec036c2c1c137effa1e6930';

/// Notifier managing the active list of trip history records and their sync.

abstract class _$TripHistory extends $Notifier<List<Trip>> {
  List<Trip> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Trip>, List<Trip>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Trip>, List<Trip>>,
              List<Trip>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
