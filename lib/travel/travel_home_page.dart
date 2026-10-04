import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuyulove/auth/auth_controller.dart';
import 'package:tuyulove/booking/booking_api.dart';
import 'package:tuyulove/booking/booking_page.dart';
import 'package:tuyulove/chat/chat_api.dart';
import 'package:tuyulove/chat/chat_page.dart';
import 'package:tuyulove/discover/discover_api.dart';
import 'package:tuyulove/discover/discover_page.dart';
import 'package:tuyulove/l10n/app_localizations.dart';
import 'package:tuyulove/travel/travel_controller.dart';
import 'package:tuyulove/trip/trip_api.dart';
import 'package:tuyulove/trip/trip_page.dart';

final class TravelHomePage extends StatefulWidget {
  const TravelHomePage({super.key});

  @override
  State<TravelHomePage> createState() => _TravelHomePageState();
}

final class _TravelHomePageState extends State<TravelHomePage> {
  TravelController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final auth = context.read<AuthController>();
    final session = auth.session;
    if (session == null) return;
    _controller = TravelController(
      context.read<DiscoveryApi>(),
      context.read<BookingApi>(),
      context.read<ChatApi>(),
      context.read<TripApi>(),
      session,
      auth,
    )..load();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return const SizedBox.shrink();
    final strings = AppLocalizations.of(context);
    return ChangeNotifierProvider.value(
      value: controller,
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text(strings.appTitle),
            bottom: TabBar(
              tabs: [
                Tab(
                  icon: const Icon(Icons.explore_outlined),
                  text: strings.tabDiscover,
                ),
                Tab(
                  icon: const Icon(Icons.event_available_outlined),
                  text: strings.tabBooking,
                ),
                Tab(
                  icon: const Icon(Icons.chat_bubble_outline),
                  text: strings.tabChat,
                ),
                Tab(
                  icon: const Icon(Icons.auto_stories_outlined),
                  text: strings.tabTrips,
                ),
              ],
            ),
          ),
          body: const TabBarView(
            children: [DiscoverPage(), BookingPage(), ChatPage(), TripPage()],
          ),
        ),
      ),
    );
  }
}
