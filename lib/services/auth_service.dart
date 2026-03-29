import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Check if the device supports biometric authentication
  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  /// Check if the device is supported (has secure lock screen)
  Future<bool> isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  /// Check if biometrics are available (device has biometrics enrolled)
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await canCheckBiometrics();
      if (!canCheck) return false;

      final availableBiometrics = await _auth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  /// Authenticate using biometrics or device credentials
  Future<bool> authenticate({required String localizedReason}) async {
    try {
      final canAuthenticate = await isBiometricAvailable();
      if (!canAuthenticate) {
        // If biometrics not available, still try (will fall back to PIN/password)
      }

      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow PIN/password fallback
          useErrorDialogs: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}
