import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuyulove/auth/auth_controller.dart';
import 'package:tuyulove/auth/auth_model.dart';
import 'package:tuyulove/l10n/app_localizations.dart';
import 'package:tuyulove/travel/travel_home_page.dart';

final class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

final class _LoginPageState extends State<LoginPage> {
  final _tuyuId = TextEditingController();

  @override
  void dispose() {
    _tuyuId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final controller = context.watch<AuthController>();
    if (controller.status == AuthStatus.authenticated) {
      return const TravelHomePage();
    }
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _TravelBackdrop()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xfffffbf2).withValues(alpha: 0.94),
                      border: Border.all(
                        color: const Color(0xff3d2e24),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 28,
                          offset: Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  'tuyu_logo.png',
                                  width: 72,
                                  height: 72,
                                  semanticLabel: strings.brandMark,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  strings.brandMark,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        letterSpacing: 3,
                                        color: const Color(0xffa43d24),
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            strings.loginTitle,
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  height: 1.05,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            strings.loginSubtitle,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(height: 1.5),
                          ),
                          const SizedBox(height: 28),
                          TextField(
                            controller: _tuyuId,
                            enabled: !controller.isBusy,
                            textInputAction: TextInputAction.done,
                            autocorrect: false,
                            enableSuggestions: false,
                            decoration: InputDecoration(
                              labelText: strings.tuyuIdLabel,
                              prefixIcon: const Icon(Icons.explore_outlined),
                            ),
                            onChanged: (_) => controller.resetError(),
                            onSubmitted: controller.isBusy
                                ? null
                                : controller.login,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: controller.isBusy
                                ? null
                                : () => controller.login(_tuyuId.text),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: controller.isBusy
                                ? const SizedBox.square(
                                    dimension: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(strings.loginAction),
                          ),
                          const SizedBox(height: 16),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: _StatusMessage(status: controller.status),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.phonelink_lock_outlined,
                                size: 20,
                                color: Color(0xff146c72),
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  strings.localSigningHint,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.status});
  final AuthStatus status;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return switch (status) {
      AuthStatus.failed => Text(
        strings.loginError,
        key: const ValueKey('login-error'),
        style: const TextStyle(color: Color(0xffa43d24)),
      ),
      AuthStatus.authenticated => Text(
        strings.loginSuccess,
        key: const ValueKey('login-success'),
        style: const TextStyle(
          color: Color(0xff146c72),
          fontWeight: FontWeight.w700,
        ),
      ),
      _ => const SizedBox.shrink(key: ValueKey('login-idle')),
    };
  }
}

final class _TravelBackdrop extends StatelessWidget {
  const _TravelBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xffffd79a), Color(0xfff2a76f), Color(0xff4c9a9f)],
          stops: [0, 0.55, 1],
        ),
      ),
      child: CustomPaint(painter: _RoutePainter()),
    );
  }
}

final class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sun = Paint()..color = const Color(0x66fff8d8);
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.18),
      size.shortestSide * 0.22,
      sun,
    );
    final route = Paint()
      ..color = const Color(0x99fff8e8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()
      ..moveTo(-20, size.height * 0.78)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.56,
        size.width * 0.57,
        size.height * 0.92,
        size.width + 20,
        size.height * 0.58,
      );
    canvas.drawPath(path, route);
  }

  @override
  bool shouldRepaint(_RoutePainter oldDelegate) => false;
}
