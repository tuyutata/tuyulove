import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuyulove/l10n/app_localizations.dart';
import 'package:tuyulove/travel/travel_controller.dart';

final class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

final class _ChatPageState extends State<ChatPage> {
  final _peer = TextEditingController();
  final _message = TextEditingController();

  @override
  void dispose() {
    _peer.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final controller = context.watch<TravelController>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _peer,
                decoration: InputDecoration(labelText: strings.peerTuyuId),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonal(
              onPressed: controller.busy
                  ? null
                  : () => controller.startConversation(_peer.text),
              child: Text(strings.startChat),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: controller.conversations
              .map(
                (conversation) => ChoiceChip(
                  label: Text(conversation.peerTuyuId),
                  selected:
                      controller.selectedConversation?.id == conversation.id,
                  onSelected: (_) =>
                      controller.selectConversation(conversation),
                ),
              )
              .toList(growable: false),
        ),
        const Divider(height: 32),
        for (final message in controller.chatMessages)
          ListTile(
            title: Text(message.content),
            subtitle: Text(message.senderTuyuId),
          ),
        if (controller.selectedConversation != null)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _message,
                  decoration: InputDecoration(labelText: strings.messageHint),
                ),
              ),
              IconButton(
                tooltip: strings.send,
                onPressed: controller.busy
                    ? null
                    : () async {
                        await controller.sendMessage(_message.text);
                        if (mounted && controller.error == null) {
                          _message.clear();
                        }
                      },
                icon: const Icon(Icons.send),
              ),
            ],
          ),
      ],
    );
  }
}
