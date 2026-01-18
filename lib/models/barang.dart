class Barang {
  final String id;
  final String warungId;
  final String kategoriId;
  final String nama;
  final String fotoPath;
  final int stok;
  final int stokMinimum;
  final int harga;
  final String? deskripsi;
  final String? satuan;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool needsSync;

  Barang({
    required this.id,
    required this.warungId,
    required this.kategoriId,
    required this.nama,
    required this.fotoPath,
    this.stok = 0,
    this.stokMinimum = 5,
    this.harga = 0,
    this.deskripsi,
    this.satuan = 'pcs',
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.needsSync = true,
  });

  bool get isStokMenipis => stok <= stokMinimum;
  bool get isStokHabis => stok <= 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'warung_id': warungId,
      'kategori_id': kategoriId,
      'nama': nama,
      'foto_path': fotoPath,
      'stok': stok,
      'stok_minimum': stokMinimum,
      'harga': harga,
      'deskripsi': deskripsi,
      'satuan': satuan,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'needs_sync': needsSync ? 1 : 0,
    };
  }

  factory Barang.fromMap(Map<String, dynamic> map) {
    return Barang(
      id: map['id'] as String,
      warungId: map['warung_id'] as String,
      kategoriId: map['kategori_id'] as String,
      nama: map['nama'] as String,
      fotoPath: map['foto_path'] as String,
      stok: map['stok'] as int? ?? 0,
      stokMinimum: map['stok_minimum'] as int? ?? 5,
      harga: map['harga'] as int? ?? 0,
      deskripsi: map['deskripsi'] as String?,
      satuan: map['satuan'] as String? ?? 'pcs',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isActive: (map['is_active'] as int?) == 1,
      needsSync: (map['needs_sync'] as int?) == 1,
    );
  }

  Barang copyWith({
    String? id,
    String? warungId,
    String? kategoriId,
    String? nama,
    String? fotoPath,
    int? stok,
    int? stokMinimum,
    int? harga,
    String? deskripsi,
    String? satuan,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? needsSync,
  }) {
    return Barang(
      id: id ?? this.id,
      warungId: warungId ?? this.warungId,
      kategoriId: kategoriId ?? this.kategoriId,
      nama: nama ?? this.nama,
      fotoPath: fotoPath ?? this.fotoPath,
      stok: stok ?? this.stok,
      stokMinimum: stokMinimum ?? this.stokMinimum,
      harga: harga ?? this.harga,
      deskripsi: deskripsi ?? this.deskripsi,
      satuan: satuan ?? this.satuan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      needsSync: needsSync ?? this.needsSync,
    );
  }
}
