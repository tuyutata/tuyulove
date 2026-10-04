import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuyulove/l10n/app_localizations.dart';
import 'package:tuyulove/travel/travel_controller.dart';

final class TripPage extends StatefulWidget {
  const TripPage({super.key});

  @override
  State<TripPage> createState() => _TripPageState();
}

final class _TripPageState extends State<TripPage> {
  final _title = TextEditingController();
  final _content = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final controller = context.watch<TravelController>();
    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _title,
            decoration: InputDecoration(labelText: strings.tripTitle),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _content,
            maxLines: 4,
            decoration: InputDecoration(labelText: strings.tripContent),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: controller.busy
                ? null
                : () async {
                    await controller.publishTrip(_title.text, _content.text);
                    if (mounted && controller.error == null) {
                      _title.clear();
                      _content.clear();
                    }
                  },
            child: Text(strings.publishTrip),
          ),
          const Divider(height: 32),
          if (!controller.busy && controller.trips.isEmpty)
            Center(child: Text(strings.noData)),
          for (final trip in controller.trips)
            Card(
              child: ListTile(
                title: Text(trip.title),
                subtitle: Text('${trip.authorTuyuId}\n${trip.content}'),
                isThreeLine: true,
              ),
            ),
        ],
      ),
    );
  }
}
