import 'dart:convert';
import 'dart:typed_data';

Uint8List concatBytes(Iterable<List<int>> parts) {
  final builder = BytesBuilder(copy: false);
  for (final part in parts) {
    builder.add(part);
  }
  return builder.takeBytes();
}

Uint8List scaleString(String value) {
  final encoded = utf8.encode(value);
  return concatBytes([scaleCompact(encoded.length), encoded]);
}

Uint8List scaleCompact(int value) {
  if (value < 0 || value >= 1 << 30) {
    throw RangeError.range(value, 0, (1 << 30) - 1, 'value');
  }
  if (value < 1 << 6) return Uint8List.fromList([value << 2]);
  if (value < 1 << 14) {
    final encoded = (value << 2) | 1;
    return Uint8List.fromList([encoded & 0xff, encoded >> 8]);
  }
  final encoded = (value << 2) | 2;
  return Uint8List.fromList([
    encoded & 0xff,
    (encoded >> 8) & 0xff,
    (encoded >> 16) & 0xff,
    (encoded >> 24) & 0xff,
  ]);
}

Uint8List uint64LittleEndian(int value) {
  if (value < 0) throw RangeError.value(value, 'value');
  final data = ByteData(8)..setUint64(0, value, Endian.little);
  return data.buffer.asUint8List();
}

String bytesToHex(List<int> bytes, {bool prefix = true}) {
  final value = bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
  return prefix ? '0x$value' : value;
}

Uint8List hexToBytes(String value) {
  final normalized = value.startsWith('0x') ? value.substring(2) : value;
  if (normalized.length.isOdd ||
      !RegExp(r'^[0-9a-fA-F]*$').hasMatch(normalized)) {
    throw const FormatException('十六进制字节格式无效');
  }
  return Uint8List.fromList([
    for (var index = 0; index < normalized.length; index += 2)
      int.parse(normalized.substring(index, index + 2), radix: 16),
  ]);
}

void clearBytes(List<int> bytes) {
  for (var index = 0; index < bytes.length; index++) {
    bytes[index] = 0;
  }
}
