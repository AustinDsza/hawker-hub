import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/hawker.dart';
import '../models/location.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseService _supabaseService;
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._supabaseService);

  // Getters
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isAuthenticated => _user != null;

  // Check if user is already logged in
  Future<void> checkAuthState() async {
    try {
      _isLoading = true;
      notifyListeners();

      final userData = await _supabaseService.getCurrentUser();
      _user = userData;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('AuthProvider: Attempting to sign in with email: $email');
      _user = await _supabaseService.signIn(email, password);
      
      if (_user != null) {
        debugPrint('AuthProvider: Sign in successful. User role: ${_user!['role']}');
      } else {
        debugPrint('AuthProvider: Sign in failed - user is null');
      }
      
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      debugPrint('AuthProvider: Sign in error: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign in with phone (for demo purposes - simplified)
  Future<bool> signInWithPhone(String phone) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // In a real app, this would send an OTP to the phone and verify it
      // For this demo app, we'll use hardcoded test accounts
      bool success = false;
      
      // The admin phone number for testing
      if (phone == '+1111111111') {
        success = await signIn('admin@example.com', 'admin123');
      } else {
        _error = 'Phone authentication not fully implemented in demo. Please use email login.';
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign up with email and password
  Future<bool> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
    String role, {
    String? phone,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userData = await _supabaseService.signUp(email, password, name, role, phone: phone);
      if (userData != null) {
        _user = userData;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to create account';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabaseService.signOut();
      _user = null;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Added method to get the current hawker
  Future<Hawker?> getCurrentHawker() async {
    if (_user == null || _user!['role'] != 'hawker') return null;
    
    try {
      final hawkers = await _supabaseService.getNearbyHawkers(const Location(0, 0));
      return hawkers.firstWhere((h) => h.id == _user!['id'], orElse: () => throw Exception('Hawker not found'));
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Add method to check user role
  String? get userRole => _user?['role'];

  // Add method to verify if user is a hawker
  bool get isHawker => _user?['role'] == 'hawker';

  void updateUserData(Map<String, dynamic> data) {
    if (_user != null) {
      _user = {...?_user, ...data};
      notifyListeners();
    }
  }
} 