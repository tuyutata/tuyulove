import 'package:flutter_test/flutter_test.dart';
import 'package:tuyulove/auth/auth_api.dart';
import 'package:tuyulove/network/secure_api_client.dart';

final class _Transport implements SecureApiTransport {
  _Transport({this.expiresAt = 1800000000000});
  final Object expiresAt;
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
      'product_id': 'tuyulove',
      'operation': 1,
      'device_id': 'device-1',
      'expires_at': expiresAt,
    };
  }
}

void main() {
  test('requests a TuyuLove-bound challenge', () async {
    final transport = _Transport();
    final challenge = await TuyuAuthApi(transport)
        .createChallenge(tuyuId: 'TUYU-1', deviceId: 'device-1');
    expect(transport.path, '/v1/auth/challenge');
    expect(transport.body?['product_id'], 'tuyulove');
    expect(challenge.keyRevision, 2);
    expect(challenge.accountId, startsWith('0x'));
  });

  test('拒绝日期字符串，云端有效期只有整数毫秒格式', () async {
    await expectLater(
      TuyuAuthApi(_Transport(expiresAt: '2027-01-15T08:00:00Z'))
          .createChallenge(tuyuId: 'TUYU-1', deviceId: 'device-1'),
      throwsFormatException,
    );
  });
}
