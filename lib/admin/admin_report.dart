import 'package:flutter/material.dart';
import 'package:mae_grp_assignment/admin/admin_settings.dart';
import 'package:mae_grp_assignment/admin/admin_userManagement.dart';
import 'admin_dailyAppointment_chart.dart';
import 'admin_userRole_chart.dart';
import 'admin_dashboard.dart';
import 'admin_notification.dart';

class ReportPage extends StatefulWidget {
  final String email;

  const ReportPage({super.key, required this.email});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  int _selectedIndex = 2; // Current selected index for bottom navigation

  @override
  void initState() {
    super.initState();
  }

  // Handle bottom navigation item selection
  void _onItemTapped(int index) {
    if (index == 0) {
      // Navigate to Admin Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => AdminDashboard(email: widget.email)),
      );
    } else if (index == 1) {
      // Navigate to User Management
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AdminUserManagement(email: widget.email)),
      );
    } else if (index == 3) {
      // Navigate to Admin Notifications
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AdminNotificationPage(email: widget.email)),
      );
    } else if (index == 4) {
      // Navigate to Admin Settings
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

  @override
  Widget build(BuildContext context) {
    int currentYear = DateTime.now().year; // Get the current year

    return Scaffold(
      backgroundColor: const Color(0xFF091E40), // Set background color
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false, // Remove back button
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Reports & Analytics",
              style: TextStyle(color: Colors.white), // Title style
            ),
          ],
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF091E40), Color(0xFF66363A)], // Gradient background
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display the User Sign-up Chart for the past 7 days
                _buildCard(
                    "User Sign-ups (Last 7 Days) - $currentYear",
                    UserRoleBarChart()), 
                const SizedBox(height: 20),
                // Display the Daily Appointment Chart for the past 7 days
                _buildCard(
                    "Appointments Created (Last 7 Days) - $currentYear",
                    DailyAppointmentsChart()), 
              ],
            ),
          ),
        ),
      ),
      // Bottom navigation bar
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

  // Widget to build each card in the reports page
  Widget _buildCard(String title, Widget child) {
    return Card(
      color: Colors.white10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the title of the card
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Display the chart or content inside the card
            child,
          ],
        ),
      ),
    );
  }
}
