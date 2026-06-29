import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:unorive/core/services/local_storage_service.dart';
import 'package:unorive/data/models/trip.dart';

/// Abstract repository managing past trip records (history).
abstract class TripHistoryRepository {
  /// Retrieves all locally cached trip history records.
  List<Trip> getTripHistory();

  /// Saves a completed or cancelled trip record locally and updates Firestore if authenticated.
  Future<void> saveTripToHistory(Trip trip);

  /// Deletes a trip record locally and updates Firestore if authenticated.
  Future<void> deleteTripFromHistory(String id);

  /// Merges local Hive records with Firestore records.
  Future<void> sync(String uid);
}

/// Concrete implementation of [TripHistoryRepository] managing Hive and Firestore.
class TripHistoryRepositoryImpl implements TripHistoryRepository {
  TripHistoryRepositoryImpl({required LocalStorageService storage}) : _storage = storage;

  final LocalStorageService _storage;

  bool get _useFirestore =>
      Firebase.apps.isNotEmpty && FirebaseAuth.instance.currentUser != null;

  String? get _currentUid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? _getUserCollection(String uid) {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid).collection('trip_history');
  }

  @override
  List<Trip> getTripHistory() {
    final list = _storage.getTripHistoryJson();
    return list.map((jsonStr) {
      return Trip.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    }).toList();
  }

  @override
  Future<void> saveTripToHistory(Trip trip) async {
    // 1. Write to local Hive box for instant UI update
    await _storage.saveTripHistoryJson(trip.id, jsonEncode(trip.toJson()));

    // 2. Propagate to Cloud Firestore if authenticated
    if (_useFirestore) {
      final uid = _currentUid;
      if (uid != null) {
        try {
          await _getUserCollection(uid)?.doc(trip.id).set(trip.toJson());
        } catch (_) {
          // Recover silently
        }
      }
    }
  }

  @override
  Future<void> deleteTripFromHistory(String id) async {
    // 1. Delete from local Hive box
    await _storage.deleteTripHistory(id);

    // 2. Propagate delete to Cloud Firestore if authenticated
    if (_useFirestore) {
      final uid = _currentUid;
      if (uid != null) {
        try {
          await _getUserCollection(uid)?.doc(id).delete();
        } catch (_) {
          // Recover silently
        }
      }
    }
  }

  @override
  Future<void> sync(String uid) async {
    if (Firebase.apps.isEmpty) return;

    try {
      final userCollection = _getUserCollection(uid);
      if (userCollection == null) return;

      // 1. Fetch remote records from Firestore
      final snapshot = await userCollection.get().timeout(const Duration(seconds: 5));
      final remoteTrips = snapshot.docs.map((doc) => Trip.fromJson(doc.data())).toList();

      // 2. Fetch local records from Hive
      final localTrips = getTripHistory();

      final Map<String, Trip> localMap = {for (var t in localTrips) t.id: t};
      final Map<String, Trip> remoteMap = {for (var t in remoteTrips) t.id: t};

      // Conflict Resolution Strategy: Last-Write-Wins (LWW) based on createdAt
      
      // Upload missing or newer local trips to Firestore
      for (final local in localTrips) {
        final remote = remoteMap[local.id];
        if (remote == null || local.createdAt.isAfter(remote.createdAt)) {
          await userCollection.doc(local.id).set(local.toJson());
        }
      }

      // Download missing or newer remote trips to local Hive
      for (final remote in remoteTrips) {
        final local = localMap[remote.id];
        if (local == null || remote.createdAt.isAfter(local.createdAt)) {
          await _storage.saveTripHistoryJson(remote.id, jsonEncode(remote.toJson()));
        }
      }
    } catch (_) {
      // Recover silently in case of timeout or offline sync failures
    }
  }
}
