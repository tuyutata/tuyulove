import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tuyulove/discover/discover_api.dart';
import 'package:tuyulove/network/secure_api_client.dart';

final class _Transport implements PublicApiTransport {
  _Transport(this.listing);
  final Map<String, Object?> listing;

  @override
  Future<Map<String, Object?>> publicGet(
    String path, {
    Map<String, Object?> query = const {},
  }) async => {
    'listings': [listing],
  };
}

final class _Verifier implements DiscoverySignatureVerifier {
  _Verifier(this.result);
  final bool result;

  @override
  Future<bool> verify({
    required Uint8List publicKey,
    required Uint8List payload,
    required Uint8List signature,
  }) async => result;
}

Map<String, Object?> listing() {
  final updatedAt = DateTime.now().toUtc().millisecondsSinceEpoch;
  final expiresAt = updatedAt + const Duration(days: 1).inMilliseconds;
  final payload = {
    'listing_id': 'tli_${'1' * 32}',
    'merchant_instance_id': 'tmi_${'2' * 32}',
    'capability': 'hotel',
    'title': '山海酒店',
    'summary': '海边客房',
    'location': '青岛',
    'currency': 'CNY',
    'minimum_amount': 68800,
    'media_url': null,
    'service_endpoint': 'https://hotel.example',
    'source_updated_at': updatedAt,
    'expires_at': expiresAt,
  };
  return {
    ...payload,
    'installation_public_key': '0x${'3' * 64}',
    'signed_payload': base64Url
        .encode(utf8.encode(jsonEncode(payload)))
        .replaceAll('=', ''),
    'signature': '0x${'4' * 128}',
  };
}

void main() {
  test(
    'accepts only a listing whose outer fields match its verified payload',
    () async {
      final api = TuyuDiscoveryApi(_Transport(listing()), _Verifier(true));
      final values = await api.search(query: '山海');
      expect(values.single.title, '山海酒店');
      expect(values.single.serviceEndpoint, Uri.parse('https://hotel.example'));
    },
  );

  test('rejects a tampered or unverified discovery listing', () async {
    final tampered = listing()..['title'] = '被修改的标题';
    await expectLater(
      TuyuDiscoveryApi(_Transport(tampered), _Verifier(true)).search(),
      throwsFormatException,
    );
    await expectLater(
      TuyuDiscoveryApi(_Transport(listing()), _Verifier(false)).search(),
      throwsFormatException,
    );
  });
}
