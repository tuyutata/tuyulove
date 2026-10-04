import 'package:flutter_test/flutter_test.dart';
import 'package:tuyulove/auth/auth_model.dart';
import 'package:tuyulove/auth/tuyu_signing_message.dart';

void main() {
  AuthChallenge challenge({String audience = 'tuyulove'}) => AuthChallenge(
    challengeId: 'challenge-1',
    tuyuId: 'TUYU-10001',
    accountId: '0x${'11' * 32}',
    keyRevision: 3,
    audience: audience,
    operation: 1,
    deviceId: 'device-1',
    expiresAt: DateTime.fromMillisecondsSinceEpoch(1800000000000, isUtc: true),
  );

  test('creates a deterministic Blake2-256 digest', () {
    expect(
      buildTuyuLoginDigest(challenge()),
      buildTuyuLoginDigest(challenge()),
    );
    expect(buildTuyuLoginDigest(challenge()), hasLength(32));
  });

  test('binds the digest to the target audience', () {
    expect(
      buildTuyuLoginDigest(challenge()),
      isNot(buildTuyuLoginDigest(challenge(audience: 'tuyubooking'))),
    );
  });
}
