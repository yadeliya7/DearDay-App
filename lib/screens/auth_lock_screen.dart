import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'package:poem_diary/l10n/app_localizations.dart';

class AuthLockScreen extends StatefulWidget {
  const AuthLockScreen({super.key});

  @override
  State<AuthLockScreen> createState() => _AuthLockScreenState();
}

class _AuthLockScreenState extends State<AuthLockScreen> {
  final AuthService _authService = AuthService();
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    // Trigger authentication immediately when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    try {
      final localizations = AppLocalizations.of(context)!;
      final authenticated = await _authService.authenticate(
        localizedReason: localizations.authenticationRequired,
      );

      if (authenticated) {
        // Authentication successful, return success
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        // Authentication failed
        if (mounted) {
          setState(() {
            _isAuthenticating = false;
          });
        }
      }
    } catch (e) {
      // Error during authentication
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false, // Prevent back button
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lock Icon
                Icon(
                  Icons.lock_outline,
                  size: 100,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'DearDay',
                  style: GoogleFonts.dancingScript(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  localizations.authenticationRequired,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 48),

                // Authenticate Button
                if (!_isAuthenticating)
                  ElevatedButton.icon(
                    onPressed: _authenticate,
                    icon: const Icon(Icons.fingerprint),
                    label: Text(
                      localizations.authenticationRequired,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  )
                else
                  CircularProgressIndicator(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),

                const SizedBox(height: 24),

                // Exit App Button
                TextButton(
                  onPressed: () {
                    // Exit the app
                    SystemNavigator.pop();
                  },
                  child: Text(
                    'Çıkış',
                    style: GoogleFonts.poppins(color: Colors.red, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
