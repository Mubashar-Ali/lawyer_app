import 'package:flutter/material.dart';
import '../models/user.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  authenticating,
  error,
}

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _token;
  String? _errorMessage;
  bool _isLawyer = true; // Default to lawyer mode

  AuthStatus get status => _status;
  User? get user => _user;
  String? get token => _token;
  String? get errorMessage => _errorMessage;
  bool get isLawyer => _isLawyer;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // For demo purposes, we'll use dummy data
  Future<bool> login(String email, String password, {bool isLawyer = true}) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // For demo, accept any email/password with basic validation
      if (email.isEmpty || !email.contains('@') || password.isEmpty) {
        _status = AuthStatus.error;
        _errorMessage = 'Invalid email or password';
        notifyListeners();
        return false;
      }

      // Set user based on role
      _isLawyer = isLawyer;
      
      if (isLawyer) {
        _user = User(
          id: '1',
          name: 'James Wilson',
          email: email,
          phone: '(555) 123-4567',
          role: 'lawyer',
          profileImage: 'https://randomuser.me/api/portraits/men/32.jpg',
        );
      } else {
        _user = User(
          id: '2',
          name: 'Robert Smith',
          email: email,
          phone: '(555) 987-6543',
          role: 'client',
          profileImage: 'https://randomuser.me/api/portraits/men/45.jpg',
        );
      }
      
      _token = 'dummy_token_${DateTime.now().millisecondsSinceEpoch}';
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, {bool isLawyer = true}) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Basic validation
      if (name.isEmpty || email.isEmpty || !email.contains('@') || password.length < 6) {
        _status = AuthStatus.error;
        _errorMessage = 'Please provide valid information';
        notifyListeners();
        return false;
      }

      // Set user based on role
      _isLawyer = isLawyer;
      
      if (isLawyer) {
        _user = User(
          id: '1',
          name: name,
          email: email,
          phone: '(555) 123-4567',
          role: 'lawyer',
          profileImage: 'https://randomuser.me/api/portraits/men/32.jpg',
        );
      } else {
        _user = User(
          id: '2',
          name: name,
          email: email,
          phone: '(555) 987-6543',
          role: 'client',
          profileImage: 'https://randomuser.me/api/portraits/men/45.jpg',
        );
      }
      
      _token = 'dummy_token_${DateTime.now().millisecondsSinceEpoch}';
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Basic validation
      if (email.isEmpty || !email.contains('@')) {
        _errorMessage = 'Please provide a valid email';
        notifyListeners();
        return false;
      }

      // In a real app, this would send a password reset email
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    
    _status = AuthStatus.unauthenticated;
    _user = null;
    _token = null;
    notifyListeners();
  }

  void switchToLawyerMode() {
    if (!_isLawyer) {
      _isLawyer = true;
      _user = User(
        id: '1',
        name: 'James Wilson',
        email: 'james.wilson@example.com',
        phone: '(555) 123-4567',
        role: 'lawyer',
        profileImage: 'https://randomuser.me/api/portraits/men/32.jpg',
      );
      notifyListeners();
    }
  }

  void switchToClientMode() {
    if (_isLawyer) {
      _isLawyer = false;
      _user = User(
        id: '2',
        name: 'Robert Smith',
        email: 'robert.smith@example.com',
        phone: '(555) 987-6543',
        role: 'client',
        profileImage: 'https://randomuser.me/api/portraits/men/45.jpg',
      );
      notifyListeners();
    }
  }

  // Check if user is already logged in (from storage in a real app)
  Future<void> checkAuthStatus() async {
    // Simulate checking stored credentials
    await Future.delayed(const Duration(seconds: 1));
    
    // For demo purposes, default to unauthenticated
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
