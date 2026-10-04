// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TuyuLove';

  @override
  String get brandMark => 'TUYU · LOVE';

  @override
  String get loginTitle => 'Your next journey starts here.';

  @override
  String get loginSubtitle =>
      'Use your one Tuyu ID across travel and merchant services.';

  @override
  String get tuyuIdLabel => 'Tuyu ID';

  @override
  String get loginAction => 'Sign in securely';

  @override
  String get localSigningHint =>
      'Your identity key stays in this device\'s protected storage. Every sign-in is signed locally with sr25519.';

  @override
  String get loginError =>
      'Sign-in could not be verified. Check your Tuyu ID and local identity key.';

  @override
  String get loginSuccess => 'Identity verified. Welcome to TuyuLove.';

  @override
  String get tabDiscover => 'Discover';

  @override
  String get tabBooking => 'Booking';

  @override
  String get tabChat => 'Chat';

  @override
  String get tabTrips => 'Trips';

  @override
  String get searchHint => 'Search hotels, restaurants, tours, or tickets';

  @override
  String get operationFailed =>
      'The operation failed. Check the network or service and try again.';

  @override
  String get noData => 'No content yet';

  @override
  String get requestQuote => 'Live quote';

  @override
  String get bookingEmpty =>
      'Choose a service in Discover and request a live quote first.';

  @override
  String get quoteAmount => 'Live quote';

  @override
  String get quoteExpires => 'Quote expires';

  @override
  String get confirmBooking => 'Confirm booking';

  @override
  String get bookingId => 'Booking ID';

  @override
  String get bookingStatus => 'Status';

  @override
  String get peerTuyuId => 'Peer Tuyu ID';

  @override
  String get startChat => 'Start chat';

  @override
  String get messageHint => 'Message';

  @override
  String get send => 'Send';

  @override
  String get tripTitle => 'Trip title';

  @override
  String get tripContent => 'Write about this journey';

  @override
  String get publishTrip => 'Publish trip';
}
