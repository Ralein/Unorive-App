import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:unorive/data/models/user_profile.dart';

/// Abstract repository managing user authentication state and operations.
abstract class AuthRepository {
  /// Stream of current authenticated user profiles.
  Stream<UserProfile?> get authStateChanges;

  /// Returns the current signed in user profile.
  UserProfile? get currentUser;

  /// Signs in anonymously.
  Future<UserProfile> signInAnonymously();

  /// Signs in with Google credentials (mocked for Phase 2).
  Future<UserProfile> signInWithGoogle();

  /// Signs in with Apple credentials (mocked for Phase 2).
  Future<UserProfile> signInWithApple();

  /// Signs out the current user.
  Future<void> signOut();
}

/// Concrete implementation of [AuthRepository] utilizing [FirebaseAuth],
/// with auto-fallback to mock credentials if Firebase is uninitialized.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl();

  final StreamController<UserProfile?> _mockAuthController = StreamController<UserProfile?>.broadcast();
  UserProfile? _mockUser;

  bool get _useFirebase => Firebase.apps.isNotEmpty;

  @override
  Stream<UserProfile?> get authStateChanges {
    if (_useFirebase) {
      return FirebaseAuth.instance.authStateChanges().map(_mapFirebaseUser);
    }
    // Return mock stream
    return _mockAuthController.stream;
  }

  @override
  UserProfile? get currentUser {
    if (_useFirebase) {
      return _mapFirebaseUser(FirebaseAuth.instance.currentUser);
    }
    return _mockUser;
  }

  @override
  Future<UserProfile> signInAnonymously() async {
    if (_useFirebase) {
      final credentials = await FirebaseAuth.instance.signInAnonymously();
      final user = _mapFirebaseUser(credentials.user);
      if (user != null) return user;
      throw Exception('Firebase Anonymous Login failed.');
    } else {
      // Mock login
      _mockUser = const UserProfile(
        uid: 'mock_guest_uid_123',
        email: 'guest@unorive.com',
        displayName: 'Guest Traveller',
        isAnonymous: true,
      );
      _mockAuthController.add(_mockUser);
      return _mockUser!;
    }
  }

  @override
  Future<UserProfile> signInWithGoogle() async {
    // Phase 2 Mock
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _mockUser = const UserProfile(
      uid: 'mock_google_uid_456',
      email: 'traveller.google@gmail.com',
      displayName: 'Google Explorer',
      isAnonymous: false,
    );
    _mockAuthController.add(_mockUser);
    return _mockUser!;
  }

  @override
  Future<UserProfile> signInWithApple() async {
    // Phase 2 Mock
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _mockUser = const UserProfile(
      uid: 'mock_apple_uid_789',
      email: 'traveller.apple@icloud.com',
      displayName: 'Apple Explorer',
      isAnonymous: false,
    );
    _mockAuthController.add(_mockUser);
    return _mockUser!;
  }

  @override
  Future<void> signOut() async {
    if (_useFirebase) {
      await FirebaseAuth.instance.signOut();
    } else {
      _mockUser = null;
      _mockAuthController.add(null);
    }
  }

  UserProfile? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return UserProfile(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? (user.isAnonymous ? 'Guest' : ''),
      isAnonymous: user.isAnonymous,
    );
  }
}
