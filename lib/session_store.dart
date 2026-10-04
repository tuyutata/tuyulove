import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tuyulove/auth/auth_model.dart';
import 'package:tuyulove/shared/bytes.dart';

abstract interface class SessionStore {
  Future<String> deviceId();
  Future<void> save(AuthSession session);
  Future<void> clear();
}

final class SecureSessionStore implements SessionStore {
  SecureSessionStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _deviceKey = 'tuyu.auth.device_id';
  static const _tokenKey = 'tuyu.auth.session_token';
  static const _expiryKey = 'tuyu.auth.session_expiry';
  final FlutterSecureStorage _storage;

  @override
  Future<String> deviceId() async {
    final existing = await _storage.read(key: _deviceKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final random = Random.secure();
    final bytes = Uint8List.fromList(
      List<int>.generate(16, (_) => random.nextInt(256)),
    );
    final value = bytesToHex(bytes, prefix: false);
    clearBytes(bytes);
    await _storage.write(key: _deviceKey, value: value);
    return value;
  }

  @override
  Future<void> save(AuthSession session) async {
    await _storage.write(key: _tokenKey, value: session.token);
    await _storage.write(
      key: _expiryKey,
      value: session.expiresAt.toIso8601String(),
    );
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _expiryKey);
  }
}
