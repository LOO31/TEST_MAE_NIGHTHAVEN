import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../services/auth_service.dart';

class MobileRegister extends StatefulWidget {
  const MobileRegister({super.key});

  @override
  State<MobileRegister> createState() => _MobileRegisterState();
}

class _MobileRegisterState extends State<MobileRegister> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  String? _errorMessage;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Mobile Register"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF091E40), Color(0xFF66363A)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              _buildLogo(),
              const SizedBox(height: 20),
              _buildTitle(),
              const SizedBox(height: 20),
              _buildTextField("Username", controller: _userController),
              const SizedBox(height: 15),
              _buildTextField("Email", controller: _emailController),
              const SizedBox(height: 15),
              _buildTextField("Password",
                  controller: _passwordController, isPassword: true),
              const SizedBox(height: 10),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              const SizedBox(height: 10),
              _buildSignInPrompt(),
              const SizedBox(height: 20),
              _buildRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(30),
        ),
        child:
            Image.asset("assets/images/NightHavenLogo.jpg", fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildTitle() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        "Sign Up",
        style: GoogleFonts.poppins(
            color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField(String hint,
      {bool isPassword = false, TextEditingController? controller}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white10,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassword
            ? const Icon(Icons.visibility, color: Colors.white54)
            : null,
      ),
    );
  }

  Widget _buildSignInPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account?",
            style: TextStyle(color: Colors.white70)),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Sign In",
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _registerUser,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: Colors.purple,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text("Sign Up",
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _registerUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String username = _userController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "Username, Email, and Password cannot be empty!";
        _isLoading = false;
      });
      return;
    }

    // Hash the password using SHA-256
    String hashedPassword = sha256.convert(utf8.encode(password)).toString();

    // Call AuthService to register with hashed password
    String? result = await _authService.signUp(username, email, hashedPassword);

    if (result == null) {
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      setState(() {
        _errorMessage = result;
        _isLoading = false;
      });
    }
  }
}
