import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_helper.dart';
import 'package:uuid/uuid.dart';

class UserProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  User? _currentUser;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get error => _error;

  Future<void> checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _db.getUser();
      _isLoggedIn = _currentUser != null;
    } catch (e) {
      _error = 'Gagal memeriksa status login: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createUser(String nama, {String? pin, String? fotoPath}) async {
    try {
      final now = DateTime.now();
      final user = User(
        id: _uuid.v4(),
        nama: nama,
        pin: pin,
        fotoPath: fotoPath,
        createdAt: now,
        lastLogin: now,
      );

      await _db.insertUser(user);
      _currentUser = user;
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal membuat user: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String? pin) async {
    if (_currentUser == null) return false;

    // If user has PIN, verify it
    if (_currentUser!.pin != null && _currentUser!.pin!.isNotEmpty) {
      if (pin != _currentUser!.pin) {
        _error = 'PIN salah';
        notifyListeners();
        return false;
      }
    }

    // Update last login
    final updated = _currentUser!.copyWith(lastLogin: DateTime.now());
    await _db.updateUser(updated);
    _currentUser = updated;
    _isLoggedIn = true;
    notifyListeners();
    return true;
  }

  Future<bool> updateUser(User user) async {
    try {
      await _db.updateUser(user);
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal mengupdate user: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePin(String? newPin) async {
    if (_currentUser == null) return false;

    try {
      final updated = _currentUser!.copyWith(pin: newPin);
      await _db.updateUser(updated);
      _currentUser = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal mengubah PIN: $e';
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
