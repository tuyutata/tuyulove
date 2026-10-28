import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tuyulove/discover/discover_api.dart';
import 'package:tuyulove/discover/models.dart';
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
    'listing_id': payload['listing_id'],
    'instance_id': payload['merchant_instance_id'],
    'service_kind': payload['capability'],
    'listing_title': payload['title'],
    'listing_summary': payload['summary'],
    'listing_location': payload['location'],
    'currency': payload['currency'],
    'minimum_amount': payload['minimum_amount'],
    'media_url': payload['media_url'],
    'service_endpoint': payload['service_endpoint'],
    'source_time': updatedAt,
    'expires_at': expiresAt,
    'instance_key': '0x${'3' * 64}',
    'signed_payload': base64Url
        .encode(utf8.encode(jsonEncode(payload)))
        .replaceAll('=', ''),
    'payload_signature': '0x${'4' * 128}',
  };
}

void main() {
  test(
    'accepts only a listing whose outer fields match its verified payload',
    () async {
      final api = TuyuDiscoveryApi(_Transport(listing()), _Verifier(true));
      final values = await api.search(query: '山海');
      expect(values.single.listingTitle, '山海酒店');
      expect(values.single.serviceEndpoint, Uri.parse('https://hotel.example'));
    },
  );

  test('rejects a tampered or unverified discovery listing', () async {
    final tampered = listing()..['listing_title'] = '被修改的标题';
    await expectLater(
      TuyuDiscoveryApi(_Transport(tampered), _Verifier(true)).search(),
      throwsFormatException,
    );
    await expectLater(
      TuyuDiscoveryApi(_Transport(listing()), _Verifier(false)).search(),
      throwsFormatException,
    );
  });

  test('缺少规范字段时不读取旧字段作为回退', () {
    final old = listing()..remove('instance_id');
    old['merchant_instance_id'] = 'tmi_${'2' * 32}';
    expect(() => DiscoveryListing.fromJson(old), throwsFormatException);
  });
}
