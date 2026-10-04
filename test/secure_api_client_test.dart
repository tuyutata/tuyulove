import 'package:flutter_test/flutter_test.dart';
import 'package:tuyulove/network/secure_api_client.dart';

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
}
