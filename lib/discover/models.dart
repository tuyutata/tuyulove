enum TravelCapability {
  hotel,
  restaurant,
  tour,
  ticket;

  static TravelCapability parse(String value) =>
      TravelCapability.values.firstWhere(
        (item) => item.name == value,
        orElse: () => throw const FormatException('旅行服务分类无效'),
      );
}

final class DiscoveryListing {
  const DiscoveryListing({
    required this.id,
    required this.merchantInstanceId,
    required this.capability,
    required this.title,
    required this.summary,
    required this.location,
    required this.currency,
    required this.minimumAmount,
    required this.mediaUrl,
    required this.serviceEndpoint,
    required this.installationPublicKey,
    required this.sourceUpdatedAt,
    required this.expiresAt,
    required this.signedPayload,
    required this.signature,
  });

  factory DiscoveryListing.fromJson(Map<String, Object?> json) =>
      DiscoveryListing(
        id: _string(json, 'listing_id'),
        merchantInstanceId: _string(json, 'merchant_instance_id'),
        capability: TravelCapability.parse(_string(json, 'capability')),
        title: _string(json, 'title'),
        summary: json['summary'] is String
            ? json['summary']! as String
            : throw const FormatException(),
        location: json['location'] is String
            ? json['location']! as String
            : throw const FormatException(),
        currency: _string(json, 'currency'),
        minimumAmount: _integer(json, 'minimum_amount'),
        mediaUrl: json['media_url'] as String?,
        serviceEndpoint: Uri.parse(_string(json, 'service_endpoint')),
        installationPublicKey: _string(json, 'installation_public_key'),
        sourceUpdatedAt: _date(json, 'source_updated_at'),
        expiresAt: _date(json, 'expires_at'),
        signedPayload: _string(json, 'signed_payload'),
        signature: _string(json, 'signature'),
      );

  final String id;
  final String merchantInstanceId;
  final TravelCapability capability;
  final String title;
  final String summary;
  final String location;
  final String currency;
  final int minimumAmount;
  final String? mediaUrl;
  final Uri serviceEndpoint;
  final String installationPublicKey;
  final DateTime sourceUpdatedAt;
  final DateTime expiresAt;
  final String signedPayload;
  final String signature;
}

String _string(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String || value.isEmpty) throw FormatException('缺少字段：$key');
  return value;
}

int _integer(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! int) throw FormatException('字段类型无效：$key');
  return value;
}

DateTime _date(Map<String, Object?> json, String key) =>
    DateTime.fromMillisecondsSinceEpoch(_integer(json, key), isUtc: true);
