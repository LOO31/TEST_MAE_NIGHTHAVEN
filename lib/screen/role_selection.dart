import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mobile_login.dart'; // Import the MobileLogin page
import 'welcome_page.dart';

class RoleSelection extends StatelessWidget {
  const RoleSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.black, // Set the background color of the page to black
      appBar: AppBar(
        title: Text(
          "Role Selection Page",
          style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16), // Set title text color to white
        ),
        backgroundColor: Colors.transparent, // Make the app bar transparent
        elevation: 0, // Remove the shadow of the app bar
        foregroundColor:
            Colors.white, // Ensure all foreground elements are white
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const WelcomePage()),
            );
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF091E40),
              Color(0xFF66363A)
            ], // Set background gradient colors
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 40), // Add space at the top

            // Role Selection Title
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 30.0), // Add horizontal padding
              child: Align(
                alignment: Alignment.centerLeft, // Align text to the left
                child: Text(
                  "Role Selection",
                  style: GoogleFonts.poppins(
                    color: Colors.white, // Set text color to white
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20), // Add space

            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.start, // Align items at the top
                children: [
                  _buildRoleButton(context, "User"), // Create "User" button
                  _buildDivider(), // Add a divider
                  _buildRoleButton(context, "Doctor"), // Create "Doctor" button
                  _buildDivider(), // Add another divider
                  _buildRoleButton(context, "Admin"), // Create "Admin" button
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(BuildContext context, String role) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 30.0, vertical: 5), // Add padding around the button
      child: SizedBox(
        width: double.infinity, // Make the button take full width
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MobileLogin(selectedRole: role),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
                vertical: 15), // Adjust button height
            backgroundColor:
                Colors.black.withAlpha(77), // Semi-transparent black button
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)), // Rounded corners
            elevation: 5, // Add shadow effect
          ),
          child: Text(
            role,
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600), // Set text color to white
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(
          vertical: 5.0, horizontal: 40), // Add spacing around the divider
      child: Divider(
          color: Colors.white54,
          thickness: 0.5), // Set divider color and thickness
    );
  }
}
