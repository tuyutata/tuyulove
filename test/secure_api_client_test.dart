import 'package:flutter_test/flutter_test.dart';
import 'package:tuyulove/network/secure_api_client.dart';
import 'package:tuyulove/trip/models.dart';
import 'package:tuyulove/chat/models.dart';

void main() {
  test('rejects an insecure service endpoint', () {
    expect(
      () => SecureApiClient(Uri.parse('http://serve.tuyulove.com')),
      throwsArgumentError,
    );
  });

  test('accepts an HTTPS service endpoint', () {
    expect(
      () => SecureApiClient(Uri.parse('https://serve.tuyulove.com')),
      returnsNormally,
    );
  });

  test('游记和聊天消费模型只保留各自唯一身份字段', () {
    final trip = TripPost.fromJson({
      'trip_id': 'trip-1',
      'author_id': 'TUYU-1',
      'post_title': '标题',
      'post_body': '正文',
      'media_keys': <String>[],
      'created_at': 1800000000000,
    });
    expect(trip.tripId, 'trip-1');
    expect(trip.authorId, 'TUYU-1');
    expect(trip.postTitle, '标题');
    expect(trip.postBody, '正文');
    final conversation = ChatConversation.fromJson({
      'conversation_id': 'chat-1',
      'peer_tuyu_id': 'TUYU-2',
      'updated_at': 1800000000000,
    });
    final message = ChatMessage.fromJson({
      'message_id': 'message-1',
      'conversation_id': 'chat-1',
      'sender_tuyu_id': 'TUYU-2',
      'sequence': 1,
      'content': '消息',
      'created_at': 1800000000000,
    });
    expect(conversation.conversationId, 'chat-1');
    expect(message.messageId, 'message-1');
    expect(message.conversationId, conversation.conversationId);
  });
}
