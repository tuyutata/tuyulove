import 'dart:typed_data';

final class BusinessProof {
  const BusinessProof({
    required this.tuyuId,
    required this.accountId,
    required this.signature,
  });

  final String tuyuId;
  final String accountId;
  final String signature;
}

abstract interface class BusinessProofSigner {
  Future<BusinessProof> signBusinessPayload(Uint8List payload);
}

final class BusinessProofUnavailable implements Exception {
  const BusinessProofUnavailable();
}
