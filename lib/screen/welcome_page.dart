import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'role_selection.dart'; // Import Role Selection page

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    // ⏳ 2秒后自动跳转
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) { 
        _navigateWithFadeTransition();
      }
    });
  }

  void _navigateWithFadeTransition() {
    Navigator.of(context).pushReplacement(_fadeRoute(const RoleSelection()));
  }

  PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation, // 渐隐动画
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 500), // 动画时间
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF253751), // Background color
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/cloud.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Logo
          Positioned(
            top: 200,
            left: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                'assets/images/NightHavenLogo.jpg',
                width: 277,
                height: 213,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // "Good Night!" text
          Positioned(
            top: 460,
            left: 150,
            child: Text(
              "Good Night!",
              style: GoogleFonts.leckerliOne(fontSize: 24, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
