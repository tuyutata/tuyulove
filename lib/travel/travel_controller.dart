import 'package:flutter/foundation.dart';
import 'package:tuyulove/auth/auth_model.dart';
import 'package:tuyulove/auth/business_proof.dart';
import 'package:tuyulove/booking/booking_api.dart';
import 'package:tuyulove/booking/models.dart';
import 'package:tuyulove/chat/chat_api.dart';
import 'package:tuyulove/chat/models.dart';
import 'package:tuyulove/discover/discover_api.dart';
import 'package:tuyulove/discover/models.dart';
import 'package:tuyulove/trip/models.dart';
import 'package:tuyulove/trip/trip_api.dart';

final class TravelController extends ChangeNotifier {
  TravelController(
    this._discovery,
    this._booking,
    this._chat,
    this._trip,
    this._session,
    this._signer,
  );

  final DiscoveryApi _discovery;
  final BookingApi _booking;
  final ChatApi _chat;
  final TripApi _trip;
  final AuthSession _session;
  final BusinessProofSigner _signer;

  bool busy = false;
  String? error;
  List<DiscoveryListing> listings = const [];
  List<TripPost> trips = const [];
  List<ChatConversation> conversations = const [];
  List<ChatMessage> chatMessages = const [];
  ChatConversation? selectedConversation;
  MerchantQuote? currentQuote;
  MerchantBooking? currentBooking;

  Future<void> load() => _run(() async {
    final values = await Future.wait<Object>([
      _discovery.search(),
      _trip.list(),
      _chat.conversations(_session.token),
    ]);
    listings = values[0] as List<DiscoveryListing>;
    trips = values[1] as List<TripPost>;
    conversations = values[2] as List<ChatConversation>;
  });

  Future<void> search(String query, TravelCapability? capability) => _run(
    () async {
      listings = await _discovery.search(query: query, capability: capability);
    },
  );

  Future<void> requestQuote(DiscoveryListing listing) => _run(() async {
    currentBooking = null;
    currentQuote = await _booking.quote(
      listing: listing,
      quantity: 1,
      requestedFor: DateTime.now().add(const Duration(days: 1)),
      signer: _signer,
    );
  });

  Future<void> confirmBooking() => _run(() async {
    final quote = currentQuote;
    if (quote == null) return;
    currentBooking = await _booking.book(quote: quote, signer: _signer);
  });

  Future<void> startConversation(String peerTuyuId) => _run(() async {
    final conversation = await _chat.createConversation(
      _session.token,
      peerTuyuId.trim(),
    );
    selectedConversation = conversation;
    conversations = await _chat.conversations(_session.token);
    chatMessages = await _chat.messages(_session.token, conversation.id, 0);
  });

  Future<void> selectConversation(ChatConversation conversation) =>
      _run(() async {
        selectedConversation = conversation;
        chatMessages = await _chat.messages(_session.token, conversation.id, 0);
      });

  Future<void> sendMessage(String content) => _run(() async {
    final conversation = selectedConversation;
    if (conversation == null || content.trim().isEmpty) return;
    await _chat.send(_session.token, conversation.id, content.trim());
    final after = chatMessages.isEmpty ? 0 : chatMessages.last.sequence;
    chatMessages = [
      ...chatMessages,
      ...await _chat.messages(_session.token, conversation.id, after),
    ];
  });

  Future<void> publishTrip(String title, String content) => _run(() async {
    await _trip.publish(
      _session.token,
      title: title.trim(),
      content: content.trim(),
    );
    trips = await _trip.list();
  });

  Future<void> _run(Future<void> Function() operation) async {
    if (busy) return;
    busy = true;
    error = null;
    notifyListeners();
    try {
      await operation();
    } on Object {
      error = 'operation_failed';
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
