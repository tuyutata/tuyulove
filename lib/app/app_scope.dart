import 'dart:async';

import 'package:citizen_sdk/citizen_sdk.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:tuyulove/auth/auth_api.dart';
import 'package:tuyulove/auth/auth_controller.dart';
import 'package:tuyulove/auth/tuyu_signer.dart';
import 'package:tuyulove/booking/booking_api.dart';
import 'package:tuyulove/chat/chat_api.dart';
import 'package:tuyulove/discover/discover_api.dart';
import 'package:tuyulove/network/secure_api_client.dart';
import 'package:tuyulove/session_store.dart';
import 'package:tuyulove/trip/trip_api.dart';

final class AppScope extends StatefulWidget {
  const AppScope({
    required this.serviceEndpoint,
    required this.citizenSdk,
    required this.child,
    super.key,
  });
  final String serviceEndpoint;
  final CitizenSdk citizenSdk;
  final Widget child;

  @override
  State<AppScope> createState() => _AppScopeState();
}

final class _AppScopeState extends State<AppScope> {
  late final AuthController _controller;
  late final SecureApiClient _client;
  late final DiscoverySignatureVerifier _signatureVerifier;

  @override
  void initState() {
    super.initState();
    final endpoint = Uri.tryParse(widget.serviceEndpoint);
    _client = SecureApiClient(
      endpoint != null && widget.serviceEndpoint.isNotEmpty
          ? endpoint
          : Uri.parse('https://unavailable.invalid'),
    );
    _signatureVerifier = CitizenSdkDiscoverySignatureVerifier();
    final AuthApi api = endpoint == null || widget.serviceEndpoint.isEmpty
        ? const UnavailableAuthApi()
        : TuyuAuthApi(_client);
    _controller = AuthController(
      api: api,
      signer: CitizenSdkTuyuSigner(widget.citizenSdk.signing),
      sessionStore: SecureSessionStore(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    unawaited(widget.citizenSdk.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(value: _controller),
        Provider<DiscoveryApi>(
          create: (_) => TuyuDiscoveryApi(_client, _signatureVerifier),
        ),
        Provider<BookingApi>(
          create: (_) => DirectMerchantBookingApi(_signatureVerifier),
        ),
        Provider<ChatApi>(create: (_) => TuyuChatApi(_client)),
        Provider<TripApi>(create: (_) => TuyuTripApi(_client)),
      ],
      child: widget.child,
    );
  }
}
