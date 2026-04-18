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

  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      debugPrint('Biometric availability error: $e');
      return false;
    }
  }

  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      debugPrint('Error checking device support: $e');
      return false;
    }
  }

  Future<bool> isBiometricAvailable() async {
    final bool canCheck = await canCheckBiometrics();
    final bool deviceSupported = await isDeviceSupported();
    return canCheck || deviceSupported;
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return [];
    }
  }

  Future<bool> hasEnrolledFingerprint() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.any(_isSupportedBiometricType);
    } catch (e) {
      debugPrint('Error checking enrolled fingerprint: $e');
      return false;
    }
  }

  Future<bool> authenticate({
    String reason = 'Please authenticate to access your secure notes',
    bool biometricOnly = false,
  }) async {
    try {
      if (!await isBiometricAvailable()) {
        return false;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
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

  Future<bool> authenticateWithAnyBiometric({
    String reason = 'Please authenticate using your device biometric sensor',
  }) async {
    return await authenticate(reason: reason, biometricOnly: false);
  }

  Future<bool> authenticateWithFingerprint({
    String reason = 'Please authenticate using your fingerprint',
  }) async {
    return await authenticate(reason: reason, biometricOnly: true);
  }

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
