import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_connect/features/auth/presentation/auth_providers.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  static const Color _bg = Color(0xFF0F1113);
  static const Color _bg2 = Color(0xFF15181B);
  static const Color _gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Simple direct navigation based on state
    if (authState.isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (authState.token != null) {
          context.go('/home');
        } else {
          context.go('/login');
        }
      });
    }

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_bg, _bg2, _bg],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                'assets/images/premium_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/premium_logo_final.png',
                  width: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Sajdah Connect',
                  style: TextStyle(
                    color: _gold,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Faith, Community, Technology',
                  style: TextStyle(
                    color: Color(0xFF9A9A9A),
                    fontSize: 13,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 48),
                const _InstagramStyleSpinner(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InstagramStyleSpinner extends StatefulWidget {
  const _InstagramStyleSpinner();

  @override
  State<_InstagramStyleSpinner> createState() => _InstagramStyleSpinnerState();
}

class _InstagramStyleSpinnerState extends State<_InstagramStyleSpinner>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: RotationTransition(
        turns: _controller,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF1A1E22),
              width: 3,
            ),
          ),
          child: Stack(
            children: [
              // Outer rotating ring
              Positioned.fill(
                child: CustomPaint(
                  painter: _CircularRingPainter(),
                ),
              ),
              // Inner circle
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF0F1113),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircularRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = SweepGradient(
        colors: const [
          Color(0xFFD4AF37),
          Color(0xFF9B7D3A),
          Color(0xFF6B5B28),
          Color(0xFF1A1E22),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.width / 2,
        ),
      )
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: (size.width - 8) / 2,
      ),
      0,
      3.14 * 1.5,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CircularRingPainter oldDelegate) => false;
}
