import 'dart:typed_data';

import 'package:citizen_sdk/citizen_sdk.dart';

abstract interface class TuyuSigner {
  Future<Uint8List> sign({
    required String accountId,
    required Uint8List message,
  });
}

/// TuyuLove只构造业务载荷；账户秘密、设备认证与sr25519签名全部归CitizenSDK。
final class CitizenSdkTuyuSigner implements TuyuSigner {
  const CitizenSdkTuyuSigner(this._signing);

  final CitizenSigning _signing;

  @override
  Future<Uint8List> sign({
    required String accountId,
    required Uint8List message,
  }) async =>
      (await _signing.sign(accountId: accountId, payload: message)).bytes;
}
