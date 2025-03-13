import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'role_selection.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Slower blinking effect
    )..repeat(reverse: true);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _navigateWithFadeTransition();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateWithFadeTransition() {
    Navigator.of(context).pushReplacement(_fadeRoute(const RoleSelection()));
  }

  PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: StarryNightPainter(_controller.value),
                );
              },
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'assets/images/NightHavenLogo.jpg',
                    width: 250,
                    height: 190,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  "Good Night!",
                  style: GoogleFonts.leckerliOne(
                      fontSize: 28, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StarryNightPainter extends CustomPainter {
  final double animationValue;
  final Random _random = Random();

  StarryNightPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF0D1B2A), const Color(0xFF253751)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    Paint starPaint = Paint();
    for (int i = 0; i < 100; i++) {
      double x = _random.nextDouble() * size.width;
      double y =
          _random.nextDouble() * size.height * 0.6; // Concentrated at top 60%
      double radius = _random.nextDouble() * 2;

      // Stars fade out as they move downward
      double verticalFade = 1.0 - (y / (size.height * 0.6));
      double opacity = verticalFade *
          (0.3 + (0.7 * (0.5 + 0.5 * sin(animationValue * pi * 2))));

      starPaint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
