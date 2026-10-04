import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tuyulove/auth/business_proof.dart';
import 'package:tuyulove/booking/booking_api.dart';
import 'package:tuyulove/discover/discover_api.dart';
import 'package:tuyulove/discover/models.dart';
import 'package:tuyulove/network/merchant_api_client.dart';

final class _Signer implements BusinessProofSigner {
  @override
  Future<BusinessProof> signBusinessPayload(Uint8List payload) async =>
      BusinessProof(
        tuyuId: 'TUYU-TRAVELER',
        accountId: '0x${'1' * 64}',
        signature: '0x${'2' * 128}',
      );
}

final class _Verifier implements DiscoverySignatureVerifier {
  @override
  Future<bool> verify({
    required Uint8List publicKey,
    required Uint8List payload,
    required Uint8List signature,
  }) async => true;
}

final class _Merchant implements MerchantApiTransport {
  final paths = <String>[];

  @override
  Future<Map<String, Object?>> postSigned(
    String path,
    Map<String, Object?> body, {
    required String idempotencyKey,
  }) async {
    paths.add(path);
    final payload = path.endsWith('quotes')
        ? {
            'kind': 'quote',
            'quote_id': 'quote-1',
            'listing_id': 'tli_${'3' * 32}',
            'quantity': 1,
            'amount': 68800,
            'currency': 'CNY',
            'expires_at': DateTime.now()
                .add(const Duration(minutes: 5))
                .millisecondsSinceEpoch,
          }
        : {
            'kind': 'booking',
            'booking_id': 'booking-1',
            'quote_id': 'quote-1',
            'status': 'confirmed',
            'created_at': DateTime.now().millisecondsSinceEpoch,
          };
    return {
      'signed_payload': base64Url
          .encode(utf8.encode(jsonEncode(payload)))
          .replaceAll('=', ''),
      'signature': '0x${'4' * 128}',
    };
  }
}

DiscoveryListing listing() => DiscoveryListing(
  id: 'tli_${'3' * 32}',
  merchantInstanceId: 'tmi_${'5' * 32}',
  capability: TravelCapability.hotel,
  title: '山海酒店',
  summary: '海边客房',
  location: '青岛',
  currency: 'CNY',
  minimumAmount: 68800,
  mediaUrl: null,
  serviceEndpoint: Uri.parse('https://hotel.example'),
  installationPublicKey: '0x${'6' * 64}',
  sourceUpdatedAt: DateTime.now().toUtc(),
  expiresAt: DateTime.now().toUtc().add(const Duration(days: 1)),
  signedPayload: 'e30',
  signature: '0x${'7' * 128}',
);

void main() {
  test(
    'requests a live quote and booking directly from the merchant endpoint',
    () async {
      final merchant = _Merchant();
      final api = DirectMerchantBookingApi(
        _Verifier(),
        clientFactory: (_) => merchant,
      );
      final quote = await api.quote(
        listing: listing(),
        quantity: 1,
        requestedFor: DateTime.now().add(const Duration(days: 1)),
        signer: _Signer(),
      );
      final booking = await api.book(quote: quote, signer: _Signer());
      expect(quote.amount, 68800);
      expect(booking.status, 'confirmed');
      expect(merchant.paths, ['/tuyu/v1/quotes', '/tuyu/v1/bookings']);
    },
  );
}
