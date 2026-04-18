import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeAuthState();
  }

  Future<void> _checkBiometrics() async {
    final canCheck = await _biometricService.canCheckBiometrics();
    setState(() => _isBiometricSupported = canCheck);
    if (canCheck) {
      _authenticateWithBiometrics();
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    final navigator = Navigator.of(context);
    final authenticated = await _biometricService.authenticate();
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

  void _setupPin() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set PIN'),
        content: TextField(
          controller: _pinController,
          obscureText: true,
          decoration: InputDecoration(labelText: 'Enter 4-6 digit PIN'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(this.context);
              final hash = sha256
                  .convert(utf8.encode(_pinController.text))
                  .toString();
              await SecureStorageService.savePinHash(hash);
              if (!mounted) return;
              navigator.pop();
              _verifyPin();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isBiometricSupported) ...[
              ElevatedButton.icon(
                onPressed: _authenticateWithBiometrics,
                icon: Icon(Icons.fingerprint),
                label: Text('Unlock with Biometrics'),
              ),
              SizedBox(height: 20),
              Text('OR'),
            ],
            SizedBox(height: 20),
            TextField(
              controller: _pinController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Enter PIN'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyPin,
              child: Text('Unlock with PIN'),
            ),
          ],
        ),
      ),
    );
  }
}
