final class TripPost {
  const TripPost({
    required this.tripId,
    required this.authorId,
    required this.postTitle,
    required this.postBody,
    required this.mediaKeys,
    required this.createdAt,
  });

  factory TripPost.fromJson(Map<String, Object?> json) {
    final media = json['media_keys'];
    if (media is! List || media.any((item) => item is! String)) {
      throw const FormatException('游记媒体字段无效');
    }
    return TripPost(
      tripId: _string(json, 'trip_id'),
      authorId: _string(json, 'author_id'),
      postTitle: _string(json, 'post_title'),
      postBody: _string(json, 'post_body'),
      mediaKeys: media.cast<String>(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        _integer(json, 'created_at'),
        isUtc: true,
      ),
    );
  }

  final String tripId;
  final String authorId;
  final String postTitle;
  final String postBody;
  final List<String> mediaKeys;
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
