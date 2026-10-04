import 'package:dio/dio.dart';

/// 商家实时接口独立于 TuyuServe；不向商家泄露 TuyuServe Bearer 会话。
abstract interface class MerchantApiTransport {
  Future<Map<String, Object?>> postSigned(
    String path,
    Map<String, Object?> body, {
    required String idempotencyKey,
  });
}

final class MerchantApiClient implements MerchantApiTransport {
  MerchantApiClient(Uri endpoint, {Dio? dio}) : _dio = dio ?? Dio() {
    if (endpoint.scheme != 'https' ||
        endpoint.host.isEmpty ||
        endpoint.userInfo.isNotEmpty) {
      throw ArgumentError.value(endpoint, 'endpoint', '商家接口必须使用有效 HTTPS 地址');
    }
    _dio.options = BaseOptions(
      baseUrl: endpoint.toString().replaceFirst(RegExp(r'/$'), ''),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 10),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      followRedirects: false,
      validateStatus: (status) =>
          status != null && status >= 200 && status < 300,
    );
  }

  final Dio _dio;

  @override
  Future<Map<String, Object?>> postSigned(
    String path,
    Map<String, Object?> body, {
    required String idempotencyKey,
  }) async {
    if (!path.startsWith('/tuyu/') || path.startsWith('//')) {
      throw ArgumentError.value(path, 'path', '商家 API 路径无效');
    }
    if (!RegExp(r'^[A-Za-z0-9._:-]{8,128}$').hasMatch(idempotencyKey)) {
      throw ArgumentError.value(idempotencyKey, 'idempotencyKey', '幂等键无效');
    }
    final response = await _dio.post<Object?>(
      path,
      data: body,
      options: Options(headers: {'idempotency-key': idempotencyKey}),
    );
    final data = response.data;
    if (data is! Map) throw const FormatException('商家响应格式无效');
    return data.map((key, value) => MapEntry(key.toString(), value));
  }
}
