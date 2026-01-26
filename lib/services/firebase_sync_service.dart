import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'database_helper.dart';
import 'connectivity_service.dart';

class FirebaseSyncService {
  static final FirebaseSyncService instance = FirebaseSyncService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseHelper _db = DatabaseHelper.instance;
  final ConnectivityService _connectivity = ConnectivityService.instance;

  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  factory FirebaseSyncService() => instance;
  FirebaseSyncService._internal();

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;

  // Get user's collection reference
  CollectionReference _userCollection(String collection) {
    if (_userId == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(_userId).collection(collection);
  }

  // Sync all data to Firebase
  Future<SyncResult> syncToFirebase() async {
    if (_userId == null) {
      return SyncResult(success: false, message: 'User not authenticated');
    }

    if (!_connectivity.isConnected) {
      return SyncResult(success: false, message: 'No internet connection');
    }

    if (_isSyncing) {
      return SyncResult(success: false, message: 'Sync already in progress');
    }

    _isSyncing = true;
    debugPrint('Starting sync to Firebase...');

    try {
      // Sync user data
      await _syncUserData();

      // Sync warung
      await _syncWarung();

      // Sync barang
      await _syncBarang();

      // Sync riwayat
      await _syncRiwayat();

      // Mark all as synced
      await _markAllAsSynced();

      _lastSyncTime = DateTime.now();
      _isSyncing = false;

      debugPrint('Sync completed successfully');
      return SyncResult(success: true, message: 'Data berhasil disinkronkan');
    } catch (e) {
      _isSyncing = false;
      debugPrint('Sync failed: $e');
      return SyncResult(success: false, message: 'Gagal sinkronisasi: $e');
    }
  }

  // Sync user data
  Future<void> _syncUserData() async {
    final localUser = await _db.getUser();
    if (localUser == null) return;

    final userDoc = _firestore.collection('users').doc(_userId);
    await userDoc.set({
      'nama': localUser.nama,
      'fotoPath': localUser.fotoPath,
      'createdAt': localUser.createdAt.toIso8601String(),
      'lastLogin': localUser.lastLogin?.toIso8601String(),
      'lastSync': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Sync warung
  Future<void> _syncWarung() async {
    final warungList = await _db.getAllWarung();
    final batch = _firestore.batch();

    for (var warung in warungList) {
      final docRef = _userCollection('warung').doc(warung.id);
      batch.set(docRef, {
        ...warung.toMap(),
        'lastSync': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  // Sync barang (only items that need sync)
  Future<void> _syncBarang() async {
    final barangList = await _db.getBarangNeedingSync();
    if (barangList.isEmpty) return;

    final batch = _firestore.batch();

    for (var barang in barangList) {
      final docRef = _userCollection('barang').doc(barang.id);
      batch.set(docRef, {
        ...barang.toMap(),
        'lastSync': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  // Sync riwayat (only items that need sync)
  Future<void> _syncRiwayat() async {
    final riwayatList = await _db.getRiwayatNeedingSync();
    if (riwayatList.isEmpty) return;

    final batch = _firestore.batch();

    for (var riwayat in riwayatList) {
      final docRef = _userCollection('riwayat').doc(riwayat.id);
      batch.set(docRef, {
        ...riwayat.toMap(),
        'lastSync': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  // Mark all local data as synced
  Future<void> _markAllAsSynced() async {
    await _db.markAllAsSynced();
  }

  // Download data from Firebase (for new device)
  Future<SyncResult> downloadFromFirebase() async {
    if (_userId == null) {
      return SyncResult(success: false, message: 'User not authenticated');
    }

    if (!_connectivity.isConnected) {
      return SyncResult(success: false, message: 'No internet connection');
    }

    _isSyncing = true;
    debugPrint('Downloading data from Firebase...');

    try {
      // Download warung
      await _downloadWarung();

      // Download barang
      await _downloadBarang();

      // Download riwayat
      await _downloadRiwayat();

      _lastSyncTime = DateTime.now();
      _isSyncing = false;

      debugPrint('Download completed successfully');
      return SyncResult(success: true, message: 'Data berhasil diunduh');
    } catch (e) {
      _isSyncing = false;
      debugPrint('Download failed: $e');
      return SyncResult(success: false, message: 'Gagal mengunduh data: $e');
    }
  }

  Future<void> _downloadWarung() async {
    final snapshot = await _userCollection('warung').get();
    
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final warung = Warung.fromMap(data);
      
      // Check if exists locally
      final existing = await _db.getWarungById(warung.id);
      if (existing == null) {
        await _db.insertWarung(warung);
      } else {
        await _db.updateWarung(warung);
      }
    }
  }

  Future<void> _downloadBarang() async {
    final snapshot = await _userCollection('barang').get();
    
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final barang = Barang.fromMap(data);
      
      // Check if exists locally
      final existing = await _db.getBarangById(barang.id);
      if (existing == null) {
        await _db.insertBarang(barang);
      } else {
        await _db.updateBarang(barang);
      }
    }
  }

  Future<void> _downloadRiwayat() async {
    final snapshot = await _userCollection('riwayat')
        .orderBy('created_at', descending: true)
        .limit(500)
        .get();
    
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final riwayat = Riwayat.fromMap(data);
      
      // Try to insert (ignore if exists)
      try {
        await _db.insertRiwayat(riwayat);
      } catch (e) {
        // Ignore duplicate key errors
      }
    }
  }

  // Check if user has data on Firebase
  Future<bool> hasCloudData() async {
    if (_userId == null) return false;
    if (!_connectivity.isConnected) return false;

    try {
      final warungSnapshot = await _userCollection('warung').limit(1).get();
      return warungSnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Delete all user data from Firebase
  Future<void> deleteAllCloudData() async {
    if (_userId == null) return;

    // Delete all subcollections
    final collections = ['warung', 'barang', 'riwayat'];
    
    for (var collection in collections) {
      final snapshot = await _userCollection(collection).get();
      final batch = _firestore.batch();
      
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    }

    // Delete user document
    await _firestore.collection('users').doc(_userId).delete();
  }
}

class SyncResult {
  final bool success;
  final String message;
  final int? syncedItems;

  SyncResult({
    required this.success,
    required this.message,
    this.syncedItems,
  });
}
