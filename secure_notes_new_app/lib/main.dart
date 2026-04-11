import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'biometric_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Secure Notes Auth',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final BiometricService _biometricService = BiometricService();
  bool _biometricSupported = false;
  bool _isAuthenticating = false;
  String _statusMessage = 'Checking biometric availability...';

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }

  Future<void> _checkBiometricSupport() async {
    final supported = await _biometricService.isBiometricAvailable();
    final biometrics = await _biometricService.getAvailableBiometrics();
    final hasFingerprint = biometrics.contains(BiometricType.fingerprint);

    if (!mounted) return;

    setState(() {
      _biometricSupported = supported;
      _statusMessage = supported
          ? hasFingerprint
              ? 'Fingerprint authentication is available.'
              : 'Biometric authentication is available.'
          : 'No biometric methods are available on this device.';
    });
  }

  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
      _statusMessage = 'Waiting for biometric authentication...';
    });

    final authenticated = await _biometricService.authenticateBiometricOnly(
      reason: 'Please scan your fingerprint to unlock Secure Notes',
    );

    if (!mounted) return;

    setState(() {
      _isAuthenticating = false;
      _statusMessage = authenticated
          ? 'Authentication successful! Welcome.'
          : 'Authentication failed. Please try again.';
    });

    if (authenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secure Notes Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fingerprint, size: 88, color: Colors.deepPurple),
            const SizedBox(height: 24),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _biometricSupported && !_isAuthenticating ? _authenticate : null,
              icon: const Icon(Icons.lock_open),
              label: Text(
                _isAuthenticating ? 'Authenticating...' : 'Unlock with Biometrics',
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _checkBiometricSupport,
              child: const Text('Retry Availability Check'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secure Notes')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.notes, size: 96, color: Colors.deepPurple),
            SizedBox(height: 24),
            Text(
              'You are authenticated.',
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(height: 12),
            Text('Use this screen as the secure notes home page.'),
          ],
        ),
      ),
    );
  }
}
