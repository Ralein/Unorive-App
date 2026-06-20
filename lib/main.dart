import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load Environment Variables (.env)
  try {
    await dotenv.load(fileName: '.env');
    developer.log('Environment variables loaded successfully.');
  } catch (e) {
    developer.log(
      'Failed to load .env file. Please ensure a .env file exists. '
      'Falling back to default system values. Error: $e',
      level: 900,
    );
  }

  // Initialize Firebase (Safely wrapped for Phase 0 placeholder verification)
  try {
    // Note: In production, configure this via Firebase CLI (flutterfire configure)
    // which generates firebase_options.dart. For now, we attempt dynamic init
    // and log a warning if it fails.
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY'] ?? 'mock-api-key',
        appId: dotenv.env['FIREBASE_APP_ID_ANDROID'] ?? 'mock-app-id',
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? 'mock-sender-id',
        projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? 'mock-project-id',
      ),
    );
    developer.log('Firebase initialized successfully.');
  } catch (e) {
    developer.log(
      'Firebase initialization failed. If you have not configured Firebase yet, '
      'this is expected for Phase 0. Please refer to the README. Error: $e',
      level: 900,
    );
  }

  runApp(
    const ProviderScope(
      child: UnoriveApp(),
    ),
  );
}
