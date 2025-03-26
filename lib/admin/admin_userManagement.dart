import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_addUser.dart';
import 'admin_editUser.dart';
import 'admin_dashboard.dart';
import 'admin_notification.dart';
import 'admin_report.dart';
import 'admin_settings.dart';
import 'admin_userManagement_services.dart';

class AdminUserManagement extends StatefulWidget {
  final String email;
  const AdminUserManagement({super.key, required this.email});

  @override
  _AdminUserManagementState createState() => _AdminUserManagementState();
}

class _AdminUserManagementState extends State<AdminUserManagement>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 1;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => AdminDashboard(email: widget.email)),
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
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AdminSettingsPage(email: widget.email)),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Fetch users from Firestore filtered by role
  Stream<QuerySnapshot> fetchUsers(String role) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: role)
        .snapshots();
  }

  // Show confirmation dialog before deleting user
  Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              title: const Text("Confirm Deletion",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: const Text(
                  "This action cannot be undone. Are you sure you want to delete this user?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancel",
                      style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Delete",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // Handle user deletion process
  void handleDeleteUser(BuildContext context, String userId) async {
    bool confirmDelete = await showDeleteConfirmationDialog(context);
    if (!confirmDelete) return;

    try {
      await UserManagementService().deleteUser(userId);
      setState(() {}); // Refresh UI after deletion

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting user: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF091E40), Color(0xFF66363A)],
              ),
            ),
          ),
          
          // Header section with tabs
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
                  color: Colors.black,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "User Management",
                        style: GoogleFonts.poppins(
                            fontSize: 24, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.black,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    tabs: const [
                      Tab(text: "Users"),
                      Tab(text: "Doctors"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Search bar
          Positioned(
            top: 170,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.only(top: 8),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  hintText: "Search by name or email...",
                  hintStyle: GoogleFonts.poppins(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          
          // User list content
          Positioned.fill(
            top: 210,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUserList("User"),
                _buildUserList("Doctor"),
              ],
            ),
          ),
        ],
      ),
      
      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Report"),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: "Notification"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
      
      // Add user floating button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddUserPage(
                      email: widget.email,
                    )),
          );
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  // Build user list based on role
  Widget _buildUserList(String role) {
    return StreamBuilder<QuerySnapshot>(
      stream: fetchUsers(role),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "No $role Found",
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.white70),
            ),
          );
        }

        // Filter users based on search query
        var users = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          var name = (data['username'] ?? "").toLowerCase();
          var email = (data['email'] ?? "").toLowerCase();
          return searchQuery.isEmpty ||
              name.contains(searchQuery.toLowerCase()) ||
              email.contains(searchQuery.toLowerCase());
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          itemCount: users.length,
          itemBuilder: (context, index) {
            var userDoc = users[index];
            var userData = userDoc.data() as Map<String, dynamic>;

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    userData['profilePic'] ??
                        "https://i.pinimg.com/736x/c0/74/9b/c0749b7cc401421662ae901ec8f9f660.jpg",
                  ),
                  radius: 24,
                ),
                title: Text(
                  userData['username'] ?? "Unknown",
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                subtitle: Text(
                  userData['email'] ?? "No Email",
                  style:
                      GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Edit button
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditUserPage(
                              userId: userDoc.id,
                              currentName: userData['username'] ?? "Unknown",
                              currentEmail: userData['email'] ?? "No Email",
                              currentRole: userData['role'] ?? "User",
                              currentProfilePic: userData['profilePic'] ??
                                  "https://i.pinimg.com/736x/c0/74/9b/c0749b7cc401421662ae901ec8f9f660.jpg",
                              createdAt: userData['created_at'] ?? "Unknown",
                              email: widget.email,
                            ),
                          ),
                        );
                      },
                    ),
                    // Delete button
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: () {
                        handleDeleteUser(context, userDoc.id);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}