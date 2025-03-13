import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../admin/admin_dashboard.dart';
import 'main_page.dart';
import 'mobile_register.dart';

class MobileLogin extends StatefulWidget {
  final String? email; 

  const MobileLogin({super.key, this.email, required selectedRole});

  @override
  State<MobileLogin> createState() => _MobileLoginState();
}

class _MobileLoginState extends State<MobileLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.email != null) {
      _emailController.text = widget.email!;
    }
  }

  // User Login Logic
  void _loginUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "Email and Password cannot be empty!";
        _isLoading = false;
      });
      return;
    }

    try {
      // Firebase Credential
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      // Quer Firestore to get characteristics
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('auth_uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        setState(() {
          _errorMessage = "User not found in Firestore!";
          _isLoading = false;
        });
        return;
      }

      DocumentSnapshot userDoc = userQuery.docs.first;
      // Get user role from firebase
      String userRole = userDoc['role']; 

      // Switch User
      Widget nextPage;
      if (userRole == 'Admin') {
        nextPage = AdminDashboard(email: email);
      } else {
        nextPage = MainPage(email: email);
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => nextPage),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Login failed: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title:
            const Text("Mobile Login", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
              _buildTextField("Email", controller: _emailController),
              const SizedBox(height: 15),
              _buildTextField("Password",
                  controller: _passwordController, isPassword: true),
              const SizedBox(height: 10),
              if (_errorMessage != null)
                Text(_errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14)),
              const SizedBox(height: 10),
              _buildSignUpPrompt(),
              const SizedBox(height: 20),
              _buildLoginButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Logo
  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(40),
        ),
        child:
            Image.asset("assets/images/NightHavenLogo.jpg", fit: BoxFit.cover),
      ),
    );
  }

  // Title
  Widget _buildTitle() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        "Sign In",
        style: GoogleFonts.poppins(
            color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Input Field
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
      ),
    );
  }

  // Registration Hints
  Widget _buildSignUpPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?",
            style: TextStyle(color: Colors.white70)),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MobileRegister()),
          ),
          child: Text("Sign Up",
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
        ),
      ],
    );
  }

  // Login Button
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _loginUser,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: Colors.purple,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text("Sign In",
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
      ),
    );
  }
}
