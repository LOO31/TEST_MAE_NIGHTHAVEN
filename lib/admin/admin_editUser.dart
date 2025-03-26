import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class EditUserPage extends StatefulWidget {
  final String userId;
  final String currentName;
  final String currentEmail;
  final String currentRole;
  final String currentProfilePic;
  final Timestamp createdAt; // Firestore timestamp
  final String email;

  const EditUserPage({
    super.key,
    required this.userId,
    required this.currentName,
    required this.currentEmail,
    required this.currentRole,
    required this.currentProfilePic,
    required this.createdAt,
    required this.email,
  });

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.currentName;
    _emailController.text = widget.currentEmail;
  }

  /// Format Firestore Timestamp to readable string
  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-"
           "${dateTime.day.toString().padLeft(2, '0')} "
           "${dateTime.hour.toString().padLeft(2, '0')}:"
           "${dateTime.minute.toString().padLeft(2, '0')}";
  }

  /// Update user information in Firestore
  Future<void> _updateUser() async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .update({
        "username": _nameController.text.trim(),
        "email": _emailController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User updated successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit User", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF091E40), Color(0xFF66363A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // User profile picture
              CircleAvatar(
                backgroundImage: NetworkImage(widget.currentProfilePic),
                radius: 50,
              ),
              const SizedBox(height: 20),

              // User ID (read-only)
              _buildInfoField("User ID", widget.userId),

              // Username (editable)
              _buildTextField("Username", _nameController),

              // Email (editable)
              _buildTextField("Email", _emailController),

              // Role (read-only)
              _buildInfoField("Role", widget.currentRole),

              // Created At (read-only)
              _buildInfoField("Created At", formatTimestamp(widget.createdAt)),

              const SizedBox(height: 20),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _updateUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Read-only information field
  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  /// Editable text field
  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.2),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}