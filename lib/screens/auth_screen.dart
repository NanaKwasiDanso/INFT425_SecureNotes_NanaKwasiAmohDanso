import 'dart:ui';
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

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final BiometricService _biometricService = BiometricService();
  final TextEditingController _pinController = TextEditingController();
  bool _isBiometricSupported = false;
  bool _hasExistingPin = false;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _initializeAuthState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _initializeAuthState() async {
    final hasBiometrics = await _biometricService.isBiometricAvailable();
    final storedHash = await SecureStorageService.loadPinHash();

    if (!mounted) return;
    setState(() {
      _isBiometricSupported = hasBiometrics;
      _hasExistingPin = storedHash != null;
      _isLoading = false;
    });
    _animationController.forward();
  }

  Future<void> _authenticateWithBiometrics() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final authenticated = await _biometricService.authenticate(
      reason: 'Use your device biometric sensor to unlock secure notes',
    );
    
    if (!mounted) return;

    if (authenticated) {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const NotesListScreen()),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Biometric authentication failed. Please try again or use PIN.'),
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
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
        SnackBar(
          content: const Text('Please complete sign up first.'),
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final inputHash = sha256.convert(utf8.encode(_pinController.text)).toString();
    if (inputHash == storedHash) {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const NotesListScreen()),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Incorrect PIN. Please try again.'),
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _signUp() async {
    final messenger = ScaffoldMessenger.of(context);
    final pin = _pinController.text.trim();

    if (pin.length < 4 || pin.length > 6 || int.tryParse(pin) == null) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid 4-6 digit PIN.'),
          backgroundColor: Colors.orangeAccent.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    bool authenticated = true;
    if (_isBiometricSupported) {
      authenticated = await _biometricService.authenticate(
        reason: 'Use your biometric credential to complete sign-up',
      );
    }

    if (!mounted) return;

    if (!authenticated) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Authentication failed. Please try again.'),
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0C29),
        body: Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F0C29), // Deep space
              Color(0xFF302B63), // Purple twilight
              Color(0xFF24243E), // Dark slate
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Abstract background elements
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.cyanAccent.withOpacity(0.15),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.purpleAccent.withOpacity(0.15),
                ),
              ),
            ),
            // Glassmorphism Blur
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(color: Colors.transparent),
              ),
            ),
            // Main Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon/Logo
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.lock_outline_rounded,
                            size: 64,
                            color: Colors.cyanAccent,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Title
                        Text(
                          _hasExistingPin ? 'Welcome Back' : 'Secure Setup',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _hasExistingPin
                              ? 'Enter your PIN or use biometrics to unlock your vault.'
                              : 'Create a secure PIN to protect your private notes.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.7),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 48),
                        // Glassmorphism Card
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 5,
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                controller: _pinController,
                                obscureText: true,
                                obscuringCharacter: '●',
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  letterSpacing: 8,
                                ),
                                decoration: InputDecoration(
                                  hintText: _hasExistingPin ? 'PIN' : '4-6 Digits',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.3),
                                    fontSize: 18,
                                    letterSpacing: 2,
                                  ),
                                  filled: true,
                                  fillColor: Colors.black.withOpacity(0.2),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _handlePrimaryAction,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  backgroundColor: Colors.cyanAccent.shade400,
                                  foregroundColor: Colors.black87,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  _hasExistingPin ? 'UNLOCK' : 'SET PIN & CONTINUE',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              if (_isBiometricSupported) ...[
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        'OR',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                OutlinedButton.icon(
                                  onPressed: _authenticateWithBiometrics,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    side: BorderSide(
                                      color: Colors.purpleAccent.withOpacity(0.5),
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.fingerprint_rounded,
                                    color: Colors.purpleAccent.shade100,
                                    size: 28,
                                  ),
                                  label: Text(
                                    _hasExistingPin
                                        ? 'USE BIOMETRICS'
                                        : 'ENROLL BIOMETRICS',
                                    style: TextStyle(
                                      color: Colors.purpleAccent.shade100,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
