import 'dart:convert';
import 'dart:typed_data';

import 'package:tuyulove/auth/business_proof.dart';
import 'package:tuyulove/booking/models.dart';
import 'package:tuyulove/discover/discover_api.dart';
import 'package:tuyulove/discover/models.dart';
import 'package:tuyulove/network/merchant_api_client.dart';
import 'package:tuyulove/shared/bytes.dart';
import 'package:tuyulove/shared/ids.dart';

abstract interface class BookingApi {
  Future<MerchantQuote> quote({
    required DiscoveryListing listing,
    required int quantity,
    required DateTime requestedFor,
    required BusinessProofSigner signer,
  });

  Future<MerchantBooking> book({
    required MerchantQuote quote,
    required BusinessProofSigner signer,
  });
}

typedef MerchantClientFactory = MerchantApiTransport Function(Uri endpoint);

final class DirectMerchantBookingApi implements BookingApi {
  DirectMerchantBookingApi(
    this._verifier, {
    MerchantClientFactory? clientFactory,
  }) : _clientFactory = clientFactory ?? MerchantApiClient.new;

  final DiscoverySignatureVerifier _verifier;
  final MerchantClientFactory _clientFactory;

  @override
  Future<MerchantQuote> quote({
    required DiscoveryListing listing,
    required int quantity,
    required DateTime requestedFor,
    required BusinessProofSigner signer,
  }) async {
    if (quantity < 1 ||
        quantity > 99 ||
        !requestedFor.isAfter(DateTime.now())) {
      throw ArgumentError('报价数量或日期无效');
    }
    final requestId = randomId('tqr');
    final payload = Uint8List.fromList(
      utf8.encode(
        jsonEncode({
          'action': 'quote',
          'request_id': requestId,
          'listing_id': listing.id,
          'quantity': quantity,
          'requested_for': requestedFor.toUtc().toIso8601String(),
        }),
      ),
    );
    final proof = await signer.signBusinessPayload(payload);
    final response = await _clientFactory(listing.serviceEndpoint).postSigned(
      '/tuyu/v1/quotes',
      _envelope(payload, proof),
      idempotencyKey: requestId,
    );
    final decoded = await _verifyResponse(response, listing);
    if (decoded['kind'] != 'quote' ||
        decoded['listing_id'] != listing.id ||
        decoded['quantity'] != quantity) {
      throw const FormatException('商家报价约束无效');
    }
    final expiresAt = _date(decoded, 'expires_at');
    if (!expiresAt.isAfter(DateTime.now().toUtc())) {
      throw const FormatException('商家报价已经过期');
    }
    return MerchantQuote(
      id: _string(decoded, 'quote_id'),
      listing: listing,
      quantity: quantity,
      amount: _integer(decoded, 'amount'),
      currency: _string(decoded, 'currency'),
      expiresAt: expiresAt,
    );
  }

  @override
  Future<MerchantBooking> book({
    required MerchantQuote quote,
    required BusinessProofSigner signer,
  }) async {
    if (!quote.expiresAt.isAfter(DateTime.now().toUtc())) {
      throw const FormatException('商家报价已经过期');
    }
    final requestId = randomId('tbk');
    final payload = Uint8List.fromList(
      utf8.encode(
        jsonEncode({
          'action': 'booking',
          'request_id': requestId,
          'listing_id': quote.listing.id,
          'quote_id': quote.id,
        }),
      ),
    );
    final proof = await signer.signBusinessPayload(payload);
    final response = await _clientFactory(quote.listing.serviceEndpoint)
        .postSigned(
          '/tuyu/v1/bookings',
          _envelope(payload, proof),
          idempotencyKey: requestId,
        );
    final decoded = await _verifyResponse(response, quote.listing);
    if (decoded['kind'] != 'booking' || decoded['quote_id'] != quote.id) {
      throw const FormatException('商家预订约束无效');
    }
    return MerchantBooking(
      id: _string(decoded, 'booking_id'),
      quoteId: quote.id,
      status: _string(decoded, 'status'),
      createdAt: _date(decoded, 'created_at'),
    );
  }

  Map<String, Object?> _envelope(Uint8List payload, BusinessProof proof) => {
    'signed_payload': base64Url.encode(payload).replaceAll('=', ''),
    'signature': proof.signature,
    'account_id': proof.accountId,
    'tuyu_id': proof.tuyuId,
  };

  Future<Map<String, Object?>> _verifyResponse(
    Map<String, Object?> response,
    DiscoveryListing listing,
  ) async {
    final encoded = _string(response, 'signed_payload');
    final payload = Uint8List.fromList(
      base64Url.decode(base64Url.normalize(encoded)),
    );
    final signature = hexToBytes(_string(response, 'signature'));
    if (!await _verifier.verify(
      publicKey: hexToBytes(listing.installationPublicKey),
      payload: payload,
      signature: signature,
    )) {
      throw const FormatException('商家响应签名无效');
    }
    final decoded = jsonDecode(utf8.decode(payload, allowMalformed: false));
    if (decoded is! Map) throw const FormatException('商家响应载荷无效');
    return Map<String, Object?>.fromEntries(
      decoded.entries.map(
        (entry) => MapEntry(entry.key.toString(), entry.value),
      ),
    );
  }
}

String _string(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String || value.isEmpty) throw FormatException('缺少字段：$key');
  return value;
}

int _integer(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! int || value < 0) throw FormatException('字段类型无效：$key');
  return value;
}

DateTime _date(Map<String, Object?> json, String key) =>
    DateTime.fromMillisecondsSinceEpoch(_integer(json, key), isUtc: true);
