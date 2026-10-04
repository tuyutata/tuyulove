import 'package:citizen_sdk/citizen_sdk.dart';
import 'package:flutter/widgets.dart';
import 'package:tuyulove/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const endpoint = String.fromEnvironment('TUYU_SERVE_URL');
  final citizenSdk = await CitizenSdk.open(
    modules: CitizenSdkModules.wallet | CitizenSdkModules.signing,
  );
  runApp(TuyuLoveApp(serviceEndpoint: endpoint, citizenSdk: citizenSdk));
}
