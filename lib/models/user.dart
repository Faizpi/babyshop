class User {
  final String id;
  final String nama;
  final String? pin;
  final String? fotoPath;
  final DateTime createdAt;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.nama,
    this.pin,
    this.fotoPath,
    required this.createdAt,
    this.lastLogin,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'pin': pin,
      'foto_path': fotoPath,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      nama: map['nama'] as String,
      pin: map['pin'] as String?,
      fotoPath: map['foto_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastLogin: map['last_login'] != null
          ? DateTime.parse(map['last_login'] as String)
          : null,
    );
  }

  User copyWith({
    String? id,
    String? nama,
    String? pin,
    String? fotoPath,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      pin: pin ?? this.pin,
      fotoPath: fotoPath ?? this.fotoPath,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
