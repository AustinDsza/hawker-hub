import 'package:flutter/material.dart';
import 'package:hawker_hub/screens/auth/login_screen.dart';
import 'package:hawker_hub/screens/auth/signup_screen.dart';
import 'package:hawker_hub/screens/splash_screen.dart';
import 'package:hawker_hub/screens/user/user_dashboard.dart';
import 'package:hawker_hub/screens/hawker/hawker_dashboard.dart';
import 'package:hawker_hub/screens/admin/admin_dashboard.dart';
import 'sample_data_loader.dart';

class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String userDashboard = '/user';
  static const String hawkerDashboard = '/hawker';
  static const String adminDashboard = '/admin';
  static const String supabaseTest = '/supabase_test';

  static Map<String, WidgetBuilder> getRoutes() {
    print('Initializing routes. Available routes:');
    print('- User dashboard: $userDashboard');
    print('- Hawker dashboard: $hawkerDashboard');
    print('- Admin dashboard: $adminDashboard');
    print('- Supabase test: $supabaseTest');
    
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      signup: (context) => const SignupScreen(),
      userDashboard: (context) => const UserDashboard(),
      hawkerDashboard: (context) => const HawkerDashboard(),
      adminDashboard: (context) => const AdminDashboard(),
      supabaseTest: (context) => const SampleDataLoader(),
    };
  }
} 