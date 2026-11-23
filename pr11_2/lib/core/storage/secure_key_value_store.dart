import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SecureKeyValueStore {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);
}

class PlatformSecureKeyValueStore implements SecureKeyValueStore {
  PlatformSecureKeyValueStore._(this._storage);

  factory PlatformSecureKeyValueStore.create() {
    final storage = Platform.isMacOS
        ? const FlutterSecureStorage(
            mOptions: MacOsOptions(usesDataProtectionKeychain: false),
          )
        : const FlutterSecureStorage();
    return PlatformSecureKeyValueStore._(storage);
  }

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class MemorySecureKeyValueStore implements SecureKeyValueStore {
  final Map<String, String> _values = {};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }
}
