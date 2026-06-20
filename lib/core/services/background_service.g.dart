// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'background_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(backgroundService)
final backgroundServiceProvider = BackgroundServiceProvider._();

final class BackgroundServiceProvider
    extends
        $FunctionalProvider<
          BackgroundService,
          BackgroundService,
          BackgroundService
        >
    with $Provider<BackgroundService> {
  BackgroundServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backgroundServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backgroundServiceHash();

  @$internal
  @override
  $ProviderElement<BackgroundService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BackgroundService create(Ref ref) {
    return backgroundService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackgroundService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackgroundService>(value),
    );
  }
}

String _$backgroundServiceHash() => r'9e89058d6f9494b0182026b4d0093d38d1087cdf';
