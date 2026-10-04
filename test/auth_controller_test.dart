import 'dart:io';
import 'dart:typed_data';

import 'package:citizen_sdk/citizen_sdk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuyulove/auth/auth_api.dart';
import 'package:tuyulove/auth/auth_controller.dart';
import 'package:tuyulove/auth/auth_model.dart';
import 'package:tuyulove/auth/tuyu_signer.dart';
import 'package:tuyulove/session_store.dart';

final class _Api implements AuthApi {
  _Api(this.now);
  final DateTime now;

  @override
  Future<AuthChallenge> createChallenge({
    required String tuyuId,
    required String deviceId,
  }) async {
    return AuthChallenge(
      challengeId: 'challenge-1',
      tuyuId: tuyuId,
      accountId: '0x${'11' * 32}',
      keyRevision: 1,
      audience: 'tuyulove',
      operation: 1,
      deviceId: deviceId,
      expiresAt: now.add(const Duration(minutes: 5)),
    );
  }

  @override
  Future<AuthSession> createSession(AuthProof proof) async {
    return AuthSession(
      token: 'session',
      tuyuId: proof.challenge.tuyuId,
      expiresAt: now.add(const Duration(hours: 1)),
    );
  }
}

final class _Signer implements TuyuSigner {
  @override
  Future<Uint8List> sign({
    required String accountId,
    required Uint8List message,
  }) async => Uint8List(64);
}

final class _CitizenSigning implements CitizenSigning {
  String? accountId;
  Uint8List? payload;

  @override
  Future<CitizenWalletSignature> sign({
    required String accountId,
    required Uint8List payload,
  }) async {
    this.accountId = accountId;
    this.payload = Uint8List.fromList(payload);
    return CitizenWalletSignature(accountId: accountId, bytes: Uint8List(64));
  }

  @override
  Future<CitizenQrSigned> signQrRequest(String signRequest) =>
      throw UnimplementedError();

  @override
  Future<CitizenSigningOutcome> begin(CitizenSigningIntent intent) =>
      throw UnimplementedError();

  @override
  Future<CitizenSigningCompleted> consumeExternalSignature({
    required String sessionId,
    required String response,
  }) => throw UnimplementedError();

  @override
  Future<bool> cancel(String sessionId) async => false;
}

final class _Store implements SessionStore {
  AuthSession? saved;

  @override
  Future<void> clear() async {}

  @override
  Future<String> deviceId() async => 'device-1';

  @override
  Future<void> save(AuthSession session) async => saved = session;
}

void main() {
  test('只通过CitizenSDK签名且packages目录和旧依赖完全删除', () async {
    final signing = _CitizenSigning();
    final payload = Uint8List.fromList([1, 2, 3]);
    final signature = await CitizenSdkTuyuSigner(signing)
        .sign(accountId: '0x${'11' * 32}', message: payload);
    expect(signing.accountId, '0x${'11' * 32}');
    expect(signing.payload, payload);
    expect(signature, hasLength(64));
    expect(Directory('packages').existsSync(), isFalse);
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('citizen_sdk:'));
    for (final removed in ['tuyu_native_signer', 'tuyu_hardware_secretvault']) {
      expect(pubspec, isNot(contains(removed)));
    }
  });

  test('completes direct local-signature login', () async {
    final now = DateTime.utc(2026, 8, 24);
    final store = _Store();
    final controller = AuthController(
      api: _Api(now),
      signer: _Signer(),
      sessionStore: store,
      clock: () => now,
    );
    await controller.login('TUYU-1');
    expect(controller.status, AuthStatus.authenticated);
    expect(store.saved?.token, 'session');
  });

  test('does not start login for an empty Tuyu ID', () async {
    final now = DateTime.utc(2026, 8, 24);
    final controller = AuthController(
      api: _Api(now),
      signer: _Signer(),
      sessionStore: _Store(),
      clock: () => now,
    );
    await controller.login('  ');
    expect(controller.status, AuthStatus.idle);
  });
}
