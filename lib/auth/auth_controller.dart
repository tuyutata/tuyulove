import 'package:flutter/foundation.dart';
import 'package:tuyulove/auth/auth_api.dart';
import 'package:tuyulove/auth/business_proof.dart';
import 'package:tuyulove/auth/auth_model.dart';
import 'package:tuyulove/auth/tuyu_signer.dart';
import 'package:tuyulove/auth/tuyu_signing_message.dart';
import 'package:tuyulove/session_store.dart';
import 'package:tuyulove/shared/bytes.dart';
import 'package:tuyulove/shared/time.dart';

final class AuthController extends ChangeNotifier
    implements BusinessProofSigner {
  AuthController({
    required AuthApi api,
    required TuyuSigner signer,
    required SessionStore sessionStore,
    Clock clock = systemClock,
  }) : this._(api, signer, sessionStore, clock);

  AuthController._(this._api, this._signer, this._sessionStore, this._clock);

  final AuthApi _api;
  final TuyuSigner _signer;
  final SessionStore _sessionStore;
  final Clock _clock;

  AuthStatus _status = AuthStatus.idle;
  AuthSession? _session;
  String? _accountId;
  AuthStatus get status => _status;
  bool get isBusy => _status == AuthStatus.signing;
  AuthSession? get session => _session;

  Future<void> login(String rawTuyuId) async {
    final tuyuId = rawTuyuId.trim();
    if (tuyuId.isEmpty || isBusy) return;
    _setStatus(AuthStatus.signing);
    try {
      final deviceId = await _sessionStore.deviceId();
      final challenge = await _api.createChallenge(
        tuyuId: tuyuId,
        deviceId: deviceId,
      );
      _validateChallenge(challenge, tuyuId, deviceId);
      final digest = buildTuyuLoginDigest(challenge);
      final signature = await _signer.sign(
        accountId: challenge.accountId,
        message: digest,
      );
      try {
        final session = await _api.createSession(
          AuthProof(challenge: challenge, signature: bytesToHex(signature)),
        );
        if (session.tuyuId != tuyuId || !session.expiresAt.isAfter(_clock())) {
          throw const FormatException('会话约束无效');
        }
        await _sessionStore.save(session);
        _session = session;
        _accountId = challenge.accountId;
        _setStatus(AuthStatus.authenticated);
      } finally {
        clearBytes(signature);
        clearBytes(digest);
      }
    } on Object {
      _setStatus(AuthStatus.failed);
    }
  }

  void resetError() {
    if (_status == AuthStatus.failed) _setStatus(AuthStatus.idle);
  }

  @override
  Future<BusinessProof> signBusinessPayload(Uint8List payload) async {
    final session = _session;
    final accountId = _accountId;
    if (_status != AuthStatus.authenticated ||
        session == null ||
        accountId == null ||
        !session.expiresAt.isAfter(_clock()) ||
        payload.isEmpty) {
      throw const BusinessProofUnavailable();
    }
    final signature = await _signer.sign(
      accountId: accountId,
      message: payload,
    );
    try {
      return BusinessProof(
        tuyuId: session.tuyuId,
        accountId: accountId,
        signature: bytesToHex(signature),
      );
    } finally {
      clearBytes(signature);
    }
  }

  void _validateChallenge(
    AuthChallenge challenge,
    String tuyuId,
    String deviceId,
  ) {
    if (challenge.tuyuId != tuyuId ||
        challenge.deviceId != deviceId ||
        challenge.audience != TuyuAuthApi.audience ||
        challenge.operation != 1 ||
        !challenge.expiresAt.isAfter(_clock())) {
      throw const FormatException('认证挑战约束无效');
    }
  }

  void _setStatus(AuthStatus value) {
    _status = value;
    notifyListeners();
  }
}
