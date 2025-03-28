import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bcrypt/bcrypt.dart'; // Import bcrypt for password hashing
import 'mobile_login.dart';
import 'role_selection.dart'; // Import the login page

class MobileRegister extends StatefulWidget {
  final String? selectedRole; // 让 selectedRole 变成可选

  const MobileRegister({super.key, this.selectedRole});

  @override
  State<MobileRegister> createState() => _MobileRegisterState();
}

class _MobileRegisterState extends State<MobileRegister> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;
  bool _isLoading = false;

  // User registration method
  void _registerUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String username = _userController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Validate email format
    if (!_isValidEmail(email)) {
      setState(() {
        _errorMessage = "Invalid email format!";
        _isLoading = false;
      });
      return;
    }

    // Ensure username, email, and password are not empty
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "Username, Email, and Password cannot be empty!";
        _isLoading = false;
      });
      return;
    }

    try {
      // Register the user with Firebase Authentication
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? uid = userCredential.user?.uid;

      if (uid != null) {
        // Get the highest user ID in Firestore (e.g., u1, u2, u3)
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .orderBy('created_at', descending: true)
            .limit(1)
            .get();

        int nextUid = 1;
        if (snapshot.docs.isNotEmpty) {
          var lastDoc = snapshot.docs.first;
          String lastId = lastDoc.id; // e.g., "u3"
          nextUid = int.parse(lastId.replaceAll('u', '')) + 1;
        }

        // Use Firebase Authentication's UID as the custom user UID
        String customUid = 'u$nextUid'; // Custom UID e.g., u1, u2, u3

        // Hash the password using bcrypt
        String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

        // Store user data in Firestore under the 'users' collection
        FirebaseFirestore.instance.collection('users').doc(customUid).set({
          'username': username,
          'email': email,
          'password': hashedPassword,
          'role': widget.selectedRole, // Role passed from Role Selection
          'auth_uid': uid, // Firebase Authentication UID
          'created_at': FieldValue.serverTimestamp(),
          'profilePic':
              "https://i.pinimg.com/736x/c0/74/9b/c0749b7cc401421662ae901ec8f9f660.jpg", // Default profile picture
        });

        // On successful registration, navigate to SignIn page and pass email and role
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login',
              arguments: {'email': email, 'role': widget.selectedRole});
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error registering user: $e";
        _isLoading = false;
      });
    }
  }

  // Validate email format
  bool _isValidEmail(String email) {
    final regex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return regex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        title: const Text(
          "Mobile Register",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const RoleSelection()),
            );
          },
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

  // Build logo widget
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

  // Build title widget
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

  // Build text input fields (username, email, password)
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

  // Build SignIn prompt widget
  Widget _buildSignInPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account?",
            style: TextStyle(color: Colors.white70)),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MobileLogin(
                // Transform user inputed email
                email: _emailController.text.trim(), selectedRole: null,
              ),
            ),
          ),
          child: Text("Sign In",
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
        ),
      ],
    );
  }

  // Build register button widget
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
}
