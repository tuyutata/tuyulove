import 'package:tuyulove/auth/auth_model.dart';
import 'package:tuyulove/network/secure_api_client.dart';

abstract interface class AuthApi {
  Future<AuthChallenge> createChallenge({
    required String tuyuId,
    required String deviceId,
  });
  Future<AuthSession> createSession(AuthProof proof);
}

final class TuyuAuthApi implements AuthApi {
  const TuyuAuthApi(this._transport);

  static const String audience = 'tuyulove';
  final SecureApiTransport _transport;

  @override
  Future<AuthChallenge> createChallenge({
    required String tuyuId,
    required String deviceId,
  }) async {
    final json = await _transport.post('/v1/auth/challenge', {
      'tuyu_id': tuyuId,
      'device_id': deviceId,
      'audience': audience,
    });
    return AuthChallenge(
      challengeId: _string(json, 'challenge_id'),
      tuyuId: _string(json, 'tuyu_id'),
      accountId: _string(json, 'account_id'),
      keyRevision: _integer(json, 'key_revision'),
      audience: _string(json, 'audience'),
      operation: _integer(json, 'operation'),
      deviceId: _string(json, 'device_id'),
      expiresAt: _date(json, 'expires_at'),
    );
  }

  @override
  Future<AuthSession> createSession(AuthProof proof) async {
    final challenge = proof.challenge;
    final json = await _transport.post('/v1/auth/session', {
      'challenge_id': challenge.challengeId,
      'tuyu_id': challenge.tuyuId,
      'account_id': challenge.accountId,
      'key_revision': challenge.keyRevision,
      'audience': challenge.audience,
      'operation': challenge.operation,
      'device_id': challenge.deviceId,
      'expires_at': challenge.expiresAt.millisecondsSinceEpoch,
      'signature': proof.signature,
    });
    return AuthSession(
      token: _string(json, 'session_token'),
      tuyuId: _string(json, 'tuyu_id'),
      expiresAt: _date(json, 'expires_at'),
    );
  }

  static String _string(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is! String || value.isEmpty) throw FormatException('缺少字段：$key');
    return value;
  }

  static int _integer(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is! int) throw FormatException('字段类型无效：$key');
    return value;
  }

  static DateTime _date(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
    }
    if (value is String) {
      return DateTime.parse(value).toUtc();
    }
    throw FormatException('字段类型无效：$key');
  }
}

final class UnavailableAuthApi implements AuthApi {
  const UnavailableAuthApi();

  @override
  Future<AuthChallenge> createChallenge({
    required String tuyuId,
    required String deviceId,
  }) {
    throw const AuthUnavailableException();
  }

  @override
  Future<AuthSession> createSession(AuthProof proof) {
    throw const AuthUnavailableException();
  }
}

final class AuthUnavailableException implements Exception {
  const AuthUnavailableException();
}
