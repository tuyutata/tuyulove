import 'package:citizen_sdk/citizen_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tuyulove/app/app_scope.dart';
import 'package:tuyulove/auth/login_page.dart';
import 'package:tuyulove/l10n/app_localizations.dart';

final class TuyuLoveApp extends StatelessWidget {
  const TuyuLoveApp({
    required this.serviceEndpoint,
    required this.citizenSdk,
    super.key,
  });
  final String serviceEndpoint;
  final CitizenSdk citizenSdk;

  static const supportedLocales = [Locale('zh'), Locale('en')];

  @override
  Widget build(BuildContext context) {
    return AppScope(
      serviceEndpoint: serviceEndpoint,
      citizenSdk: citizenSdk,
      child: MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        supportedLocales: supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supported) {
          if (locale == null) return const Locale('en');
          return supported.firstWhere(
            (item) => item.languageCode == locale.languageCode,
            orElse: () => const Locale('en'),
          );
        },
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xffc14f2f),
            primary: const Color(0xffa43d24),
            secondary: const Color(0xff146c72),
            surface: const Color(0xfffffbf2),
          ),
          scaffoldBackgroundColor: const Color(0xfffff7e7),
          fontFamily: 'serif',
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Color(0xfffffdf8),
            border: OutlineInputBorder(),
          ),
          useMaterial3: true,
        ),
        home: const LoginPage(),
      ),
    );
  }
}
