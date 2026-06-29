import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:unorive/core/services/local_storage_service.dart';
import 'package:unorive/data/models/saved_place.dart';

/// Abstract repository managing saved favorite locations.
abstract class SavedPlacesRepository {
  /// Retrieves all locally saved places.
  List<SavedPlace> getSavedPlaces();

  /// Saves a favorite place locally and updates Firestore if authenticated.
  Future<void> saveSavedPlace(SavedPlace place);

  /// Deletes a favorite place locally and updates Firestore if authenticated.
  Future<void> deleteSavedPlace(String id);

  /// Merges local Hive records with Firestore records.
  Future<void> sync(String uid);
}

/// Concrete implementation of [SavedPlacesRepository] managing Hive and Firestore.
class SavedPlacesRepositoryImpl implements SavedPlacesRepository {
  SavedPlacesRepositoryImpl({required LocalStorageService storage}) : _storage = storage;

  final LocalStorageService _storage;

  bool get _useFirestore =>
      Firebase.apps.isNotEmpty && FirebaseAuth.instance.currentUser != null;

  String? get _currentUid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? _getUserCollection(String uid) {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid).collection('saved_places');
  }

  @override
  List<SavedPlace> getSavedPlaces() {
    final list = _storage.getSavedPlacesJson();
    return list.map((jsonStr) {
      return SavedPlace.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    }).toList();
  }

  @override
  Future<void> saveSavedPlace(SavedPlace place) async {
    // 1. Write to local Hive box for instant UI update
    await _storage.saveSavedPlaceJson(place.id, jsonEncode(place.toJson()));

    // 2. Propagate to Cloud Firestore if authenticated
    if (_useFirestore) {
      final uid = _currentUid;
      if (uid != null) {
        try {
          await _getUserCollection(uid)?.doc(place.id).set(place.toJson());
        } catch (_) {
          // Recover silently (Firestore auto-caches/retries offline writes)
        }
      }
    }
  }

  @override
  Future<void> deleteSavedPlace(String id) async {
    // 1. Delete from local Hive box
    await _storage.deleteSavedPlace(id);

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
      final remotePlaces = snapshot.docs.map((doc) => SavedPlace.fromJson(doc.data())).toList();

      // 2. Fetch local records from Hive
      final localPlaces = getSavedPlaces();

      final Map<String, SavedPlace> localMap = {for (var p in localPlaces) p.id: p};
      final Map<String, SavedPlace> remoteMap = {for (var p in remotePlaces) p.id: p};

      // Conflict Resolution Strategy: Last-Write-Wins (LWW) based on createdAt
      // For elements present in both, compare timestamps. Otherwise, copy missing elements.
      
      // Upload missing or newer local places to Firestore
      for (final local in localPlaces) {
        final remote = remoteMap[local.id];
        if (remote == null || local.createdAt.isAfter(remote.createdAt)) {
          await userCollection.doc(local.id).set(local.toJson());
        }
      }

      // Download missing or newer remote places to local Hive
      for (final remote in remotePlaces) {
        final local = localMap[remote.id];
        if (local == null || remote.createdAt.isAfter(local.createdAt)) {
          await _storage.saveSavedPlaceJson(remote.id, jsonEncode(remote.toJson()));
        }
      }
    } catch (_) {
      // Recover silently in case of timeout or offline sync failures
    }
  }
}
