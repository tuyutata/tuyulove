import 'package:tuyulove/network/secure_api_client.dart';
import 'package:tuyulove/shared/ids.dart';
import 'package:tuyulove/trip/models.dart';

abstract interface class TripApi {
  Future<List<TripPost>> list();
  Future<TripPost> publish(
    String token, {
    required String title,
    required String content,
  });
}

final class TuyuTripApi implements TripApi {
  const TuyuTripApi(this._client);
  final TuyuApiTransport _client;

  @override
  Future<List<TripPost>> list() async {
    final response = await _client.publicGet('/v1/trips', query: {'limit': 30});
    final values = response['trips'];
    if (values is! List) throw const FormatException('游记列表格式无效');
    return values
        .map((value) {
          if (value is! Map) throw const FormatException('游记记录格式无效');
          return TripPost.fromJson(
            value.map((key, item) => MapEntry(key.toString(), item)),
          );
        })
        .toList(growable: false);
  }

  @override
  Future<TripPost> publish(
    String token, {
    required String title,
    required String content,
  }) async {
    final response = await _client.authorizedPost('/v1/trips', {
      'title': title,
      'content': content,
      'media_keys': <String>[],
      'idempotency_key': randomId('tpi'),
    }, token: token);
    final value = response['trip'];
    if (value is! Map) throw const FormatException('游记记录格式无效');
    return TripPost.fromJson(
      value.map((key, item) => MapEntry(key.toString(), item)),
    );
  }
}
