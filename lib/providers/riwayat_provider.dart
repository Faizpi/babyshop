import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_helper.dart';

class RiwayatProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Map<String, dynamic>> _riwayatList = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get riwayatList => _riwayatList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRiwayat(String warungId, {int limit = 100}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _riwayatList = await _db.getRiwayatWithBarangInfo(warungId, limit: limit);
    } catch (e) {
      _error = 'Gagal memuat riwayat: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<List<Riwayat>> getRiwayatByBarang(String barangId) async {
    try {
      return await _db.getRiwayatByBarang(barangId);
    } catch (e) {
      _error = 'Gagal memuat riwayat barang: $e';
      notifyListeners();
      return [];
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
