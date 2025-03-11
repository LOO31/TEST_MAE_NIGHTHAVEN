import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'mobile_login.dart'; // Import your login page

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1D2A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _handleLogout(context), // Logout button
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "NightHaven",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildClockWidget(),
            const SizedBox(height: 30),
            _buildConnectedDevicesSection(),
            const Spacer(),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      // Ensure widget is still mounted before using context
      if (!context.mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Logout Success"),
          duration: Duration(seconds: 2),
        ),
      );

      // Delay navigation to allow the user to see the message
      Future.delayed(const Duration(seconds: 2), () {
        if (!context.mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MobileLogin(selectedRole: ''),
          ),
          (route) => false,
        );
      });
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout failed: ${e.toString()}")),
      );
    }
  }

  Widget _buildClockWidget() {
    return const Column(
      children: [
        Text(
          "20 : 30",
          style: TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Good Night",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectedDevicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Connected Devices",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                "View All >",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildDeviceCard("Apple Watch", "100%", "Connected"),
        _buildDeviceCard("Mi Band", "77%", "Disconnect"),
      ],
    );
  }

  Widget _buildDeviceCard(String name, String battery, String status) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3142),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              Text("$battery • $status",
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          const Icon(Icons.bookmark_border, color: Colors.white70),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF2D3142),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.bedtime), label: "Sleep"),
        BottomNavigationBarItem(
            icon: Icon(Icons.favorite), label: "Diary & Emotion"),
        BottomNavigationBarItem(
            icon: Icon(Icons.medical_services), label: "AI & Doctor"),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Report"),
      ],
    );
  }
}
