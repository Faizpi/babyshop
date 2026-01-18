import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_helper.dart';
import 'package:uuid/uuid.dart';

class WarungProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  List<Warung> _warungList = [];
  Warung? _selectedWarung;
  bool _isLoading = false;
  String? _error;

  List<Warung> get warungList => _warungList;
  Warung? get selectedWarung => _selectedWarung;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasWarung => _warungList.isNotEmpty;

  Future<void> loadWarungList() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _warungList = await _db.getAllWarung();

      // Load last selected warung
      final lastWarungId = await _db.getSetting('last_warung_id');
      if (lastWarungId != null && _warungList.isNotEmpty) {
        _selectedWarung = _warungList.firstWhere(
          (w) => w.id == lastWarungId,
          orElse: () => _warungList.first,
        );
      } else if (_warungList.isNotEmpty) {
        _selectedWarung = _warungList.first;
      }
    } catch (e) {
      _error = 'Gagal memuat daftar warung: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addWarung(
    String nama, {
    String? alamat,
    String? fotoPath,
  }) async {
    try {
      final now = DateTime.now();
      final warung = Warung(
        id: _uuid.v4(),
        nama: nama,
        alamat: alamat,
        fotoPath: fotoPath,
        createdAt: now,
        updatedAt: now,
      );

      await _db.insertWarung(warung);
      _warungList.add(warung);

      // Auto-select if first warung
      if (_selectedWarung == null) {
        _selectedWarung = warung;
        await _db.setSetting('last_warung_id', warung.id);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal menambah warung: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateWarung(Warung warung) async {
    try {
      final updated = warung.copyWith(updatedAt: DateTime.now());
      await _db.updateWarung(updated);

      final index = _warungList.indexWhere((w) => w.id == warung.id);
      if (index >= 0) {
        _warungList[index] = updated;
      }

      if (_selectedWarung?.id == warung.id) {
        _selectedWarung = updated;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal mengupdate warung: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteWarung(String id) async {
    try {
      await _db.deleteWarung(id);
      _warungList.removeWhere((w) => w.id == id);

      if (_selectedWarung?.id == id) {
        _selectedWarung = _warungList.isNotEmpty ? _warungList.first : null;
        if (_selectedWarung != null) {
          await _db.setSetting('last_warung_id', _selectedWarung!.id);
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal menghapus warung: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> selectWarung(Warung warung) async {
    _selectedWarung = warung;
    await _db.setSetting('last_warung_id', warung.id);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
