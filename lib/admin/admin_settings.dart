import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mae_grp_assignment/admin/admin_editProfile.dart';
import 'package:mae_grp_assignment/screen/mobile_logout.dart';
import '../screen/app_versions.dart';
import '../screen/privacy_policy.dart';
import '../screen/terms_and_conditions.dart';
import 'admin_dashboard.dart';
import 'admin_notification.dart';
import 'admin_userManagement.dart';
import 'admin_report.dart';
import 'admin_changePassword.dart';

class AdminSettingsPage extends StatefulWidget {
  final String email;
  const AdminSettingsPage({super.key, required this.email});

  @override
  _AdminSettingsPageState createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  int _selectedIndex = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(fontSize: 24, color: Colors.white),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF091E40), Color(0xFF66363A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  "No Data Found",
                  style: TextStyle(color: Colors.white)),
              );
            }

            // Filter users by current email
            var users = snapshot.data!.docs.where((doc) {
              var data = doc.data() as Map<String, dynamic>;
              return data['email'] == widget.email;
            }).toList();

            if (users.isEmpty) {
              return const Center(
                child: Text(
                    "No Data Found",
                    style: TextStyle(color: Colors.white)),
              );
            }

            var userDoc = users.first;
            var data = userDoc.data() as Map<String, dynamic>;

            // Extract user data
            String userId = userDoc.id;
            String doctorName = data['username'] ?? "Doctor Name";
            String doctorEmail = data['email'] ?? "doctor@example.com";
            String doctorRole = data['role'] ?? "Role";
            String profilePicUrl = data['profilePic'] ?? 
                "https://i.pinimg.com/736x/c0/74/9b/c0749b7cc401421662ae901ec8f9f660.jpg";

            // Handle timestamp conversion
            Timestamp createdAtTimestamp = data['created_at'] ?? Timestamp.now();
            String createdAt = createdAtTimestamp.toDate().toString();

            return Column(
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(profilePicUrl),
                      ),
                      const SizedBox(height: 16),
                      Text(
                          doctorName,
                          style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Text(
                          doctorEmail,
                          style: GoogleFonts.poppins(
                              fontSize: 16, color: Colors.white70)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildSettingsItem("Edit Profile", Icons.edit, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminEditProfilePage(
                              userId: userId,
                              currentName: doctorName,
                              currentEmail: doctorEmail,
                              currentRole: doctorRole,
                              currentProfilePic: profilePicUrl,
                              createdAt: createdAt,
                            ),
                          ),
                        );
                      }),
                      _buildSettingsItem("Change Password", Icons.vpn_key, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AdminChangePasswordPage(email: widget.email)),
                        );
                      }),
                      _buildSettingsItem("Privacy Policy", Icons.security, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PrivacyPolicyPage(email: widget.email)),
                        );
                      }),
                      _buildSettingsItem(
                          "Terms and Conditions", Icons.description, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  TermsAndConditionsPage(email: widget.email)),
                        );
                      }),
                      _buildSettingsItem("App Version", Icons.info, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AppVersionPage(email: widget.email)),
                        );
                      }),
                      _buildSettingsItem("Logout", Icons.logout, _logout),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Report'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Notification'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  void _logout() async {
    LogoutService.logout(context);
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => AdminDashboard(email: widget.email)),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AdminUserManagement(email: widget.email)),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ReportPage(email: widget.email)),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AdminNotificationPage(email: widget.email)),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _buildSettingsItem(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 3,
      color: Colors.black54,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        onTap: onTap,
      ),
    );
  }
}