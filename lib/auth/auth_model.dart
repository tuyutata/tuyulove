final class AuthChallenge {
  const AuthChallenge({
    required this.challengeId,
    required this.tuyuId,
    required this.accountId,
    required this.keyRevision,
    required this.productId,
    required this.operation,
    required this.deviceId,
    required this.expiresAt,
  });

  final String challengeId;
  final String tuyuId;
  final String accountId;
  final int keyRevision;
  final String productId;
  final int operation;
  final String deviceId;
  final DateTime expiresAt;
}

final class AuthProof {
  const AuthProof({required this.challenge, required this.signature});
  final AuthChallenge challenge;
  final String signature;
}

final class AuthSession {
  const AuthSession({
    required this.sessionToken,
    required this.tuyuId,
    required this.expiresAt,
  });
  final String sessionToken;
  final String tuyuId;
  final DateTime expiresAt;
}

enum AuthStatus { idle, signing, authenticated, failed }
