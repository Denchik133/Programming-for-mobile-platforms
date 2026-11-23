import 'package:connectivity_plus/connectivity_plus.dart';

abstract interface class ConnectivityStatus {
  Future<bool> get isOnline;
  Stream<bool> get changes;
}

class ConnectivityService implements ConnectivityStatus {
  ConnectivityService([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<bool> get isOnline async => (await _connectivity.checkConnectivity())
      .any((result) => result != ConnectivityResult.none);

  @override
  Stream<bool> get changes => _connectivity.onConnectivityChanged.map(
    (results) => results.any((result) => result != ConnectivityResult.none),
  );
}
