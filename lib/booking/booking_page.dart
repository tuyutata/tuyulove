import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuyulove/l10n/app_localizations.dart';
import 'package:tuyulove/travel/travel_controller.dart';

final class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final controller = context.watch<TravelController>();
    final quote = controller.currentQuote;
    final booking = controller.currentBooking;
    if (quote == null) return Center(child: Text(strings.bookingEmpty));
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          quote.listing.title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Text(
          '${strings.quoteAmount}: ${quote.currency} ${(quote.amount / 100).toStringAsFixed(2)}',
        ),
        Text('${strings.quoteExpires}: ${quote.expiresAt.toLocal()}'),
        const SizedBox(height: 24),
        if (booking == null)
          FilledButton(
            onPressed: controller.busy ? null : controller.confirmBooking,
            child: Text(strings.confirmBooking),
          )
        else
          Card(
            child: ListTile(
              leading: const Icon(Icons.verified_outlined),
              title: Text('${strings.bookingId}: ${booking.id}'),
              subtitle: Text('${strings.bookingStatus}: ${booking.status}'),
            ),
          ),
      ],
    );
  }
}
