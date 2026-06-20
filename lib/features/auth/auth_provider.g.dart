// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the [LocalStorageService]. Should be overridden in [ProviderScope]
/// after initialization.

@ProviderFor(localStorageService)
final localStorageServiceProvider = LocalStorageServiceProvider._();

/// Provider for the [LocalStorageService]. Should be overridden in [ProviderScope]
/// after initialization.

final class LocalStorageServiceProvider
    extends
        $FunctionalProvider<
          LocalStorageService,
          LocalStorageService,
          LocalStorageService
        >
    with $Provider<LocalStorageService> {
  /// Provider for the [LocalStorageService]. Should be overridden in [ProviderScope]
  /// after initialization.
  LocalStorageServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localStorageServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localStorageServiceHash();

  @$internal
  @override
  $ProviderElement<LocalStorageService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalStorageService create(Ref ref) {
    return localStorageService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalStorageService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalStorageService>(value),
    );
  }
}

String _$localStorageServiceHash() =>
    r'46e772f2239fc244cfedd1dbe12bf732712a9ea0';

/// Provider exposing the [AuthRepository] implementation.

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// Provider exposing the [AuthRepository] implementation.

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// Provider exposing the [AuthRepository] implementation.
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'a8767550d220ede9bb05149c073a651c4422d5ef';

/// Stream provider tracking changes in user authentication state.

@ProviderFor(authState)
final authStateProvider = AuthStateProvider._();

/// Stream provider tracking changes in user authentication state.

final class AuthStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserProfile?>,
          UserProfile?,
          Stream<UserProfile?>
        >
    with $FutureModifier<UserProfile?>, $StreamProvider<UserProfile?> {
  /// Stream provider tracking changes in user authentication state.
  AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $StreamProviderElement<UserProfile?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<UserProfile?> create(Ref ref) {
    return authState(ref);
  }
}

String _$authStateHash() => r'e68fd53e12c904cc10b746f85fdf4fa2dfc1901e';

/// Notifier managing and persisting the user onboarding completion status.

@ProviderFor(OnboardingController)
final onboardingControllerProvider = OnboardingControllerProvider._();

/// Notifier managing and persisting the user onboarding completion status.
final class OnboardingControllerProvider
    extends $NotifierProvider<OnboardingController, bool> {
  /// Notifier managing and persisting the user onboarding completion status.
  OnboardingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingControllerHash();

  @$internal
  @override
  OnboardingController create() => OnboardingController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$onboardingControllerHash() =>
    r'26307cf381931b7a13cc36d80edb056686f4f0d4';

/// Notifier managing and persisting the user onboarding completion status.

abstract class _$OnboardingController extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Notifier managing and persisting guest mode activation.

@ProviderFor(GuestModeController)
final guestModeControllerProvider = GuestModeControllerProvider._();

/// Notifier managing and persisting guest mode activation.
final class GuestModeControllerProvider
    extends $NotifierProvider<GuestModeController, bool> {
  /// Notifier managing and persisting guest mode activation.
  GuestModeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guestModeControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guestModeControllerHash();

  @$internal
  @override
  GuestModeController create() => GuestModeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$guestModeControllerHash() =>
    r'6287a46f4a0282c6617557ca51dade9304533232';

/// Notifier managing and persisting guest mode activation.

abstract class _$GuestModeController extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
