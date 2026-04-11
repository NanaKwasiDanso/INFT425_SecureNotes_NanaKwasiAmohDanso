import 'package:flutter/material.dart';
import '../services/biometric_service.dart';
import '../services/secure_storage_service.dart';
import 'notes_list_screen.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final BiometricService _biometricService = BiometricService();
  final TextEditingController _pinController = TextEditingController();
  bool _isBiometricSupported = false;
  bool _hasExistingPin = false;
  bool _hasEnrolledBiometric = false;

  @override
  void initState() {
    super.initState();
    _initializeAuthState();
  }

  Future<void> _initializeAuthState() async {
    final hasBiometricSupport = await _biometricService.isBiometricAvailable();
    final hasEnrolledBiometric = await _biometricService
        .hasEnrolledFingerprint();
    final storedHash = await SecureStorageService.loadPinHash();

    if (!mounted) return;
    setState(() {
      _isBiometricSupported = hasBiometricSupport;
      _hasEnrolledBiometric = hasEnrolledBiometric;
      _hasExistingPin = storedHash != null;
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final authenticated = await _biometricService.authenticateWithFingerprint(
      reason: 'Use your biometric credential to unlock secure notes',
    );
    if (!mounted) return;

    if (authenticated) {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const NotesListScreen()),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Biometric authentication failed. Please try again or use PIN.',
          ),
        ),
      );
    }
  }

  Future<void> _handlePrimaryAction() async {
    if (_hasExistingPin) {
      await _verifyPin();
    } else {
      await _signUp();
    }
  }

  Future<void> _verifyPin() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final storedHash = await SecureStorageService.loadPinHash();
    if (!mounted) return;

    if (storedHash == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please complete sign up first.')),
      );
      return;
    }

    final inputHash = sha256
        .convert(utf8.encode(_pinController.text))
        .toString();
    if (inputHash == storedHash) {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const NotesListScreen()),
      );
    } else {
      messenger.showSnackBar(const SnackBar(content: Text('Wrong PIN')));
    }
  }

  Future<void> _signUp() async {
    final messenger = ScaffoldMessenger.of(context);
    final pin = _pinController.text.trim();

    if (pin.length < 4 || pin.length > 6 || int.tryParse(pin) == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Enter a valid 4-6 digit PIN')),
      );
      return;
    }

    if (_isBiometricSupported && !_hasEnrolledBiometric) {
      await _showEnrollFingerprintDialog();
      return;
    }

    bool authenticated = true;
    if (_isBiometricSupported) {
      authenticated = await _biometricService.authenticateWithFingerprint(
        reason: 'Use your biometric credential to complete sign-up',
      );
    }

    if (!mounted) return;

    if (!authenticated) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Authentication failed. Please try again or enroll your biometric credential and then complete sign-up.',
          ),
        ),
      );
      return;
    }

    final hash = sha256.convert(utf8.encode(pin)).toString();
    await SecureStorageService.savePinHash(hash);

    if (!mounted) return;

    setState(() {
      _hasExistingPin = true;
    });

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const NotesListScreen()),
    );
  }

  Future<void> _showEnrollFingerprintDialog() async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enroll Biometric Credential'),
          content: const Text(
            'Biometric support is available on this device, but no biometric credential is enrolled yet. '
            'Please enroll a fingerprint or face credential in your device security settings and then complete sign-up.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2A2C6F), Color(0xFF6D3EC1), Color(0xFFCB4EFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              left: -60,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color.fromRGBO(255, 255, 255, 0.16),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: const SizedBox(width: 220, height: 220),
              ),
            ),
            Positioned(
              bottom: -100,
              right: -50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color.fromRGBO(255, 193, 7, 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: const SizedBox(width: 260, height: 260),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Secure Notes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _hasExistingPin
                          ? 'Enter your PIN or use your biometric credential to unlock.'
                          : _isBiometricSupported && !_hasEnrolledBiometric
                          ? 'Enroll your biometric credential and create a PIN to secure your notes.'
                          : 'Create a PIN and use your biometric scanner to sign up.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 36),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(255, 255, 255, 0.14),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white24),
                        boxShadow: [
                          const BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.2),
                            blurRadius: 24,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _hasExistingPin
                                ? _authenticateWithBiometrics
                                : _signUp,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.deepPurpleAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.fingerprint, size: 24),
                            label: Text(
                              _hasExistingPin
                                  ? 'Unlock with Biometric'
                                  : _isBiometricSupported &&
                                        !_hasEnrolledBiometric
                                  ? 'Enroll biometric credential & sign up'
                                  : 'Sign Up with Biometric',
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Center(
                            child: Text(
                              'OR',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_isBiometricSupported &&
                              !_hasEnrolledBiometric) ...[
                            const Text(
                              'Biometric support is available, but no biometric credential is enrolled yet. '
                              'Please enroll a fingerprint or face credential in device settings before completing sign-up.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 20),
                          ],
                          if (!_isBiometricSupported) ...[
                            const Text(
                              'Biometric support was not detected, but you can still try authentication. If it fails, use PIN.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 20),
                          ],
                          TextField(
                            controller: _pinController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: _hasExistingPin
                                  ? 'Enter PIN'
                                  : 'Create PIN',
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              filled: true,
                              fillColor: const Color.fromRGBO(
                                255,
                                255,
                                255,
                                0.08,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            cursorColor: Colors.white,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _handlePrimaryAction,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: Colors.amberAccent.shade700,
                              foregroundColor: Colors.black87,
                            ),
                            child: Text(
                              _hasExistingPin
                                  ? 'Unlock with PIN'
                                  : 'Complete Sign Up',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Choose a bold and colorful wallpaper style for the app after login.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
