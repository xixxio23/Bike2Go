import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isOnline = true;

  final ValueNotifier<bool> connectivityNotifier =
      ValueNotifier<bool>(true);

  bool get isOnline => _isOnline;

  Future<void> initialize() async {
    await checkConnectivity();

    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        setConnectivityStatus(_hasConnection(results));
      },
    );
  }

  void setConnectivityStatus(bool isConnected) {
    if (_isOnline == isConnected) {
      return;
    }

    _isOnline = isConnected;
    connectivityNotifier.value = isConnected;
  }

  Future<void> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();

      setConnectivityStatus(
        _hasConnection(results),
      );
    } catch (e) {
      debugPrint('Connectivity check error: $e');
      setConnectivityStatus(false);
    }
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any(
      (result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.vpn ||
          result == ConnectivityResult.bluetooth ||
          result == ConnectivityResult.other,
    );
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    connectivityNotifier.dispose();
  }
}