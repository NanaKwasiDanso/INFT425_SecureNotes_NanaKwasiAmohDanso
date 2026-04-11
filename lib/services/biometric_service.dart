import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _isSupportedBiometricType(BiometricType type) {
    return type == BiometricType.fingerprint ||
        type == BiometricType.face ||
        type == BiometricType.iris ||
        type == BiometricType.strong ||
        type == BiometricType.weak;
  }

  /// Check whether any biometric mechanism is available on the device.
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool deviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics || deviceSupported;
    } catch (e) {
      debugPrint('Biometric availability error: $e');
      return false;
    }
  }

  /// Check whether a fingerprint or other biometric is supported.
  Future<bool> isFingerprintSupported() async {
    try {
      final List<BiometricType> availableBiometrics = await _localAuth
          .getAvailableBiometrics();
      return availableBiometrics.any(_isSupportedBiometricType);
    } catch (e) {
      debugPrint('Error checking fingerprint availability: $e');
      return false;
    }
  }

  /// Get available biometric types.
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Check whether any biometric identity is enrolled on the device.
  Future<bool> hasEnrolledFingerprint() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.any(_isSupportedBiometricType);
    } catch (e) {
      debugPrint('Error checking enrolled fingerprint: $e');
      return false;
    }
  }

  /// Authenticate user with the available biometric mechanism.
  Future<bool> authenticateWithFingerprint({
    String reason = 'Please authenticate using your fingerprint',
  }) async {
    try {
      if (!await isBiometricAvailable()) {
        return false;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: false,
          useErrorDialogs: true,
        ),
      );

      return didAuthenticate;
    } catch (e) {
      debugPrint('Error during fingerprint authentication: $e');
      return false;
    }
  }

  /// Get descriptions for the available biometric types.
  List<String> getBiometricTypeDescriptions(List<BiometricType> types) {
    return types.where(_isSupportedBiometricType).map((type) {
      switch (type) {
        case BiometricType.fingerprint:
          return 'Fingerprint';
        case BiometricType.face:
          return 'Face';
        case BiometricType.iris:
          return 'Iris';
        case BiometricType.strong:
        case BiometricType.weak:
          return 'Biometric';
      }
    }).toList();
  }
}
