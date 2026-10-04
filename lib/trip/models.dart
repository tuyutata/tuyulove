final class TripPost {
  const TripPost({
    required this.id,
    required this.authorTuyuId,
    required this.title,
    required this.content,
    required this.mediaKeys,
    required this.createdAt,
  });

  factory TripPost.fromJson(Map<String, Object?> json) {
    final media = json['media_keys'];
    if (media is! List || media.any((item) => item is! String)) {
      throw const FormatException('游记媒体字段无效');
    }
    return TripPost(
      id: _string(json, 'trip_id'),
      authorTuyuId: _string(json, 'author_tuyu_id'),
      title: _string(json, 'title'),
      content: _string(json, 'content'),
      mediaKeys: media.cast<String>(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        _integer(json, 'created_at'),
        isUtc: true,
      ),
    );
  }

  final String id;
  final String authorTuyuId;
  final String title;
  final String content;
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
