import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unorive/core/services/local_storage_service.dart';
import 'package:unorive/data/models/saved_place.dart';
import 'package:unorive/data/repositories/saved_places_repository.dart';
import 'package:unorive/features/auth/auth_provider.dart';

part 'saved_places_provider.g.dart';

/// Provider exposing the [SavedPlacesRepository] implementation.
@riverpod
SavedPlacesRepository savedPlacesRepository(Ref ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return SavedPlacesRepositoryImpl(storage: storage);
}

/// Notifier managing the active list of saved favorite places and their sync.
@riverpod
class SavedPlaces extends _$SavedPlaces {
  @override
  List<SavedPlace> build() {
    // Listen to changes in authentication state to trigger background merges
    ref.listen(authStateProvider, (previous, next) {
      final user = next.value;
      if (user != null && !user.isAnonymous) {
        sync(user.uid);
      }
    });

    final repo = ref.read(savedPlacesRepositoryProvider);
    
    // Attempt opportunistic sync on load if user is already authenticated
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null && !user.isAnonymous) {
      Future.microtask(() => sync(user.uid));
    }

    return repo.getSavedPlaces();
  }

  /// Adds a new favorite place to storage.
  Future<void> addPlace(SavedPlace place) async {
    final repo = ref.read(savedPlacesRepositoryProvider);
    await repo.saveSavedPlace(place);
    state = repo.getSavedPlaces();
  }

  /// Deletes a favorite place from storage.
  Future<void> removePlace(String id) async {
    final repo = ref.read(savedPlacesRepositoryProvider);
    await repo.deleteSavedPlace(id);
    state = repo.getSavedPlaces();
  }

  /// Triggers a background merge with Firestore for the given user.
  Future<void> sync(String uid) async {
    final repo = ref.read(savedPlacesRepositoryProvider);
    await repo.sync(uid);
    state = repo.getSavedPlaces();
  }
}
