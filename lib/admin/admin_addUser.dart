import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bcrypt/bcrypt.dart';

class AddUserPage extends StatefulWidget {
  final String email;
  const AddUserPage({super.key, required this.email});

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = "User"; // Default role
  bool _isLoading = false;

  /// Get the latest user ID from Firestore and generate the next one
  Future<String> _getNextUserId() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('created_at', descending: true)
        .limit(1)
        .get();

    int nextUid = 1;
    if (snapshot.docs.isNotEmpty) {
      var lastDoc = snapshot.docs.first;
      String lastId = lastDoc.id;
      nextUid = int.parse(lastId.replaceAll('u', '')) + 1;
    }
    return 'u$nextUid'; // Format as u1, u2, etc.
  }

  /// Register user and save to both Firestore & Firebase Auth
  Future<void> _addUser() async {
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields!")),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // Get next user ID
      String userId = await _getNextUserId();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      // Register with Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String authUid = userCredential.user!.uid;

      // Hash password for security
      String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

      // Save to Firestore
      await FirebaseFirestore.instance.collection("users").doc(userId).set({
        "username": _usernameController.text.trim(),
        "email": email,
        "password": hashedPassword,
        "role": _selectedRole,
        "profilePic": "https://i.pinimg.com/736x/c0/74/9b/c0749b7cc401421662ae901ec8f9f660.jpg", // Default avatar
        "auth_uid": authUid,
        "created_at": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User added successfully!")),
      );
      Navigator.pop(context); // Close current page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Add New User",
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF091E40), Color(0xFF66363A)],
              ),
            ),
          ),

          // Scrollable content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 120), // Top padding
                  _buildDropdown(),
                  const SizedBox(height: 16),
                  _buildInputField(_usernameController, "Username", Icons.person),
                  const SizedBox(height: 16),
                  _buildInputField(_emailController, "Email", Icons.email),
                  const SizedBox(height: 16),
                  _buildInputField(_passwordController, "Password", Icons.lock, obscureText: true),
                  const SizedBox(height: 24),

                  // Submit button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _addUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : Text("Add User", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 20), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Custom input field widget
  Widget _buildInputField(
    TextEditingController controller, 
    String hint, 
    IconData icon, 
    {bool obscureText = false}
  ) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// Custom dropdown for role selection
  Widget _buildDropdown() {
    return Container(
      height: 56, // Match height with input fields
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRole,
          dropdownColor: Colors.black87,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
          iconEnabledColor: Colors.white,
          items: ["User", "Doctor"].map((role) {
            return DropdownMenuItem(
              value: role,
              child: Text(role, style: GoogleFonts.poppins(color: Colors.white)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedRole = value!;
            });
          },
        ),
      ),
    );
  }
}