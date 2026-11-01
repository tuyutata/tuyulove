import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:citizen_sdk/citizen_sdk.dart';
import 'package:citizen_sdk/test/platform/fixture.dart';
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
      productId: 'tuyulove',
      operation: 1,
      deviceId: deviceId,
      expiresAt: now.add(const Duration(minutes: 5)),
    );
  }

  @override
  Future<AuthSession> createSession(AuthProof proof) async {
    return AuthSession(
      sessionToken: 'session',
      tuyuId: proof.challenge.tuyuId,
      expiresAt: now.add(const Duration(hours: 1)),
    );
  }
}

// 只替换App自己的签名角色，用于登录编排等待；SDK接线由下方真实Core测试验证。
final class _Signer implements TuyuSigner {
  Completer<Uint8List>? pending;
  String? accountId;
  Uint8List? payload;
  int calls = 0;

  @override
  Future<Uint8List> sign({
    required String accountId,
    required Uint8List message,
  }) async {
    calls++;
    this.accountId = accountId;
    payload = Uint8List.fromList(message);
    return pending == null ? Uint8List(64) : await pending!.future;
  }
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
  TestWidgetsFlutterBinding.ensureInitialized();
  final fixture = CitizenSdkTestFixture();
  setUp(fixture.install);
  tearDown(fixture.dispose);
  test('公开SDK真实签名可验，旧本地签名依赖删除', () async {
    final sdk = await CitizenSdk.open(
      modules: CitizenSdkModules.wallet | CitizenSdkModules.signing,
    );
    try {
      expect(fixture.vault(fixture.handles.values.single, 1), 0);
      final prepared = await sdk
          .prepareWalletCreation(wordCount: CitizenWalletWordCount.words12)
          .result;
      try {
        final profile = await prepared.commit().result;
        final payload = Uint8List.fromList([1, 2, 3]);
        final signature = await CitizenSdkTuyuSigner(
          sdk,
        ).sign(accountId: profile.masterAccountId, message: payload);
        expect(signature, hasLength(64));
        expect(
          await CitizenSdk.verify(
            accountId: profile.masterAccountId,
            payload: payload,
            signature: signature,
          ),
          isTrue,
        );
        expect(
          await CitizenSdk.verify(
            accountId: profile.masterAccountId,
            payload: Uint8List.fromList([1, 2, 4]),
            signature: signature,
          ),
          isFalse,
        );
      } finally {
        await prepared.release();
      }
    } finally {
      await sdk.close();
    }
    expect(fixture.calls.where((method) => method != 'diagnose'), [
      'open',
      'close',
    ]);
    expect(Directory('packages').existsSync(), isFalse);
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('citizen_sdk:'));
    for (final removed in ['tuyu_native_signer', 'tuyu_hardware_secretvault']) {
      expect(pubspec, isNot(contains(removed)));
    }
  });

  test('登录等待签名结果，忙碌期间不重复提交', () async {
    final now = DateTime.utc(2026, 8, 24);
    final signing = _Signer()..pending = Completer<Uint8List>();
    final store = _Store();
    final controller = AuthController(
      api: _Api(now),
      signer: signing,
      sessionStore: store,
      clock: () => now,
    );
    addTearDown(controller.dispose);
    var completed = false;
    final result = controller.login('TUYU-1').then((_) => completed = true);
    await Future<void>.delayed(Duration.zero);
    expect(completed, isFalse);
    expect(store.saved, isNull);
    expect(controller.status, AuthStatus.signing);
    await controller.login('TUYU-1');
    expect(signing.calls, 1);
    expect(
      signing.accountId,
      citizenAccountIdFromBytes(List<int>.filled(32, 0x11)),
    );
    expect(signing.payload, hasLength(32));
    signing.pending!.complete(Uint8List(64));
    await result;
    expect(controller.status, AuthStatus.authenticated);
    expect(store.saved?.sessionToken, 'session');
    expect(signing.calls, 1);
  });

  test('本地签名未就绪时SDK真实类别和阶段原样传播', () async {
    final sdk = await CitizenSdk.open(modules: CitizenSdkModules.qr);
    try {
      await expectLater(
        CitizenSdkTuyuSigner(sdk).sign(
          accountId: citizenAccountIdFromBytes(List<int>.filled(32, 0x11)),
          message: Uint8List.fromList([1]),
        ),
        throwsA(
          isA<CitizenSdkException>()
              .having(
                (error) => error.code,
                '真实Core错误',
                CitizenSdkErrorCode.notReady,
              )
              .having(
                (error) => error.stage,
                '真实Core阶段',
                CitizenSdkFailureStage.admission,
              ),
        ),
      );
    } finally {
      await sdk.close();
    }
    expect(fixture.calls.where((method) => method != 'diagnose'), [
      'open',
      'close',
    ]);
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
    expect(store.saved?.sessionToken, 'session');
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
