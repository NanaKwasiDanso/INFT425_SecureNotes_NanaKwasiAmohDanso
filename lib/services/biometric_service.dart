import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if biometric authentication is available on the device
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      return canAuthenticate;
    } catch (e) {
      debugPrint('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final List<BiometricType> availableBiometrics = await _localAuth
          .getAvailableBiometrics();
      return availableBiometrics;
    } catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Authenticate user with biometrics
  Future<bool> authenticate({
    String reason = 'Please authenticate to access your secure notes',
    bool biometricOnly = false,
  }) async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      return didAuthenticate;
    } catch (e) {
      debugPrint('Error during biometric authentication: $e');
      return false;
    }
  }

  /// Authenticate with biometrics only (no fallback to PIN/pattern)
  Future<bool> authenticateBiometricOnly({
    String reason = 'Please authenticate using biometrics',
  }) async {
    return await authenticate(reason: reason, biometricOnly: true);
  }

  /// Check if device supports biometric authentication
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      debugPrint('Error checking device support: $e');
      return false;
    }
  }

  /// Get biometric type descriptions for UI display
  List<String> getBiometricTypeDescriptions(List<BiometricType> types) {
    return types.map((type) {
      switch (type) {
        case BiometricType.face:
          return 'Face recognition';
        case BiometricType.fingerprint:
          return 'Fingerprint';
        case BiometricType.iris:
          return 'Iris scan';
        case BiometricType.strong:
          return 'Strong biometric';
        case BiometricType.weak:
          return 'Weak biometric';
      }
    }).toList();
  }
}
