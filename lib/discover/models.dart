enum ServiceKind {
  hotel,
  restaurant,
  tour,
  ticket;

  static ServiceKind parse(String value) => ServiceKind.values.firstWhere(
    (item) => item.name == value,
    orElse: () => throw const FormatException('旅行服务分类无效'),
  );
}

/// 发现字段与服务端同词根；Dart使用lowerCamelCase，原始JSON使用snake_case。
final class DiscoveryListing {
  const DiscoveryListing({
    required this.listingId,
    required this.instanceId,
    required this.serviceKind,
    required this.listingTitle,
    required this.listingSummary,
    required this.listingLocation,
    required this.currency,
    required this.minimumAmount,
    required this.mediaUrl,
    required this.serviceEndpoint,
    required this.instanceKey,
    required this.sourceTime,
    required this.expiresAt,
    required this.signedPayload,
    required this.payloadSignature,
  });

  factory DiscoveryListing.fromJson(Map<String, Object?> json) =>
      DiscoveryListing(
        listingId: _string(json, 'listing_id'),
        instanceId: _string(json, 'instance_id'),
        serviceKind: ServiceKind.parse(_string(json, 'service_kind')),
        listingTitle: _string(json, 'listing_title'),
        listingSummary: json['listing_summary'] is String
            ? json['listing_summary']! as String
            : throw const FormatException(),
        listingLocation: json['listing_location'] is String
            ? json['listing_location']! as String
            : throw const FormatException(),
        currency: _string(json, 'currency'),
        minimumAmount: _integer(json, 'minimum_amount'),
        mediaUrl: json['media_url'] as String?,
        serviceEndpoint: Uri.parse(_string(json, 'service_endpoint')),
        instanceKey: _string(json, 'instance_key'),
        sourceTime: _date(json, 'source_time'),
        expiresAt: _date(json, 'expires_at'),
        signedPayload: _string(json, 'signed_payload'),
        payloadSignature: _string(json, 'payload_signature'),
      );

  final String listingId;
  final String instanceId;
  final ServiceKind serviceKind;
  final String listingTitle;
  final String listingSummary;
  final String listingLocation;
  final String currency;
  final int minimumAmount;
  final String? mediaUrl;
  final Uri serviceEndpoint;
  final String instanceKey;
  final DateTime sourceTime;
  final DateTime expiresAt;
  final String signedPayload;
  final String payloadSignature;
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
