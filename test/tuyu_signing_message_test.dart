import 'package:flutter_test/flutter_test.dart';
import 'package:tuyulove/auth/auth_model.dart';
import 'package:tuyulove/auth/tuyu_signing_message.dart';

void main() {
  AuthChallenge challenge({String productId = 'tuyulove'}) => AuthChallenge(
    challengeId: 'challenge-1',
    tuyuId: 'TUYU-10001',
    accountId: '0x${'11' * 32}',
    keyRevision: 3,
    productId: productId,
    operation: 1,
    deviceId: 'device-1',
    expiresAt: DateTime.fromMillisecondsSinceEpoch(1800000000000, isUtc: true),
  );

  test('creates a deterministic Blake2-256 digest', () {
    expect(buildTuyuLoginDigest(challenge()), [
      231,
      143,
      20,
      131,
      89,
      131,
      12,
      90,
      178,
      134,
      181,
      6,
      210,
      110,
      188,
      107,
      34,
      247,
      68,
      84,
      75,
      118,
      112,
      89,
      80,
      231,
      150,
      3,
      221,
      150,
      32,
      222,
    ]);
    expect(buildTuyuLoginDigest(challenge()), hasLength(32));
  });

  test('binds the digest to the target productId', () {
    expect(
      buildTuyuLoginDigest(challenge()),
      isNot(buildTuyuLoginDigest(challenge(productId: 'tuyubooking'))),
    );
  });
}
