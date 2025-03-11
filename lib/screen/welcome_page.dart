import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'role_selection.dart'; // Import Role Selection page

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  double _scale = 1.0; // Default scale value

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.9; // Shrink effect on tap
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0; // Restore size after tap
    });
    // Navigate to RoleSelection page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RoleSelection()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF253751), // Background color
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0, // Remove shadow
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/cloud.jpg"), // Your cloud image
              fit: BoxFit.cover, // Cover the entire AppBar
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Logo with animated tap effect
          Positioned(
            top: 200, // Adjust vertical position
            left: 80, // Adjust horizontal position
            child: GestureDetector(
              onTapDown: _onTapDown, // Scale down when tapped
              onTapUp: _onTapUp, // Scale back & navigate
              child: AnimatedScale(
                scale: _scale, // Apply scale animation
                duration:
                    const Duration(milliseconds: 100), // Fast smooth effect
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30), // Adjust roundness
                  child: Image.asset(
                    'assets/images/NightHavenLogo.jpg', // Image path
                    width: 277,
                    height: 213,
                    fit: BoxFit.cover, // Ensure the image fits well
                  ),
                ),
              ),
            ),
          ),

          // "Good Night!" text positioned below the logo
          Positioned(
            top: 460, // Adjust to move text up/down
            left: 150, // Adjust to move text left/right
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
