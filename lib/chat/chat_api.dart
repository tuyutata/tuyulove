import 'package:tuyulove/chat/models.dart';
import 'package:tuyulove/network/secure_api_client.dart';
import 'package:tuyulove/shared/ids.dart';

abstract interface class ChatApi {
  Future<List<ChatConversation>> conversations(String token);
  Future<ChatConversation> createConversation(String token, String peerTuyuId);
  Future<List<ChatMessage>> messages(
    String token,
    String conversationId,
    int after,
  );
  Future<ChatMessage> send(String token, String conversationId, String content);
}

final class TuyuChatApi implements ChatApi {
  const TuyuChatApi(this._client);
  final AuthenticatedApiTransport _client;

  @override
  Future<List<ChatConversation>> conversations(String token) async {
    final response = await _client.authorizedGet(
      '/v1/chat/conversations',
      token: token,
    );
    return _list(
      response,
      'conversations',
    ).map(ChatConversation.fromJson).toList(growable: false);
  }

  @override
  Future<ChatConversation> createConversation(
    String token,
    String peerTuyuId,
  ) async {
    final response = await _client.authorizedPost('/v1/chat/conversations', {
      'peer_tuyu_id': peerTuyuId,
      'idempotency_key': randomId('tci'),
    }, token: token);
    return ChatConversation.fromJson(_map(response, 'conversation'));
  }

  @override
  Future<List<ChatMessage>> messages(
    String token,
    String conversationId,
    int after,
  ) async {
    final response = await _client.authorizedGet(
      '/v1/chat/conversations/$conversationId/messages',
      token: token,
      query: {'after': after},
    );
    return _list(
      response,
      'messages',
    ).map(ChatMessage.fromJson).toList(growable: false);
  }

  @override
  Future<ChatMessage> send(
    String token,
    String conversationId,
    String content,
  ) async {
    final response = await _client.authorizedPost(
      '/v1/chat/conversations/$conversationId/messages',
      {'content': content, 'idempotency_key': randomId('tmi')},
      token: token,
    );
    return ChatMessage.fromJson(_map(response, 'message'));
  }
}

Map<String, Object?> _map(Map<String, Object?> document, String key) {
  final value = document[key];
  if (value is! Map) throw FormatException('字段格式无效：$key');
  return value.map((name, item) => MapEntry(name.toString(), item));
}

List<Map<String, Object?>> _list(Map<String, Object?> document, String key) {
  final value = document[key];
  if (value is! List) throw FormatException('字段格式无效：$key');
  return value
      .map((item) {
        if (item is! Map) throw FormatException('列表格式无效：$key');
        return item.map((name, child) => MapEntry(name.toString(), child));
      })
      .toList(growable: false);
}
