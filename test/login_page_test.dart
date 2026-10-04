import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tuyulove/auth/auth_api.dart';
import 'package:tuyulove/auth/auth_controller.dart';
import 'package:tuyulove/auth/auth_model.dart';
import 'package:tuyulove/auth/login_page.dart';
import 'package:tuyulove/auth/tuyu_signer.dart';
import 'package:tuyulove/l10n/app_localizations.dart';
import 'package:tuyulove/session_store.dart';

final class _NeverApi implements AuthApi {
  @override
  Future<AuthChallenge> createChallenge({
    required String tuyuId,
    required String deviceId,
  }) => throw UnimplementedError();
  @override
  Future<AuthSession> createSession(AuthProof proof) =>
      throw UnimplementedError();
}

final class _NeverSigner implements TuyuSigner {
  @override
  Future<Uint8List> sign({
    required String accountId,
    required Uint8List message,
  }) => throw UnimplementedError();
}

final class _Store implements SessionStore {
  @override
  Future<void> clear() async {}
  @override
  Future<String> deviceId() async => 'device';
  @override
  Future<void> save(AuthSession session) async {}
}

void main() {
  testWidgets('shows Tuyu ID as the only login identifier', (tester) async {
    final controller = AuthController(
      api: _NeverApi(),
      signer: _NeverSigner(),
      sessionStore: _Store(),
    );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(
          locale: Locale('en'),
          supportedLocales: [Locale('en'), Locale('zh')],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: LoginPage(),
        ),
      ),
    );
    expect(find.text('Tuyu ID'), findsOneWidget);
    expect(find.textContaining('phone', findRichText: true), findsNothing);
    expect(find.textContaining('email', findRichText: true), findsNothing);
  });
}
