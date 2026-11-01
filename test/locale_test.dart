import 'dart:io';
import 'dart:convert';

import 'package:citizen_sdk/citizen_sdk.dart';
import 'package:citizen_sdk/test/platform/fixture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuyulove/app/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final fixture = CitizenSdkTestFixture();
  setUp(fixture.install);
  tearDown(fixture.dispose);
  test('Android generated names use the AGP Variant API', () {
    final root =
        Platform.environment['TUYULOVE_ROOT'] ?? Directory.current.path;
    final script = File(
      '$root/android/app/build.gradle.kts',
    ).readAsStringSync();
    expect(
      script,
      contains('abstract class GenerateAppNameResources : DefaultTask'),
    );
    expect(script, contains('generatedResources.set(appNameResources)'));
    expect(script, contains('androidComponents.onVariants'));
    expect(script, contains('addGeneratedSourceDirectory'));
    expect(script, contains('GenerateAppNameResources::generatedResources'));
    expect(script, isNot(contains('res.srcDir(appNameResources)')));
    expect(script, isNot(contains('android.sourceset.disallowProvider=false')));
  });

  test('安装名称按系统语言解析并保留产品身份', () {
    final root = Platform.environment['TUYULOVE_ROOT'];
    final app = root ?? Directory.current.path;
    String source(String path) => File('$app/$path').readAsStringSync();
    for (final platform in ['ios']) {
      final catalog = jsonDecode(
        source('$platform/Runner/InfoPlist.xcstrings'),
      );
      for (final key in ['CFBundleDisplayName', 'CFBundleName']) {
        for (final entry in {
          'en': 'TuyuLove',
          'zh-Hans': '途遇旅行',
          'zh-Hant': '途遇旅行',
        }.entries) {
          expect(
            catalog['strings'][key]['localizations'][entry
                .key]['stringUnit']['value'],
            entry.value,
          );
        }
      }
      expect(
        source('$platform/Runner.pbxproj'),
        contains('InfoPlist.xcstrings'),
      );
    }
    expect(
      source('android/app/src/main/AndroidManifest.xml'),
      contains('android:label="@string/app_name"'),
    );
    final gradle = source('android/app/build.gradle.kts');
    expect(gradle, contains('generateAppNameResources'));
    expect(gradle, contains('app_en.arb'));
    expect(gradle, contains('app_zh.arb'));
    expect(
      gradle,
      contains('layout.buildDirectory.dir("generated/app-name/res")'),
    );
  });

  test('supports Chinese and English only in the first release', () {
    expect(TuyuLoveApp.supportedLocales, const [Locale('zh'), Locale('en')]);
  });

  testWidgets('follows the device Chinese locale', (tester) async {
    tester.binding.platformDispatcher.localesTestValue = const [Locale('zh')];
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);
    final sdk = (await tester.runAsync(
      () => CitizenSdk.open(
        modules: CitizenSdkModules.wallet | CitizenSdkModules.signing,
      ),
    ))!;
    try {
      await tester.pumpWidget(
        TuyuLoveApp(serviceEndpoint: '', citizenSdk: sdk),
      );
      await tester.pumpAndSettle();
      expect(find.text('途遇号'), findsOneWidget);
    } finally {
      await tester.runAsync(sdk.close);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
}
