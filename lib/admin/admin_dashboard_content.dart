import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboardContent extends StatefulWidget {
  final int totalUsers;
  final int adminUsers;
  final int normalUsers;
  final int doctorUsers;

  const AdminDashboardContent({
    super.key,
    required this.totalUsers,
    required this.adminUsers,
    required this.normalUsers,
    required this.doctorUsers,
  });

  @override
  State<AdminDashboardContent> createState() => _AdminDashboardContentState();
}

class _AdminDashboardContentState extends State<AdminDashboardContent> {
  int _currentPage = 0; // Tracks the current page of the photo carousel
  late PageController _pageController;
  late Timer _timer; // Timer for auto-sliding the photo carousel

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _startAutoSlide();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  // Starts the auto-slide functionality for the photo carousel
  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < _photoAssets.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0; // Reset to the first image after reaching the end
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  // List of photo assets for the carousel
  final List<String> _photoAssets = [
    'assets/images/Aurora_Light.jpeg',
    'assets/images/Forest_Night.jpg',
    'assets/images/Full_Moon.png',
    'assets/images/Ocean_Moon.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 115), // Spacer for top margin
          _buildPhotoWall(), // Photo carousel
          const SizedBox(height: 20), // Spacer for separating sections
          _buildTotalUsersCard(widget.totalUsers), // Card showing total users
          const SizedBox(height: 15), // Spacer for separating sections
          _buildSummaryCards(widget.adminUsers, widget.normalUsers, widget.doctorUsers), // Summary cards for user roles
        ],
      ),
    );
  }

  // Builds a card displaying the total number of users
  Widget _buildTotalUsersCard(int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white30,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text("Total Users", style: GoogleFonts.poppins(fontSize: 20, color: Colors.white)),
          const SizedBox(height: 5),
          Text("$total", style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  // Builds summary cards for Admins, Users, and Doctors
  Widget _buildSummaryCards(int admins, int users, int doctors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatBox("Admins", admins, Icons.admin_panel_settings),
        _buildStatBox("Users", users, Icons.people),
        _buildStatBox("Doctors", doctors, Icons.medical_services),
      ],
    );
  }

  // Builds a stat box card for each user role with an icon
  Widget _buildStatBox(String title, int value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 10),
            Text("$value", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(title, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  // Builds the photo carousel wall with left and right navigation buttons
  Widget _buildPhotoWall() {
    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _photoAssets.length,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (ctx, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    _photoAssets[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              );
            },
          ),
          // Left navigation button
          if (_currentPage > 0)
            Positioned(
              left: -10,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.chevron_left, 
                    size: 40, 
                    color: Colors.white),
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ),
          // Right navigation button
          if (_currentPage < _photoAssets.length - 1)
            Positioned(
              right: -10,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.chevron_right, 
                    size: 40, 
                    color: Colors.white),
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
