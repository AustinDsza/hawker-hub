import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';
import 'auth/login_screen.dart';
import 'user/user_dashboard.dart';
import 'hawker/hawker_dashboard.dart';
import 'admin/admin_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  void _checkAuthAndNavigate() async {
    debugPrint('Splash: Starting auth check');

    // Get the auth provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      // Check auth state
      await authProvider.checkAuthState();
      
      if (!mounted) return;

      final isAuthenticated = authProvider.isAuthenticated;
      debugPrint('Splash: User authenticated: $isAuthenticated');

      if (isAuthenticated && authProvider.user != null) {
        final userRole = authProvider.user!['role'];
        debugPrint('Splash: User role detected: $userRole');
        
        // Navigate based on user role
        switch (userRole) {
          case 'user':
            debugPrint('Splash: Redirecting to user dashboard');
            Navigator.of(context).pushReplacementNamed('/user');
            break;
          case 'hawker':
            debugPrint('Splash: Redirecting to hawker dashboard');
            Navigator.of(context).pushReplacementNamed('/hawker');
            break;
          case 'admin':
            debugPrint('Splash: Redirecting to admin dashboard');
            Navigator.of(context).pushReplacementNamed('/admin');
            break;
          default:
            debugPrint('Splash: Unknown role "$userRole", redirecting to login');
            Navigator.of(context).pushReplacementNamed('/login');
        }
      } else {
        debugPrint('Splash: No authenticated user, redirecting to login');
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      debugPrint('Splash: Error during auth check: $e');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade800,
              Colors.green.shade600,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.store,
                    size: 70,
                    color: Colors.green.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // App Name
              const Text(
                'Hawker Hub',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Connect with local street vendors',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 40),
              // Loading Indicator
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 