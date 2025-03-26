import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mae_grp_assignment/admin/admin_notification.dart';
import 'package:mae_grp_assignment/admin/admin_report.dart';
import 'admin_dashboard_content.dart';
import 'admin_userManagement.dart';
import 'admin_settings.dart';

class AdminDashboard extends StatefulWidget {
  final String email;
  const AdminDashboard({super.key, required this.email});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int totalUsers = 0;
  int adminUsers = 0;
  int normalUsers = 0;
  int doctorUsers = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch user data when the screen is initialized
  }

  // Fetch data from Firestore and categorize users based on their roles
  Future<void> fetchData() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();

      int adminCount = 0;
      int userCount = 0;
      int doctorCount = 0;

      // Iterate through all documents and categorize based on 'role'
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>?;
        if (data == null || !data.containsKey('role')) continue;

        String role = (data['role'] ?? 'User').toString();

        // Increment respective counts based on role
        if (role == 'Admin') {
          adminCount++;
        } else if (role == 'Doctor') {
          doctorCount++;
        } else {
          userCount++;
        }
      }

      // Update state with the fetched data
      setState(() {
        totalUsers = snapshot.size;
        adminUsers = adminCount;
        normalUsers = userCount;
        doctorUsers = doctorCount;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  // Handle bottom navigation bar item taps
  void _onItemTapped(int index) {
    if (index == 1) {
      // Navigate to "Users" screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminUserManagement(email: widget.email)),
      );
    } else if (index == 2) {
      // Navigate to "Report" screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReportPage(email: widget.email)),
      );
    } else if (index == 3) {
      // Navigate to "Notifications" screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminNotificationPage(email: widget.email)),
      );
    } else if (index == 4) {
      // Navigate to "Settings" screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminSettingsPage(email: widget.email)),
      );
    } else {
      // Change selected index without navigation for other items
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF091E40), Color(0xFF66363A)],
              ),
            ),
          ),

          // Current selected page content
          _selectedIndex == 0
              ? AdminDashboardContent(
                  totalUsers: totalUsers,
                  adminUsers: adminUsers,
                  normalUsers: normalUsers,
                  doctorUsers: doctorUsers,
                )
              : Container(), // Other pages won't render content if not selected

          // Fixed black header with "Dashboard" title
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Dashboard", // Title remains static
                    style: GoogleFonts.poppins(fontSize: 24, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Report"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notification"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}
