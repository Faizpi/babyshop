import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';
import 'package:uuid/uuid.dart';

class BarangProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final NotificationService _notif = NotificationService.instance;
  final Uuid _uuid = const Uuid();

  List<Barang> _barangList = [];
  List<Barang> _filteredList = [];
  List<Kategori> _kategoriList = [];
  String? _selectedKategoriId;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _stats = {};

  List<Barang> get barangList => _filteredList;
  List<Barang> get allBarangList => _barangList;
  List<Kategori> get kategoriList => _kategoriList;
  String? get selectedKategoriId => _selectedKategoriId;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get stats => _stats;

  List<Barang> get barangStokMenipis =>
      _barangList.where((b) => b.isStokMenipis).toList();

  int get jumlahStokMenipis => barangStokMenipis.length;

  Future<void> loadKategori() async {
    try {
      _kategoriList = await _db.getAllKategori();
      notifyListeners();
    } catch (e) {
      _error = 'Gagal memuat kategori: $e';
      notifyListeners();
    }
  }

  Future<void> loadBarang(String warungId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _barangList = await _db.getAllBarang(warungId);
      _stats = await _db.getWarungStats(warungId);
      _applyFilter();

      // Check for low stock items and notify
      await _checkLowStock();
    } catch (e) {
      _error = 'Gagal memuat daftar barang: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void _applyFilter() {
    _filteredList = _barangList.where((barang) {
      // Filter by category
      if (_selectedKategoriId != null &&
          barang.kategoriId != _selectedKategoriId) {
        return false;
      }

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        return barang.nama.toLowerCase().contains(_searchQuery.toLowerCase());
      }

      return true;
    }).toList();
  }

  void setKategoriFilter(String? kategoriId) {
    _selectedKategoriId = kategoriId;
    _applyFilter();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void clearFilters() {
    _selectedKategoriId = null;
    _searchQuery = '';
    _applyFilter();
    notifyListeners();
  }

  Future<bool> addBarang({
    required String warungId,
    required String kategoriId,
    required String nama,
    required String fotoPath,
    int stok = 0,
    int stokMinimum = 5,
    int harga = 0,
    String? deskripsi,
    String satuan = 'pcs',
  }) async {
    try {
      final now = DateTime.now();
      final barang = Barang(
        id: _uuid.v4(),
        warungId: warungId,
        kategoriId: kategoriId,
        nama: nama,
        fotoPath: fotoPath,
        stok: stok,
        stokMinimum: stokMinimum,
        harga: harga,
        deskripsi: deskripsi,
        satuan: satuan,
        createdAt: now,
        updatedAt: now,
      );

      await _db.insertBarang(barang);

      // Add to riwayat
      await _addRiwayat(
        barangId: barang.id,
        warungId: warungId,
        tipe: TipeRiwayat.tambahBarang,
        nilaiBaru: stok,
        catatan: 'Barang baru ditambahkan',
      );

      _barangList.add(barang);
      _stats = await _db.getWarungStats(warungId);
      _applyFilter();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal menambah barang: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBarang(Barang barang) async {
    try {
      final updated = barang.copyWith(
        updatedAt: DateTime.now(),
        needsSync: true,
      );
      await _db.updateBarang(updated);

      final index = _barangList.indexWhere((b) => b.id == barang.id);
      if (index >= 0) {
        _barangList[index] = updated;
      }

      _stats = await _db.getWarungStats(barang.warungId);
      _applyFilter();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal mengupdate barang: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStok(
    Barang barang,
    int delta, {
    String? catatan,
    bool isAudit = false,
  }) async {
    try {
      final stokLama = barang.stok;
      final stokBaru = (barang.stok + delta).clamp(0, 999999);

      await _db.updateStok(barang.id, stokBaru);

      // Determine history type
      TipeRiwayat tipe;
      if (isAudit) {
        tipe = TipeRiwayat.auditStok;
      } else if (delta > 0) {
        tipe = TipeRiwayat.tambahStok;
      } else {
        tipe = TipeRiwayat.kurangStok;
      }

      await _addRiwayat(
        barangId: barang.id,
        warungId: barang.warungId,
        tipe: tipe,
        nilaiLama: stokLama,
        nilaiBaru: stokBaru,
        catatan: catatan ?? (delta > 0 ? '+$delta' : '$delta'),
      );

      // Update local list
      final index = _barangList.indexWhere((b) => b.id == barang.id);
      if (index >= 0) {
        _barangList[index] = barang.copyWith(
          stok: stokBaru,
          updatedAt: DateTime.now(),
        );
      }

      _stats = await _db.getWarungStats(barang.warungId);
      _applyFilter();

      // Check if stock is low and notify
      if (stokBaru <= barang.stokMinimum) {
        await _notif.showLowStockNotification(
          barangNama: barang.nama,
          stok: stokBaru,
          stokMinimum: barang.stokMinimum,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal mengupdate stok: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateHarga(Barang barang, int hargaBaru) async {
    try {
      final hargaLama = barang.harga;
      final updated = barang.copyWith(
        harga: hargaBaru,
        updatedAt: DateTime.now(),
        needsSync: true,
      );

      await _db.updateBarang(updated);

      await _addRiwayat(
        barangId: barang.id,
        warungId: barang.warungId,
        tipe: TipeRiwayat.editHarga,
        nilaiLama: hargaLama,
        nilaiBaru: hargaBaru,
      );

      final index = _barangList.indexWhere((b) => b.id == barang.id);
      if (index >= 0) {
        _barangList[index] = updated;
      }

      _stats = await _db.getWarungStats(barang.warungId);
      _applyFilter();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal mengupdate harga: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBarang(Barang barang) async {
    try {
      await _db.deleteBarang(barang.id);

      await _addRiwayat(
        barangId: barang.id,
        warungId: barang.warungId,
        tipe: TipeRiwayat.hapusBarang,
        nilaiLama: barang.stok,
        catatan: 'Barang dihapus: ${barang.nama}',
      );

      _barangList.removeWhere((b) => b.id == barang.id);
      _stats = await _db.getWarungStats(barang.warungId);
      _applyFilter();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal menghapus barang: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> _addRiwayat({
    required String barangId,
    required String warungId,
    required TipeRiwayat tipe,
    int? nilaiLama,
    int? nilaiBaru,
    String? catatan,
  }) async {
    final riwayat = Riwayat(
      id: _uuid.v4(),
      barangId: barangId,
      warungId: warungId,
      tipe: tipe,
      nilaiLama: nilaiLama,
      nilaiBaru: nilaiBaru,
      catatan: catatan,
      createdAt: DateTime.now(),
    );
    await _db.insertRiwayat(riwayat);
  }

  Future<void> _checkLowStock() async {
    final lowStockItems = barangStokMenipis;
    if (lowStockItems.length > 3) {
      // Show summary notification for many items
      await _notif.showMultipleLowStockNotification(
        jumlahBarang: lowStockItems.length,
      );
    } else if (lowStockItems.isNotEmpty) {
      // Show individual notifications
      for (var item in lowStockItems) {
        await _notif.showLowStockNotification(
          barangNama: item.nama,
          stok: item.stok,
          stokMinimum: item.stokMinimum,
        );
      }
    }
  }

  Kategori? getKategoriById(String id) {
    try {
      return _kategoriList.firstWhere((k) => k.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
