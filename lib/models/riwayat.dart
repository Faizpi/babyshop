enum TipeRiwayat {
  tambahStok,
  kurangStok,
  editHarga,
  editBarang,
  tambahBarang,
  hapusBarang,
  auditStok,
}

class Riwayat {
  final String id;
  final String barangId;
  final String warungId;
  final TipeRiwayat tipe;
  final int? nilaiLama;
  final int? nilaiBaru;
  final String? catatan;
  final DateTime createdAt;
  final bool needsSync;

  Riwayat({
    required this.id,
    required this.barangId,
    required this.warungId,
    required this.tipe,
    this.nilaiLama,
    this.nilaiBaru,
    this.catatan,
    required this.createdAt,
    this.needsSync = true,
  });

  String get tipeText {
    switch (tipe) {
      case TipeRiwayat.tambahStok:
        return 'Tambah Stok';
      case TipeRiwayat.kurangStok:
        return 'Kurang Stok';
      case TipeRiwayat.editHarga:
        return 'Edit Harga';
      case TipeRiwayat.editBarang:
        return 'Edit Barang';
      case TipeRiwayat.tambahBarang:
        return 'Barang Baru';
      case TipeRiwayat.hapusBarang:
        return 'Hapus Barang';
      case TipeRiwayat.auditStok:
        return 'Audit Stok';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barang_id': barangId,
      'warung_id': warungId,
      'tipe': tipe.index,
      'nilai_lama': nilaiLama,
      'nilai_baru': nilaiBaru,
      'catatan': catatan,
      'created_at': createdAt.toIso8601String(),
      'needs_sync': needsSync ? 1 : 0,
    };
  }

  factory Riwayat.fromMap(Map<String, dynamic> map) {
    return Riwayat(
      id: map['id'] as String,
      barangId: map['barang_id'] as String,
      warungId: map['warung_id'] as String,
      tipe: TipeRiwayat.values[map['tipe'] as int],
      nilaiLama: map['nilai_lama'] as int?,
      nilaiBaru: map['nilai_baru'] as int?,
      catatan: map['catatan'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      needsSync: (map['needs_sync'] as int?) == 1,
    );
  }
}
