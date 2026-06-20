// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(alarmService)
final alarmServiceProvider = AlarmServiceProvider._();

final class AlarmServiceProvider
    extends $FunctionalProvider<AlarmService, AlarmService, AlarmService>
    with $Provider<AlarmService> {
  AlarmServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'alarmServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$alarmServiceHash();

  @$internal
  @override
  $ProviderElement<AlarmService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AlarmService create(Ref ref) {
    return alarmService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AlarmService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AlarmService>(value),
    );
  }
}

String _$alarmServiceHash() => r'cdecd230e4f1932b8089a48e2d68ffff4b7e9f53';
