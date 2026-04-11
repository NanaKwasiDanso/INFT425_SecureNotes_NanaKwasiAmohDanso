import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

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

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Error fetching available biometrics: $e');
      return <BiometricType>[];
    }
  }

  Future<bool> authenticateBiometricOnly({
    String reason = 'Please authenticate to continue',
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
      debugPrint('Biometric authentication error: $e');
      return false;
    }
  }
}
