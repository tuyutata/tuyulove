import 'dart:math';

String randomId(String prefix) {
  if (!RegExp(r'^[a-z]{2,8}$').hasMatch(prefix)) {
    throw ArgumentError.value(prefix, 'prefix', '标识前缀无效');
  }
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  return '${prefix}_${bytes.map((value) => value.toRadixString(16).padLeft(2, '0')).join()}';
}
