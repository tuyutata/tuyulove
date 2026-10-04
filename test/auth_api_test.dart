import 'package:flutter_test/flutter_test.dart';
import 'package:tuyulove/auth/auth_api.dart';
import 'package:tuyulove/network/secure_api_client.dart';

final class _Transport implements SecureApiTransport {
  String? path;
  Map<String, Object?>? body;

  @override
  Future<Map<String, Object?>> post(
    String path,
    Map<String, Object?> body,
  ) async {
    this.path = path;
    this.body = body;
    return {
      'challenge_id': 'challenge-1',
      'tuyu_id': 'TUYU-1',
      'account_id': '0x${'11' * 32}',
      'key_revision': 2,
      'audience': 'tuyulove',
      'operation': 1,
      'device_id': 'device-1',
      'expires_at': 1800000000000,
    };
  }
}

void main() {
  test('requests a TuyuLove-bound challenge', () async {
    final transport = _Transport();
    final challenge = await TuyuAuthApi(
      transport,
    ).createChallenge(tuyuId: 'TUYU-1', deviceId: 'device-1');
    expect(transport.path, '/v1/auth/challenge');
    expect(transport.body?['audience'], 'tuyulove');
    expect(challenge.keyRevision, 2);
    expect(challenge.accountId, startsWith('0x'));
  });
}
