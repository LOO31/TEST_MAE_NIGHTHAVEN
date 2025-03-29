import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class EditPersonalInfo extends StatefulWidget {
  const EditPersonalInfo({super.key});

  @override
  _EditPersonalInfoState createState() => _EditPersonalInfoState();
}

class _EditPersonalInfoState extends State<EditPersonalInfo> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Load user data from Firestore
  void _loadUserData() async {
    User? user = _auth.currentUser;
    if (user == null) {
      print("User is not authenticated!");
      return;
    }

    print("Current user UID: ${user.uid}");

    try {
      QuerySnapshot query = await _firestore
          .collection("users")
          .where("auth_uid", isEqualTo: user.uid)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        DocumentSnapshot doc = query.docs.first;
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        print("Firestore User Data: $data");
        print("User Document ID: ${doc.id}");

        setState(() {
          _userIdController.text = doc.id;
          _usernameController.text = data["username"] ?? "";
          _emailController.text = data["email"] ?? "";
          _roleController.text = data["role"] ?? "";
        });
      } else {
        print("User document does not exist in Firestore!");
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Personal Info",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF091E40),
              Color(0xFF66363A)
            ], // 🌈 Gradient background
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                /// **User ID (Read-Only)**
                _buildReadOnlyTextField("User ID", _userIdController),

                /// **Username**
                _buildTextField("Username", _usernameController),

                /// **Email**
                _buildReadOnlyTextField("Email", _emailController),

                /// **Role (Read-Only)**
                _buildReadOnlyTextField("Role", _roleController),

                /// **New Password**
                _buildPasswordField("New Password", _passwordController),

                const SizedBox(height: 30),

                /// **Buttons**
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton("Save Changes", Colors.blue, _saveChanges),
                    _buildButton("Update Password", Colors.red, () {
                      if (_passwordController.text.isNotEmpty) {
                        _changePassword(_passwordController.text);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Please enter a new password!")),
                        );
                      }
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Read-Only Text Field
  Widget _buildReadOnlyTextField(
      String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          readOnly: true, // Read-Only
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

  /// Editable Text Field
  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
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
          validator: (value) =>
              value!.isEmpty ? "Please enter your $label" : null,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  /// Password Field (Make Validation Optional)
  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: true,
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
          validator: (value) {
            if (value != null && value.isNotEmpty && value.length < 6) {
              return "Password must be at least 6 characters";
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  /// Button Widget
  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  ///Save Changes (Sync to Firestore & Firebase Auth)
  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    User? user = _auth.currentUser;
    if (user == null) {
      print("No authenticated user!");
      return;
    }

    try {
      // 获取 Firestore 的用户文档
      QuerySnapshot query = await _firestore
          .collection("users")
          .where("auth_uid", isEqualTo: user.uid)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        print("User document not found!");
        return;
      }

      DocumentSnapshot doc = query.docs.first;
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // 只更新被修改的字段
      Map<String, dynamic> updatedData = {};

      if (_usernameController.text != data["username"]) {
        updatedData["username"] = _usernameController.text;
      }
      if (_emailController.text != data["email"]) {
        updatedData["email"] = _emailController.text;
        await user.updateEmail(_emailController.text); // 更新 Firebase Auth 邮箱
      }
      if (_roleController.text != data["role"]) {
        updatedData["role"] = _roleController.text;
      }

      // 只有当有修改时才更新 Firestore
      if (updatedData.isNotEmpty) {
        await _firestore.collection("users").doc(doc.id).update(updatedData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No changes detected!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e")),
      );
    }
  }

  /// Change Password (Sync to Firebase Auth)
  Future<void> _changePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // 1️⃣ 获取当前用户的 Email
      String email = user.email!;

      // 2️⃣ 让用户输入当前密码
      String? currentPassword = await _showPasswordDialog();
      if (currentPassword == null || currentPassword.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password update canceled.")),
        );
        return;
      }

      // 3️⃣ 创建 Email & Password Credential
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      // 4️⃣ 重新认证用户
      await user.reauthenticateWithCredential(credential);

      // 5️⃣ 重新认证成功后，才可以更新密码
      await user.updatePassword(newPassword);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update password: $e")),
      );
    }
  }

  Future<String?> _showPasswordDialog() async {
    String? currentPassword;
    return showDialog<String>(
      context: context,
      builder: (context) {
        TextEditingController passwordController = TextEditingController();
        return AlertDialog(
          title: const Text("Re-authenticate"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Please enter your current password:"),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: "Current Password"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null), // 取消
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                currentPassword = passwordController.text;
                Navigator.pop(context, currentPassword);
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }
}
