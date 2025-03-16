import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/firebase_connected_device.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'role_selection.dart';
import '/user/sleep_tracker.dart';
import '/user/profile_setting.dart';

class MainPage extends StatefulWidget {
  final String email;

  const MainPage({super.key, required this.email});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late String _currentTime;
  late Timer _timer;
  bool _showConnectedDevices =
      false; // Controls whether the device list is displayed
  String? _connectedDevice;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });

    // **获取 Firestore 已连接的设备**
    _loadConnectedDevice();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime =
          "${_formatNumber(now.hour)} : ${_formatNumber(now.minute)}";
    });
  }

  String _formatNumber(int number) {
    return number.toString().padLeft(2, '0');
  }

  void _toggleConnection(String deviceName) async {
    print("Toggling connection for: $deviceName");

    FirebaseConnectedDevice firebaseService = FirebaseConnectedDevice();
    String? newDevice = (_connectedDevice == deviceName) ? null : deviceName;

    print("New device to be updated in Firestore: $newDevice");

    await firebaseService.updateConnectedDevice(newDevice); // 先存数据库
    setState(() {
      _connectedDevice = newDevice;
    });
  }

  void _loadConnectedDevice() async {
    FirebaseConnectedDevice firebaseService = FirebaseConnectedDevice();
    String? device = await firebaseService.getConnectedDevice();
    setState(() {
      _connectedDevice = device;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Pure black background
      appBar: AppBar(
        title: Text(
          "User Main Page",
          style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16), // Set title text color to white
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileSettings()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purpleAccent,
              Color(0xFF66363A)
            ], // Gradient background
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: _showConnectedDevices
            ? _buildConnectedDevicesList()
            : _buildMainContent(),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildMainContent() {
    return Column(
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
      ],
    );
  }

  Widget _buildClockWidget() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 210,
          height: 210,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
          ),
        ),
        Column(
          children: [
            Text(
              _currentTime,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _getGreetingMessage(),
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
        ),
      ],
    );
  }

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return "Good Morning";
    } else if (hour >= 12 && hour < 18) {
      return "Good Afternoon";
    } else {
      return "Good Night";
    }
  }

  void _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logout Success")),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (!context.mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const RoleSelection()),
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
              onPressed: () {
                setState(() {
                  _showConnectedDevices = true; // Show the list of devices
                });
              },
              child: const Text(
                "View All >",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildDeviceCard("Apple Watch", "100%",
            _connectedDevice == "Apple Watch" ? "Connected" : "Disconnected"),
        _buildDeviceCard("Mi Band", "77%",
            _connectedDevice == "Mi Band" ? "Connected" : "Disconnected"),
      ],
    );
  }

  Widget _buildDeviceCard(String deviceName, String battery, String status) {
    bool isConnected = _connectedDevice == deviceName;
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
              Text(deviceName,
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              Text("$battery • $status",
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          const Icon(Icons.bookmark_border, color: Colors.white70),
          ElevatedButton(
            onPressed: () => _toggleConnection(deviceName),
            style: ElevatedButton.styleFrom(
                backgroundColor: isConnected ? Colors.red : Colors.green),
            child: Text(isConnected ? "Disconnect" : "Connect"),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedDevicesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              _showConnectedDevices = false; // Return to the main screen
            });
          },
        ),
        const SizedBox(height: 10),
        const Text(
          "Connected Devices",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        _buildDeviceCard("Apple Watch", "100%",
            _connectedDevice == "Apple Watch" ? "Connected" : "Disconnected"),
        _buildDeviceCard("Mi Band", "77%",
            _connectedDevice == "Mi Band" ? "Connected" : "Disconnected"),
        _buildDeviceCard("Fitbit", "50%",
            _connectedDevice == "Fitbit" ? "Connected" : "Disconnected"),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF4A148C),
      selectedItemColor: Colors.black,
      unselectedItemColor: const Color(0xFF9C27B0),
      onTap: (index) {
        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SleepTracker(email: widget.email),
            ),
          );
        }
      },
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
