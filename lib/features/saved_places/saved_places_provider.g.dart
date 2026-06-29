// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_places_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider exposing the [SavedPlacesRepository] implementation.

@ProviderFor(savedPlacesRepository)
final savedPlacesRepositoryProvider = SavedPlacesRepositoryProvider._();

/// Provider exposing the [SavedPlacesRepository] implementation.

final class SavedPlacesRepositoryProvider
    extends
        $FunctionalProvider<
          SavedPlacesRepository,
          SavedPlacesRepository,
          SavedPlacesRepository
        >
    with $Provider<SavedPlacesRepository> {
  /// Provider exposing the [SavedPlacesRepository] implementation.
  SavedPlacesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedPlacesRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedPlacesRepositoryHash();

  @$internal
  @override
  $ProviderElement<SavedPlacesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SavedPlacesRepository create(Ref ref) {
    return savedPlacesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavedPlacesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavedPlacesRepository>(value),
    );
  }
}

String _$savedPlacesRepositoryHash() =>
    r'7e70a81a69d5c255a31c71ccca50ac0682fbd267';

/// Notifier managing the active list of saved favorite places and their sync.

@ProviderFor(SavedPlaces)
final savedPlacesProvider = SavedPlacesProvider._();

/// Notifier managing the active list of saved favorite places and their sync.
final class SavedPlacesProvider
    extends $NotifierProvider<SavedPlaces, List<SavedPlace>> {
  /// Notifier managing the active list of saved favorite places and their sync.
  SavedPlacesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedPlacesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedPlacesHash();

  @$internal
  @override
  SavedPlaces create() => SavedPlaces();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SavedPlace> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SavedPlace>>(value),
    );
  }
}

String _$savedPlacesHash() => r'fdeb61e3e9d36f9219e66e046058dc7342eab2db';

/// Notifier managing the active list of saved favorite places and their sync.

abstract class _$SavedPlaces extends $Notifier<List<SavedPlace>> {
  List<SavedPlace> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<SavedPlace>, List<SavedPlace>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<SavedPlace>, List<SavedPlace>>,
              List<SavedPlace>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
