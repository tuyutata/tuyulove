import 'package:dio/dio.dart';

abstract interface class SecureApiTransport {
  Future<Map<String, Object?>> post(String path, Map<String, Object?> body);
}

abstract interface class PublicApiTransport {
  Future<Map<String, Object?>> publicGet(
    String path, {
    Map<String, Object?> query = const {},
  });
}

abstract interface class AuthenticatedApiTransport {
  Future<Map<String, Object?>> authorizedGet(
    String path, {
    required String token,
    Map<String, Object?> query = const {},
  });

  Future<Map<String, Object?>> authorizedPost(
    String path,
    Map<String, Object?> body, {
    required String token,
  });
}

abstract interface class TuyuApiTransport
    implements PublicApiTransport, AuthenticatedApiTransport {}

/// 唯一服务网络入口。构造时拒绝非 HTTPS 地址，且禁止自动跟随重定向。
final class SecureApiClient implements SecureApiTransport, TuyuApiTransport {
  SecureApiClient(Uri endpoint, {Dio? dio}) : _dio = dio ?? Dio() {
    if (endpoint.scheme != 'https' ||
        endpoint.host.isEmpty ||
        endpoint.userInfo.isNotEmpty) {
      throw ArgumentError.value(
        endpoint,
        'endpoint',
        'TuyuServe 必须使用有效 HTTPS 地址',
      );
    }
    _dio.options = BaseOptions(
      baseUrl: endpoint.toString().replaceFirst(RegExp(r'/$'), ''),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
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
  Future<Map<String, Object?>> post(
    String path,
    Map<String, Object?> body,
  ) async {
    if (!path.startsWith('/') || path.startsWith('//')) {
      throw ArgumentError.value(path, 'path', 'API 路径格式无效');
    }
    final response = await _dio.post<Object?>(path, data: body);
    final data = response.data;
    if (data is! Map) throw const FormatException('TuyuServe 响应格式无效');
    return data.map((key, value) => MapEntry(key.toString(), value));
  }

  @override
  Future<Map<String, Object?>> authorizedGet(
    String path, {
    required String token,
    Map<String, Object?> query = const {},
  }) async {
    _validatePath(path);
    _validateToken(token);
    final response = await _dio.get<Object?>(
      path,
      queryParameters: query,
      options: Options(headers: {'authorization': 'Bearer $token'}),
    );
    return _map(response.data);
  }

  @override
  Future<Map<String, Object?>> publicGet(
    String path, {
    Map<String, Object?> query = const {},
  }) async {
    _validatePath(path);
    final response = await _dio.get<Object?>(path, queryParameters: query);
    return _map(response.data);
  }

  @override
  Future<Map<String, Object?>> authorizedPost(
    String path,
    Map<String, Object?> body, {
    required String token,
  }) async {
    _validatePath(path);
    _validateToken(token);
    final response = await _dio.post<Object?>(
      path,
      data: body,
      options: Options(headers: {'authorization': 'Bearer $token'}),
    );
    return _map(response.data);
  }

  static void _validatePath(String path) {
    if (!path.startsWith('/') || path.startsWith('//')) {
      throw ArgumentError.value(path, 'path', 'API 路径格式无效');
    }
  }

  static void _validateToken(String token) {
    if (token.isEmpty || token.contains(RegExp(r'[\r\n]'))) {
      throw ArgumentError.value(token, 'token', '会话令牌无效');
    }
  }

  static Map<String, Object?> _map(Object? data) {
    if (data is! Map) throw const FormatException('服务响应格式无效');
    return data.map((key, value) => MapEntry(key.toString(), value));
  }
}
