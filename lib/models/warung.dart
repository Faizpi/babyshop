class Warung {
  final String id;
  final String nama;
  final String? alamat;
  final String? fotoPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Warung({
    required this.id,
    required this.nama,
    this.alamat,
    this.fotoPath,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'alamat': alamat,
      'foto_path': fotoPath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Warung.fromMap(Map<String, dynamic> map) {
    return Warung(
      id: map['id'] as String,
      nama: map['nama'] as String,
      alamat: map['alamat'] as String?,
      fotoPath: map['foto_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isActive: (map['is_active'] as int) == 1,
    );
  }

  Warung copyWith({
    String? id,
    String? nama,
    String? alamat,
    String? fotoPath,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Warung(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      alamat: alamat ?? this.alamat,
      fotoPath: fotoPath ?? this.fotoPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
