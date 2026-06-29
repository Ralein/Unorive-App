import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unorive/core/services/local_storage_service.dart';
import 'package:unorive/data/models/trip.dart';
import 'package:unorive/data/repositories/trip_history_repository.dart';
import 'package:unorive/features/auth/auth_provider.dart';

part 'trip_history_provider.g.dart';

/// Provider exposing the [TripHistoryRepository] implementation.
@riverpod
TripHistoryRepository tripHistoryRepository(Ref ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return TripHistoryRepositoryImpl(storage: storage);
}

/// Notifier managing the active list of trip history records and their sync.
@riverpod
class TripHistory extends _$TripHistory {
  @override
  List<Trip> build() {
    // Listen to changes in authentication state to trigger background merges
    ref.listen(authStateProvider, (previous, next) {
      final user = next.value;
      if (user != null && !user.isAnonymous) {
        sync(user.uid);
      }
    });

    final repo = ref.read(tripHistoryRepositoryProvider);

    // Attempt opportunistic sync on load if user is already authenticated
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null && !user.isAnonymous) {
      Future.microtask(() => sync(user.uid));
    }

    return repo.getTripHistory();
  }

  /// Adds a new completed or cancelled trip record.
  Future<void> addTrip(Trip trip) async {
    final repo = ref.read(tripHistoryRepositoryProvider);
    await repo.saveTripToHistory(trip);
    state = repo.getTripHistory();
  }

  /// Deletes a trip record by ID.
  Future<void> removeTrip(String id) async {
    final repo = ref.read(tripHistoryRepositoryProvider);
    await repo.deleteTripFromHistory(id);
    state = repo.getTripHistory();
  }

  /// Triggers a background merge with Firestore for the given user.
  Future<void> sync(String uid) async {
    final repo = ref.read(tripHistoryRepositoryProvider);
    await repo.sync(uid);
    state = repo.getTripHistory();
  }
}
