import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';
import '../navigation/main_navigation_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _loadedPreferences = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          if (!_loadedPreferences) {
            _loadedPreferences = true;

            Future.microtask(() {
              Provider.of<ThemeProvider>(
                context,
                listen: false,
              ).loadUserPreferences();
            });
          }

          return const MainNavigationScreen();
        }

        _loadedPreferences = false;

        return const LoginScreen();
      },
    );
  }
}
