import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  static final ConnectivityService instance = ConnectivityService._internal();
  final Connectivity _connectivity = Connectivity();

  StreamController<bool>? _connectionController;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isConnected = false;
  bool _isInitialized = false;

  factory ConnectivityService() => instance;
  ConnectivityService._internal();

  bool get isConnected => _isConnected;

  Stream<bool> get connectionStream {
    _connectionController ??= StreamController<bool>.broadcast();
    return _connectionController!.stream;
  }

  Future<void> init() async {
    if (_isInitialized) return;

    // Check initial connectivity
    final results = await _connectivity.checkConnectivity();
    _isConnected = _hasConnection(results);

    // Listen for connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final connected = _hasConnection(results);
      if (connected != _isConnected) {
        _isConnected = connected;
        _connectionController?.add(_isConnected);
        debugPrint(
          'Connectivity changed: ${_isConnected ? "Online" : "Offline"}',
        );
      }
    });

    _isInitialized = true;
    debugPrint('ConnectivityService initialized. Connected: $_isConnected');
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any(
      (result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet,
    );
  }

  Future<bool> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _isConnected = _hasConnection(results);
    return _isConnected;
  }

  void dispose() {
    _subscription?.cancel();
    _connectionController?.close();
    _connectionController = null;
    _isInitialized = false;
  }
}
