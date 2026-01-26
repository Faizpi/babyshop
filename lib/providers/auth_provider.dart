import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService.instance;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get error => _error;

  AuthProvider() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  Future<void> checkAuthStatus() async {
    _currentUser = _authService.currentUser;
    notifyListeners();
  }

  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authService.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );

    _isLoading = false;
    if (!result.isSuccess) {
      _error = result.errorMessage;
    }
    notifyListeners();

    return result;
  }

  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    _isLoading = false;
    if (!result.isSuccess) {
      _error = result.errorMessage;
    }
    notifyListeners();

    return result;
  }

  Future<AuthResult> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authService.signInWithGoogle();

    _isLoading = false;
    if (!result.isSuccess) {
      _error = result.errorMessage;
    }
    notifyListeners();

    return result;
  }

  Future<void> signInWithPhone({
    required String phoneNumber,
    required Function(String, int?) onCodeSent,
    required Function(String) onError,
    required Function(User) onAutoVerified,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _authService.signInWithPhone(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId, resendToken) {
        _isLoading = false;
        notifyListeners();
        onCodeSent(verificationId, resendToken);
      },
      onError: (error) {
        _isLoading = false;
        _error = error;
        notifyListeners();
        onError(error);
      },
      onAutoVerified: (user) {
        _isLoading = false;
        _currentUser = user;
        notifyListeners();
        onAutoVerified(user);
      },
    );
  }

  Future<AuthResult> verifyOTP({
    required String verificationId,
    required String otp,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authService.verifyOTP(
      verificationId: verificationId,
      otp: otp,
    );

    _isLoading = false;
    if (!result.isSuccess) {
      _error = result.errorMessage;
    }
    notifyListeners();

    return result;
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    await _authService.signOut();
    _currentUser = null;

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
