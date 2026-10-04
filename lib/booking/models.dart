import 'package:tuyulove/discover/models.dart';

final class MerchantQuote {
  const MerchantQuote({
    required this.id,
    required this.listing,
    required this.quantity,
    required this.amount,
    required this.currency,
    required this.expiresAt,
  });

  final String id;
  final DiscoveryListing listing;
  final int quantity;
  final int amount;
  final String currency;
  final DateTime expiresAt;
}

final class MerchantBooking {
  const MerchantBooking({
    required this.id,
    required this.quoteId,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String quoteId;
  final String status;
  final DateTime createdAt;
}
