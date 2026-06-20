# Unorive — "You Know When to Arrive"

Unorive is a production-grade, location-based alarm mobile application built using Flutter. Instead of scheduling time-based alarms, travelers drop a pin or search for a destination on a 3D Mapbox map, configure an alert radius, and start a trip. Unorive monitors live location in the background and triggers a high-priority, full-volume alarm when they enter the destination radius.

---

## 🛠 Tech Stack

- **Framework**: Flutter (latest stable), Dart
- **State Management**: Riverpod with `riverpod_generator`
- **Routing**: `go_router` (supports deep links from notifications)
- **Map & Search**: Mapbox Maps SDK (`mapbox_maps_flutter`), Mapbox Search Box & Directions APIs
- **Location**: `geolocator`
- **Background Execution**: `flutter_background_service`
- **Alarm Engine**: `alarm` (bypasses silent/DND modes) + `flutter_local_notifications`
- **Persistence**: Hive (offline-first local caches)
- **Cloud Integration**: Firebase (Authentication, Firestore, Crashlytics, Analytics)
- **Theme**: Dark-first custom glassmorphic theme system

---

## 📦 Secrets & Credentials Configuration

Unorive uses `flutter_dotenv` to avoid committing API keys and credentials to the repository.

1. **Copy the environment template**:
   ```bash
   cp .env.example .env
   ```
2. **Fill in your credentials**: Open `.env` and fill in the placeholder values for Mapbox and Firebase.

### 🗺 Mapbox SDK Configuration

Mapbox requires two different tokens:
1. **Public Access Token (`MAPBOX_ACCESS_TOKEN`)**: Used by the map views to authenticate requests. Add this to your `.env` file.
2. **Secret Downloads Token (`MAPBOX_DOWNLOADS_TOKEN`)**: Required to download the Mapbox Maps SDK binary dependencies for Android and iOS.

#### 1. Setup Netrc for SDK Download (macOS/Linux)
Create or edit your `~/.netrc` file:
```env
machine api.mapbox.com
  login mapbox
  password YOUR_MAPBOX_DOWNLOADS_TOKEN
```
Ensure proper permissions:
```bash
chmod 600 ~/.netrc
```

#### 2. Android Configuration
In `android/app/build.gradle.kts` (or global `gradle.properties`), make sure the Mapbox download configuration is reading from netrc or environment properties if necessary.

#### 3. iOS Configuration
In `ios/Runner/Info.plist`, verify that the `MBXAccessToken` key maps to your public token (which we load dynamically or inject).

---

## 🔥 Firebase Setup

Placeholder Firebase initialization is configured dynamically in `lib/main.dart` using values from the `.env` file.

To configure real native configurations for your own Firebase project:
1. Install the Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```
2. Log in and configure the project:
   ```bash
   firebase login
   flutterfire configure
   ```
This generates `lib/firebase_options.dart`, which can be imported directly into `lib/main.dart` to replace the dynamic placeholder configuration.

---

## 🏛 Architecture Note: Manual Hive TypeAdapters

To maintain compatibility with the modern Flutter/Dart Analyzer required by `riverpod_generator` and `mapbox_maps_flutter`, we **do not** use `hive_generator` for code generation. Instead, we write Hive `TypeAdapter` implementations manually.

### How to write a manual TypeAdapter:
1. Define your model (e.g. `Trip` in `lib/data/models/trip.dart`).
2. Create a companion adapter class extending `TypeAdapter<YourModel>`:
   ```dart
   import 'package:hive/hive.dart';
   
   class TripAdapter extends TypeAdapter<Trip> {
     @override
     final int typeId = 0; // Assign a unique ID for each model class
   
     @override
     Trip read(BinaryReader reader) {
       // Read fields in the exact order they are written
       return Trip(
         id: reader.readString(),
         destinationName: reader.readString(),
         latitude: reader.readDouble(),
         longitude: reader.readDouble(),
         radiusMeters: reader.readDouble(),
         status: reader.readString(),
         createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
       );
     }
   
     @override
     void write(BinaryWriter writer, Trip obj) {
       // Write fields in a stable, consistent order
       writer.writeString(obj.id);
       writer.writeString(obj.destinationName);
       writer.writeDouble(obj.latitude);
       writer.writeDouble(obj.longitude);
       writer.writeDouble(obj.radiusMeters);
       writer.writeString(obj.status);
       writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
     }
   }
   ```
3. Register the adapter in `main.dart` before opening Hive boxes:
   ```dart
   Hive.registerAdapter(TripAdapter());
   ```

---

## 🚀 Running the App

### 1. Generate Riverpod Providers
Unorive uses Riverpod generator. Run the build runner to generate provider classes:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
Or run in watch mode during development:
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

### 2. Launch Local Dev Server / Devices
Ensure you have an Android emulator or iOS simulator running:
```bash
# List available devices
flutter devices

# Run on the active device
flutter run
```

---

## 🧪 Testing

Unorive utilizes unit and widget tests to verify logic correctness.

- **Run all unit/widget tests**:
  ```bash
  flutter test
  ```
- **Check static analysis / linter**:
  ```bash
  flutter analyze
  ```
# Unorive-App
