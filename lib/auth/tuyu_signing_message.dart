import 'dart:typed_data';

import 'package:polkadart/polkadart.dart';
import 'package:tuyulove/auth/auth_model.dart';
import 'package:tuyulove/shared/bytes.dart';

/// 必须与 TuyuServe 保持逐字节一致：TUYU + 操作码 + SCALE 载荷，再 Blake2-256。
Uint8List buildTuyuLoginDigest(AuthChallenge challenge) {
  final payload = concatBytes([
    scaleString(challenge.tuyuId),
    uint64LittleEndian(challenge.keyRevision),
    scaleString(challenge.accountId),
    scaleString(challenge.audience),
    scaleString(challenge.challengeId),
    scaleString(challenge.deviceId),
    uint64LittleEndian(challenge.expiresAt.millisecondsSinceEpoch),
  ]);
  final envelope = concatBytes([
    const [0x54, 0x55, 0x59, 0x55],
    [challenge.operation],
    payload,
  ]);
  return Uint8List.fromList(Hasher.blake2b256.hash(envelope));
}
