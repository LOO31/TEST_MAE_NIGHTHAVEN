import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bcrypt/bcrypt.dart';

class ChangePasswordPage extends StatefulWidget {
  final String email;

  const ChangePasswordPage({super.key, required this.email});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> _changePassword() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Find the UID and password in Firestore by email
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception("User not found in Firestore");
      }

      DocumentSnapshot userDoc = querySnapshot.docs.first;
      String uid = userDoc.id; // Get UID
      String hashedPassword = userDoc['password']; // Hashed password in Firestore

      // 2. Check if the current password is correct
      if (!BCrypt.checkpw(_currentPasswordController.text, hashedPassword)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Current password is incorrect")),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 3. Check if the new passwords match
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("New passwords do not match")),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 4. Update Firebase Authentication password
      User? user = _auth.currentUser;
      if (user == null || user.email != widget.email) {
        throw Exception("You must be logged in to change password.");
      }
      await user.updatePassword(_newPasswordController.text);

      // 5. Hash the new password and update Firestore
      String newHashedPassword = BCrypt.hashpw(_newPasswordController.text, BCrypt.gensalt());
      await FirebaseFirestore.instance.collection('users').doc(uid).update({'password': newHashedPassword});

      // 6. Sign out and navigate to login page
      await _auth.signOut();
      Navigator.pushReplacementNamed(context, '/login');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password changed successfully! Please log in again.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white38),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Change Password",
          style: GoogleFonts.poppins(fontSize: 22, color: Colors.white),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF091E40), Color(0xFF66363A)], // Gradient background
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100),
            _buildTextField("Current Password", _currentPasswordController, obscureText: true),
            const SizedBox(height: 16),
            _buildTextField("New Password", _newPasswordController, obscureText: true),
            const SizedBox(height: 16),
            _buildTextField("Confirm New Password", _confirmPasswordController, obscureText: true),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Change Password", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
