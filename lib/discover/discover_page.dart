import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuyulove/discover/models.dart';
import 'package:tuyulove/l10n/app_localizations.dart';
import 'package:tuyulove/travel/travel_controller.dart';

final class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

final class _DiscoverPageState extends State<DiscoverPage> {
  final _query = TextEditingController();
  TravelCapability? _capability;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final controller = context.watch<TravelController>();
    return RefreshIndicator(
      onRefresh: () => controller.search(_query.text, _capability),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SearchBar(
            controller: _query,
            hintText: strings.searchHint,
            leading: const Icon(Icons.search),
            onSubmitted: (value) => controller.search(value, _capability),
          ),
          const SizedBox(height: 12),
          SegmentedButton<TravelCapability>(
            emptySelectionAllowed: true,
            segments: TravelCapability.values
                .map(
                  (item) => ButtonSegment(value: item, label: Text(item.name)),
                )
                .toList(growable: false),
            selected: _capability == null ? const {} : {_capability!},
            onSelectionChanged: (values) {
              setState(() => _capability = values.firstOrNull);
              controller.search(_query.text, _capability);
            },
          ),
          if (controller.busy) const LinearProgressIndicator(),
          if (controller.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(strings.operationFailed),
            ),
          if (!controller.busy && controller.listings.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text(strings.noData)),
            ),
          for (final listing in controller.listings)
            Card(
              child: ListTile(
                title: Text(listing.title),
                subtitle: Text('${listing.location}\n${listing.summary}'),
                isThreeLine: true,
                trailing: FilledButton.tonal(
                  onPressed: controller.busy
                      ? null
                      : () => controller.requestQuote(listing),
                  child: Text(strings.requestQuote),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
