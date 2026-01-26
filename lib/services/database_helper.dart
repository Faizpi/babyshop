import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static bool _webInitialized = false;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Initialize web database factory
    if (kIsWeb && !_webInitialized) {
      databaseFactory = databaseFactoryFfiWeb;
      _webInitialized = true;
    }

    _database = await _initDB('warungku.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      // For web, just use the filename
      return await openDatabase(filePath, version: 1, onCreate: _createDB);
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add Firebase fields to users table
      await db.execute('ALTER TABLE users ADD COLUMN firebase_uid TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN email TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN phone_number TEXT');
    }
  }

  Future _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        nama TEXT NOT NULL,
        pin TEXT,
        foto_path TEXT,
        firebase_uid TEXT,
        email TEXT,
        phone_number TEXT,
        created_at TEXT NOT NULL,
        last_login TEXT
      )
    ''');

    // Warung table
    await db.execute('''
      CREATE TABLE warung (
        id TEXT PRIMARY KEY,
        nama TEXT NOT NULL,
        alamat TEXT,
        foto_path TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_active INTEGER DEFAULT 1
      )
    ''');

    // Kategori table
    await db.execute('''
      CREATE TABLE kategori (
        id TEXT PRIMARY KEY,
        nama TEXT NOT NULL,
        icon_name TEXT,
        warna TEXT,
        urutan INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Barang table
    await db.execute('''
      CREATE TABLE barang (
        id TEXT PRIMARY KEY,
        warung_id TEXT NOT NULL,
        kategori_id TEXT NOT NULL,
        nama TEXT NOT NULL,
        foto_path TEXT NOT NULL,
        stok INTEGER DEFAULT 0,
        stok_minimum INTEGER DEFAULT 5,
        harga INTEGER DEFAULT 0,
        deskripsi TEXT,
        satuan TEXT DEFAULT 'pcs',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        needs_sync INTEGER DEFAULT 1,
        FOREIGN KEY (warung_id) REFERENCES warung (id),
        FOREIGN KEY (kategori_id) REFERENCES kategori (id)
      )
    ''');

    // Riwayat table
    await db.execute('''
      CREATE TABLE riwayat (
        id TEXT PRIMARY KEY,
        barang_id TEXT NOT NULL,
        warung_id TEXT NOT NULL,
        tipe INTEGER NOT NULL,
        nilai_lama INTEGER,
        nilai_baru INTEGER,
        catatan TEXT,
        created_at TEXT NOT NULL,
        needs_sync INTEGER DEFAULT 1,
        FOREIGN KEY (barang_id) REFERENCES barang (id),
        FOREIGN KEY (warung_id) REFERENCES warung (id)
      )
    ''');

    // Settings table
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Insert default categories
    final defaultKategori = Kategori.defaultKategori();
    for (var kategori in defaultKategori) {
      await db.insert('kategori', kategori.toMap());
    }
  }

  // ==================== USER ====================
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUser() async {
    final db = await database;
    final maps = await db.query('users', limit: 1);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // ==================== WARUNG ====================
  Future<int> insertWarung(Warung warung) async {
    final db = await database;
    return await db.insert('warung', warung.toMap());
  }

  Future<List<Warung>> getAllWarung() async {
    final db = await database;
    final maps = await db.query(
      'warung',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'nama ASC',
    );
    return maps.map((map) => Warung.fromMap(map)).toList();
  }

  Future<Warung?> getWarungById(String id) async {
    final db = await database;
    final maps = await db.query('warung', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Warung.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateWarung(Warung warung) async {
    final db = await database;
    return await db.update(
      'warung',
      warung.toMap(),
      where: 'id = ?',
      whereArgs: [warung.id],
    );
  }

  Future<int> deleteWarung(String id) async {
    final db = await database;
    return await db.update(
      'warung',
      {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== KATEGORI ====================
  Future<List<Kategori>> getAllKategori() async {
    final db = await database;
    final maps = await db.query('kategori', orderBy: 'urutan ASC');
    return maps.map((map) => Kategori.fromMap(map)).toList();
  }

  Future<Kategori?> getKategoriById(String id) async {
    final db = await database;
    final maps = await db.query('kategori', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Kategori.fromMap(maps.first);
    }
    return null;
  }

  // ==================== BARANG ====================
  Future<int> insertBarang(Barang barang) async {
    final db = await database;
    return await db.insert('barang', barang.toMap());
  }

  Future<List<Barang>> getAllBarang(String warungId) async {
    final db = await database;
    final maps = await db.query(
      'barang',
      where: 'warung_id = ? AND is_active = ?',
      whereArgs: [warungId, 1],
      orderBy: 'nama ASC',
    );
    return maps.map((map) => Barang.fromMap(map)).toList();
  }

  Future<List<Barang>> getBarangByKategori(
    String warungId,
    String kategoriId,
  ) async {
    final db = await database;
    final maps = await db.query(
      'barang',
      where: 'warung_id = ? AND kategori_id = ? AND is_active = ?',
      whereArgs: [warungId, kategoriId, 1],
      orderBy: 'nama ASC',
    );
    return maps.map((map) => Barang.fromMap(map)).toList();
  }

  Future<List<Barang>> searchBarang(String warungId, String query) async {
    final db = await database;
    final maps = await db.query(
      'barang',
      where: 'warung_id = ? AND is_active = ? AND nama LIKE ?',
      whereArgs: [warungId, 1, '%$query%'],
      orderBy: 'nama ASC',
    );
    return maps.map((map) => Barang.fromMap(map)).toList();
  }

  Future<List<Barang>> getBarangStokMenipis(String warungId) async {
    final db = await database;
    final maps = await db.rawQuery(
      '''
      SELECT * FROM barang 
      WHERE warung_id = ? AND is_active = 1 AND stok <= stok_minimum
      ORDER BY stok ASC
    ''',
      [warungId],
    );
    return maps.map((map) => Barang.fromMap(map)).toList();
  }

  Future<Barang?> getBarangById(String id) async {
    final db = await database;
    final maps = await db.query('barang', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Barang.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateBarang(Barang barang) async {
    final db = await database;
    return await db.update(
      'barang',
      barang.toMap(),
      where: 'id = ?',
      whereArgs: [barang.id],
    );
  }

  Future<int> updateStok(String barangId, int stokBaru) async {
    final db = await database;
    return await db.update(
      'barang',
      {
        'stok': stokBaru,
        'updated_at': DateTime.now().toIso8601String(),
        'needs_sync': 1,
      },
      where: 'id = ?',
      whereArgs: [barangId],
    );
  }

  Future<int> deleteBarang(String id) async {
    final db = await database;
    return await db.update(
      'barang',
      {
        'is_active': 0,
        'updated_at': DateTime.now().toIso8601String(),
        'needs_sync': 1,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Statistics
  Future<Map<String, dynamic>> getWarungStats(String warungId) async {
    final db = await database;

    final totalBarang =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM barang WHERE warung_id = ? AND is_active = 1',
            [warungId],
          ),
        ) ??
        0;

    final totalStok =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT SUM(stok) FROM barang WHERE warung_id = ? AND is_active = 1',
            [warungId],
          ),
        ) ??
        0;

    final stokMenipis =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM barang WHERE warung_id = ? AND is_active = 1 AND stok <= stok_minimum',
            [warungId],
          ),
        ) ??
        0;

    final totalNilai =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT SUM(stok * harga) FROM barang WHERE warung_id = ? AND is_active = 1',
            [warungId],
          ),
        ) ??
        0;

    return {
      'totalBarang': totalBarang,
      'totalStok': totalStok,
      'stokMenipis': stokMenipis,
      'totalNilai': totalNilai,
    };
  }

  // ==================== RIWAYAT ====================
  Future<int> insertRiwayat(Riwayat riwayat) async {
    final db = await database;
    return await db.insert('riwayat', riwayat.toMap());
  }

  Future<List<Riwayat>> getRiwayatByBarang(
    String barangId, {
    int limit = 50,
  }) async {
    final db = await database;
    final maps = await db.query(
      'riwayat',
      where: 'barang_id = ?',
      whereArgs: [barangId],
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return maps.map((map) => Riwayat.fromMap(map)).toList();
  }

  Future<List<Riwayat>> getRiwayatByWarung(
    String warungId, {
    int limit = 100,
  }) async {
    final db = await database;
    final maps = await db.query(
      'riwayat',
      where: 'warung_id = ?',
      whereArgs: [warungId],
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return maps.map((map) => Riwayat.fromMap(map)).toList();
  }

  Future<List<Map<String, dynamic>>> getRiwayatWithBarangInfo(
    String warungId, {
    int limit = 100,
  }) async {
    final db = await database;
    final maps = await db.rawQuery(
      '''
      SELECT r.*, b.nama as barang_nama, b.foto_path as barang_foto
      FROM riwayat r
      LEFT JOIN barang b ON r.barang_id = b.id
      WHERE r.warung_id = ?
      ORDER BY r.created_at DESC
      LIMIT ?
    ''',
      [warungId, limit],
    );
    return maps;
  }

  // ==================== SETTINGS ====================
  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final maps = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (maps.isNotEmpty) {
      return maps.first['value'] as String?;
    }
    return null;
  }

  // ==================== SYNC ====================
  Future<List<Barang>> getBarangNeedsSync() async {
    final db = await database;
    final maps = await db.query(
      'barang',
      where: 'needs_sync = ?',
      whereArgs: [1],
    );
    return maps.map((map) => Barang.fromMap(map)).toList();
  }

  Future<List<Barang>> getBarangNeedingSync() async {
    return getBarangNeedsSync();
  }

  Future<List<Riwayat>> getRiwayatNeedingSync() async {
    final db = await database;
    final maps = await db.query(
      'riwayat',
      where: 'needs_sync = ?',
      whereArgs: [1],
    );
    return maps.map((map) => Riwayat.fromMap(map)).toList();
  }

  Future<void> markBarangSynced(String id) async {
    final db = await database;
    await db.update(
      'barang',
      {'needs_sync': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markAllAsSynced() async {
    final db = await database;
    await db.update('barang', {'needs_sync': 0});
    await db.update('riwayat', {'needs_sync': 0});
  }

  // ==================== EXPORT ====================
  Future<List<Map<String, dynamic>>> exportAllData(String warungId) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT 
        b.nama,
        b.stok,
        b.harga,
        b.stok_minimum,
        b.satuan,
        k.nama as kategori,
        b.created_at,
        b.updated_at
      FROM barang b
      LEFT JOIN kategori k ON b.kategori_id = k.id
      WHERE b.warung_id = ? AND b.is_active = 1
      ORDER BY k.urutan, b.nama
    ''',
      [warungId],
    );
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
