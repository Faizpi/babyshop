class User {
  final String id;
  final String nama;
  final String? pin;
  final String? fotoPath;
  final String? firebaseUid;
  final String? email;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.nama,
    this.pin,
    this.fotoPath,
    this.firebaseUid,
    this.email,
    this.phoneNumber,
    required this.createdAt,
    this.lastLogin,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'pin': pin,
      'foto_path': fotoPath,
      'firebase_uid': firebaseUid,
      'email': email,
      'phone_number': phoneNumber,
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
      firebaseUid: map['firebase_uid'] as String?,
      email: map['email'] as String?,
      phoneNumber: map['phone_number'] as String?,
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
    String? firebaseUid,
    String? email,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      pin: pin ?? this.pin,
      fotoPath: fotoPath ?? this.fotoPath,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
