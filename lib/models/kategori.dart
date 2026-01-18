class Kategori {
  final String id;
  final String nama;
  final String? iconName;
  final String? warna;
  final int urutan;
  final DateTime createdAt;

  Kategori({
    required this.id,
    required this.nama,
    this.iconName,
    this.warna,
    this.urutan = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'icon_name': iconName,
      'warna': warna,
      'urutan': urutan,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Kategori.fromMap(Map<String, dynamic> map) {
    return Kategori(
      id: map['id'] as String,
      nama: map['nama'] as String,
      iconName: map['icon_name'] as String?,
      warna: map['warna'] as String?,
      urutan: map['urutan'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Kategori copyWith({
    String? id,
    String? nama,
    String? iconName,
    String? warna,
    int? urutan,
    DateTime? createdAt,
  }) {
    return Kategori(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      iconName: iconName ?? this.iconName,
      warna: warna ?? this.warna,
      urutan: urutan ?? this.urutan,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Default categories for baby products
  static List<Kategori> defaultKategori() {
    final now = DateTime.now();
    return [
      Kategori(
        id: 'susu',
        nama: 'Susu & Formula',
        iconName: 'baby_bottle',
        warna: '#FFB6C1',
        urutan: 1,
        createdAt: now,
      ),
      Kategori(
        id: 'popok',
        nama: 'Popok & Diapers',
        iconName: 'diaper',
        warna: '#87CEEB',
        urutan: 2,
        createdAt: now,
      ),
      Kategori(
        id: 'makanan',
        nama: 'Makanan Bayi',
        iconName: 'food',
        warna: '#98FB98',
        urutan: 3,
        createdAt: now,
      ),
      Kategori(
        id: 'perawatan',
        nama: 'Perawatan',
        iconName: 'soap',
        warna: '#DDA0DD',
        urutan: 4,
        createdAt: now,
      ),
      Kategori(
        id: 'pakaian',
        nama: 'Pakaian',
        iconName: 'clothes',
        warna: '#F0E68C',
        urutan: 5,
        createdAt: now,
      ),
      Kategori(
        id: 'mainan',
        nama: 'Mainan',
        iconName: 'toy',
        warna: '#FFA07A',
        urutan: 6,
        createdAt: now,
      ),
      Kategori(
        id: 'perlengkapan',
        nama: 'Perlengkapan',
        iconName: 'baby_items',
        warna: '#B0C4DE',
        urutan: 7,
        createdAt: now,
      ),
      Kategori(
        id: 'lainnya',
        nama: 'Lainnya',
        iconName: 'other',
        warna: '#D3D3D3',
        urutan: 8,
        createdAt: now,
      ),
    ];
  }
}
