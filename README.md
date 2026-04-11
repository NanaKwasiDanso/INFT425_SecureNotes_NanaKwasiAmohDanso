# Secure Notes

Secure Notes is a Flutter application for storing encrypted notes and unlocking access with a PIN or biometric authentication. The app uses the device security system to protect sensitive content and stores encrypted data locally using secure storage.

## Features

- PIN-based authentication with secure hashing
- Biometric authentication support (fingerprint / face / iris)
- Encrypted note storage using `flutter_secure_storage`
- Styled authentication flow with onboarding for biometric enrollment
- Compatible with Android and iOS biometric APIs

## App Workflow

1. On first launch, the user creates a 4-6 digit PIN.
2. If biometric hardware is supported, the app prompts biometric enrollment.
3. Notes are encrypted and stored locally.
4. Returning users can unlock the app with a saved PIN or biometrics.

## Key Packages

- `local_auth` - device biometric authentication
- `flutter_secure_storage` - local encrypted storage
- `crypto` - SHA-256 hashing for PIN storage
- `encrypt` - general encryption utilities used for note protection
- `flutter_native_splash` - launch screen setup
- `flutter_launcher_icons` - app icon generation

## Getting Started

### Prerequisites

- Flutter SDK installed
- Android Studio / Xcode setup for mobile development
- A real device or emulator with biometric support for biometric testing

### Run the App

```bash
flutter pub get
flutter run
```

### Build Release

```bash
flutter build apk
flutter build ios
```

## Project Structure

- `lib/main.dart` - app entry point
- `lib/screens/auth_screen.dart` - authentication UI and logic
- `lib/screens/notes_list_screen.dart` - notes list display and navigation
- `lib/services/biometric_service.dart` - biometric availability and authentication wrapper
- `lib/services/secure_storage_service.dart` - secure storage helper methods
- `lib/services/notes_service.dart` - note encryption and persistence
- `lib/models/note.dart` - note data model
- `lib/utils/encryption_helper.dart` - encryption utilities
- `lib/widgets/biometric_auth_example.dart` - biometric auth widget example

## Android Permissions

This app adds support for biometric authentication in Android by declaring:

- `android.permission.USE_BIOMETRIC`
- `android.permission.USE_FINGERPRINT`

These permissions are configured in `android/app/src/main/AndroidManifest.xml`.

## Notes

- PINs are hashed using SHA-256 before storage.
- The app does not ship sensitive notes to a server; all storage is local.
- Biometric support requires the device to have an enrolled fingerprint/face/iris credential.

## Contact

For questions or improvements, update this README with additional usage instructions or developer notes.
