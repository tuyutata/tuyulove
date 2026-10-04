final class ChatConversation {
  const ChatConversation({
    required this.id,
    required this.peerTuyuId,
    required this.updatedAt,
  });

  factory ChatConversation.fromJson(Map<String, Object?> json) =>
      ChatConversation(
        id: _string(json, 'conversation_id'),
        peerTuyuId: _string(json, 'peer_tuyu_id'),
        updatedAt: _date(json, 'updated_at'),
      );

  final String id;
  final String peerTuyuId;
  final DateTime updatedAt;
}

final class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderTuyuId,
    required this.sequence,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, Object?> json) => ChatMessage(
    id: _string(json, 'message_id'),
    conversationId: _string(json, 'conversation_id'),
    senderTuyuId: _string(json, 'sender_tuyu_id'),
    sequence: _integer(json, 'sequence'),
    content: _string(json, 'content'),
    createdAt: _date(json, 'created_at'),
  );

  final String id;
  final String conversationId;
  final String senderTuyuId;
  final int sequence;
  final String content;
  final DateTime createdAt;
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
