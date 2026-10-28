import 'dart:convert';
import 'dart:typed_data';

import 'package:citizen_sdk/citizen_sdk.dart';
import 'package:tuyulove/discover/models.dart';
import 'package:tuyulove/network/secure_api_client.dart';
import 'package:tuyulove/shared/bytes.dart';

abstract interface class DiscoveryApi {
  Future<List<DiscoveryListing>> search({
    String query = '',
    ServiceKind? serviceKind,
  });
}

abstract interface class DiscoverySignatureVerifier {
  Future<bool> verify({
    required Uint8List publicKey,
    required Uint8List payload,
    required Uint8List signature,
  });
}

final class CitizenSdkDiscoverySignatureVerifier
    implements DiscoverySignatureVerifier {
  @override
  Future<bool> verify({
    required Uint8List publicKey,
    required Uint8List payload,
    required Uint8List signature,
  }) => CitizenSigning.verify(
    accountId: bytesToHex(publicKey),
    signature: signature,
    payload: payload,
  );
}

final class TuyuDiscoveryApi implements DiscoveryApi {
  const TuyuDiscoveryApi(this._client, this._verifier);

  final PublicApiTransport _client;
  final DiscoverySignatureVerifier _verifier;

  @override
  Future<List<DiscoveryListing>> search({
    String query = '',
    ServiceKind? serviceKind,
  }) async {
    final document = await _client.publicGet(
      '/v1/catalog',
      query: {
        if (query.trim().isNotEmpty) 'q': query.trim(),
        if (serviceKind != null) 'service_kind': serviceKind.name,
        'limit': 30,
      },
    );
    final values = document['listings'];
    if (values is! List) throw const FormatException('发现列表格式无效');
    final listings = <DiscoveryListing>[];
    for (final value in values) {
      if (value is! Map) throw const FormatException('发现记录格式无效');
      final listing = DiscoveryListing.fromJson(
        value.map((key, item) => MapEntry(key.toString(), item)),
      );
      await _verifyListing(listing);
      listings.add(listing);
    }
    return List.unmodifiable(listings);
  }

  Future<void> _verifyListing(DiscoveryListing listing) async {
    try {
      final payload = base64Url.decode(
        base64Url.normalize(listing.signedPayload),
      );
      final decoded = jsonDecode(utf8.decode(payload, allowMalformed: false));
      if (decoded is! Map) throw const FormatException();
      final json = decoded.map((key, value) => MapEntry(key.toString(), value));
      final matches =
          json['listing_id'] == listing.listingId &&
          json['merchant_instance_id'] == listing.instanceId &&
          json['capability'] == listing.serviceKind.name &&
          json['title'] == listing.listingTitle &&
          json['summary'] == listing.listingSummary &&
          json['location'] == listing.listingLocation &&
          json['currency'] == listing.currency &&
          json['minimum_amount'] == listing.minimumAmount &&
          json['media_url'] == listing.mediaUrl &&
          json['service_endpoint'] == listing.serviceEndpoint.toString() &&
          json['source_updated_at'] ==
              listing.sourceTime.millisecondsSinceEpoch &&
          json['expires_at'] == listing.expiresAt.millisecondsSinceEpoch;
      if (!matches ||
          listing.serviceEndpoint.scheme != 'https' ||
          !listing.expiresAt.isAfter(DateTime.now().toUtc()) ||
          !await _verifier.verify(
            publicKey: hexToBytes(listing.instanceKey),
            payload: Uint8List.fromList(payload),
            signature: hexToBytes(listing.payloadSignature),
          )) {
        throw const FormatException();
      }
    } on Object {
      throw const FormatException('发现摘要签名或内容无效');
    }
  }
}
