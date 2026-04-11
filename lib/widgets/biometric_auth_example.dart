import 'package:flutter/material.dart';
import 'package:secure_notes/services/biometric_service.dart';

class BiometricAuthScreen extends StatefulWidget {
  const BiometricAuthScreen({super.key});

  @override
  State<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen> {
  final BiometricService _biometricService = BiometricService();
  bool _isAuthenticated = false;
  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final isAvailable = await _biometricService.isBiometricAvailable();
    if (!mounted) return;

    setState(() {
      _isBiometricAvailable = isAvailable;
    });
  }

  Future<void> _authenticate() async {
    final authenticated = await _biometricService.authenticateWithFingerprint(
      reason: 'Authenticate to access your secure notes',
    );

    if (!mounted) return; // Check if widget is still mounted

    setState(() {
      _isAuthenticated = authenticated;
    });

    if (authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication successful!')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Authentication failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biometric Authentication')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isAuthenticated ? Icons.lock_open : Icons.lock,
              size: 80,
              color: _isAuthenticated ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              _isAuthenticated ? 'Authenticated' : 'Not Authenticated',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 40),
            if (_isBiometricAvailable) ...[
              const Text('Biometric authentication is available.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _authenticate,
                child: const Text('Authenticate with Biometrics'),
              ),
            ] else ...[
              const Text('Biometric authentication not available'),
            ],
          ],
        ),
      ),
    );
  }
}

// Usage example in your app:
// In your main.dart or wherever you need authentication:
//
// import 'package:your_app/services/biometric_service.dart';
//
// final biometricService = BiometricService();
//
// // Check if biometric support is available
// bool available = await biometricService.isBiometricAvailable();
//
// // Authenticate user with biometrics
// bool authenticated = await biometricService.authenticateWithFingerprint(
//   reason: 'Please authenticate to continue',
// );
//
// if (authenticated) {
//   // Proceed with authenticated flow
// }
