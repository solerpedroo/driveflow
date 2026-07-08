import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Monitora conectividade de rede (Wi‑Fi/dados móveis).
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Stream<bool> get onOnlineChanged async* {
    yield await isOnline;
    await for (final results in _connectivity.onConnectivityChanged) {
      yield _isOnlineResult(results);
    }
  }

  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    return _isOnlineResult(results);
  }

  bool _isOnlineResult(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((r) => r != ConnectivityResult.none);
  }
}
