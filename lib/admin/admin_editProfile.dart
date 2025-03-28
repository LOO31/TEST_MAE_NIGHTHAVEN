import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminEditProfilePage extends StatefulWidget {
  final String userId;
  final String currentName;
  final String currentEmail;
  final String currentRole;
  final String currentProfilePic;
  final String createdAt;

  const AdminEditProfilePage({
    super.key,
    required this.userId,
    required this.currentName,
    required this.currentEmail,
    required this.currentRole,
    required this.currentProfilePic,
    required this.createdAt,
  });
  
  @override
  _AdminEditProfilePageState createState() => _AdminEditProfilePageState();
}


class _AdminEditProfilePageState extends State<AdminEditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _roleController;
  late TextEditingController _createdAtController;
  late TextEditingController _profilePicController;
  late TextEditingController _uidController;
  File? _imageFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController(text: widget.currentEmail);
    _roleController = TextEditingController(text: widget.currentRole);
    _createdAtController = TextEditingController(text: widget.createdAt);
    _profilePicController = TextEditingController(text: widget.currentProfilePic);
    _uidController = TextEditingController(text: widget.userId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    _createdAtController.dispose();
    _profilePicController.dispose();
    _uidController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    String fileName = "profile_${widget.userId}.jpg";
    Reference ref = FirebaseStorage.instance.ref().child("profile_pics/$fileName");
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
    });

    try {
      String profilePicUrl = _profilePicController.text.trim();
      if (_imageFile != null) {
        profilePicUrl = await _uploadImage(_imageFile!);
      }

      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'username': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'profilePic': profilePicUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: $e")),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.black54,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Edit Profile",
            style: GoogleFonts.poppins(fontSize: 22, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF091E40), Color(0xFF66363A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 5),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : NetworkImage(_profilePicController.text) as ImageProvider,
              ),
            ),
            const SizedBox(height: 10),
            _buildTextField("User ID", _uidController, enabled: false),
            _buildTextField("Usermame", _nameController),
            _buildTextField("Email", _emailController),
            _buildTextField("Role", _roleController, enabled: false),
            _buildTextField("Created At", _createdAtController, enabled: false),
            _buildTextField("Profile Pic URL", _profilePicController, maxLines: 3),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Changes",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
