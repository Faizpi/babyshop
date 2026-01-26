import 'dart:async';
import 'package:flutter/material.dart';
import '../services/firebase_sync_service.dart';
import '../services/connectivity_service.dart';

class SyncProvider extends ChangeNotifier {
  final FirebaseSyncService _syncService = FirebaseSyncService.instance;
  final ConnectivityService _connectivity = ConnectivityService.instance;

  StreamSubscription? _connectivitySubscription;
  bool _isOnline = false;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  String? _syncError;
  bool _autoSyncEnabled = true;

  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get syncError => _syncError;
  bool get autoSyncEnabled => _autoSyncEnabled;

  SyncProvider() {
    _init();
  }

  void _init() {
    _isOnline = _connectivity.isConnected;

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.connectionStream.listen((
      isConnected,
    ) {
      _isOnline = isConnected;
      notifyListeners();

      // Auto sync when coming online
      if (isConnected && _autoSyncEnabled) {
        syncToCloud();
      }
    });
  }

  Future<SyncResult> syncToCloud() async {
    if (_isSyncing) {
      return SyncResult(success: false, message: 'Sync sudah berjalan');
    }

    if (!_isOnline) {
      return SyncResult(success: false, message: 'Tidak ada koneksi internet');
    }

    _isSyncing = true;
    _syncError = null;
    notifyListeners();

    final result = await _syncService.syncToFirebase();

    _isSyncing = false;
    if (result.success) {
      _lastSyncTime = DateTime.now();
    } else {
      _syncError = result.message;
    }
    notifyListeners();

    return result;
  }

  Future<SyncResult> downloadFromCloud() async {
    if (_isSyncing) {
      return SyncResult(success: false, message: 'Sync sudah berjalan');
    }

    if (!_isOnline) {
      return SyncResult(success: false, message: 'Tidak ada koneksi internet');
    }

    _isSyncing = true;
    _syncError = null;
    notifyListeners();

    final result = await _syncService.downloadFromFirebase();

    _isSyncing = false;
    if (result.success) {
      _lastSyncTime = DateTime.now();
    } else {
      _syncError = result.message;
    }
    notifyListeners();

    return result;
  }

  Future<bool> checkCloudData() async {
    return await _syncService.hasCloudData();
  }

  void setAutoSync(bool enabled) {
    _autoSyncEnabled = enabled;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
