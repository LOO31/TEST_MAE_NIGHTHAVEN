import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mae_grp_assignment/admin/admin_dashboard.dart';
import 'admin_report.dart';
import 'admin_settings.dart';
import 'admin_userManagement.dart';

class AdminNotificationPage extends StatefulWidget {
  final String email;

  const AdminNotificationPage({super.key, required this.email});

  @override
  _AdminNotificationPageState createState() => _AdminNotificationPageState();
}

class _AdminNotificationPageState extends State<AdminNotificationPage> {
  DateTime now = DateTime.now();
  int _selectedIndex = 3;

  @override
  Widget build(BuildContext context) {
    // Get the start of the current day
    DateTime todayStart = DateTime(now.year, now.month, now.day);
    Timestamp todayTimestamp = Timestamp.fromDate(todayStart);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: Text("Notifications",
            style: GoogleFonts.poppins(fontSize: 24, color: Colors.white)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF091E40), Color(0xFF66363A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // Fetch users created after the start of today
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('created_at', isGreaterThanOrEqualTo: todayTimestamp)
                    .snapshots(),
                builder: (context, userSnapshot) {
                  return StreamBuilder<QuerySnapshot>(
                    // Fetch follow-ups created after the start of today
                    stream: FirebaseFirestore.instance
                        .collection('follow_ups')
                        .where('createdAt', isGreaterThanOrEqualTo: todayTimestamp)
                        .snapshots(),
                    builder: (context, followUpSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting ||
                          followUpSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (userSnapshot.hasError || followUpSnapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error loading notifications',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      List<DocumentSnapshot> users = userSnapshot.data?.docs ?? [];
                      List<DocumentSnapshot> followUps = followUpSnapshot.data?.docs ?? [];

                      List<DocumentSnapshot> newUsers = [];
                      List<DocumentSnapshot> newDoctors = [];

                      // Classify new users and new doctors
                      for (var doc in users) {
                        var data = doc.data() as Map<String, dynamic>?;
                        if (data != null) {
                          String role = (data['role'] ?? 'User').toString();
                          if (role == 'User') {
                            newUsers.add(doc);
                          } else if (role == 'Doctor') {
                            newDoctors.add(doc);
                          }
                        }
                      }

                      return ListView(
                        children: [
                          // Display new users if any
                          if (newUsers.isNotEmpty) ...[
                            _buildSectionTitle("New Users"),
                            ...newUsers.map((doc) {
                              var data = doc.data() as Map<String, dynamic>;
                              return _buildNotificationTile(
                                icon: Icons.person_add,
                                color: Colors.green,
                                title: "New User Registered",
                                subtitle: "${data['username'] ?? 'Unknown user'} has joined",
                              );
                            }).toList(),
                          ],
                          // Display new doctors if any
                          if (newDoctors.isNotEmpty) ...[
                            _buildSectionTitle("New Doctors"),
                            ...newDoctors.map((doc) {
                              var data = doc.data() as Map<String, dynamic>;
                              return _buildNotificationTile(
                                icon: Icons.medical_services,
                                color: Colors.orange,
                                title: "New Doctor Registered",
                                subtitle: "Dr. ${data['username'] ?? 'Unknown doctor'} has joined",
                              );
                            }).toList(),
                          ],
                          // Display follow-ups if any
                          if (followUps.isNotEmpty) ...[
                            _buildSectionTitle("Follow-Ups"),
                            ...followUps.map((doc) {
                              var data = doc.data() as Map<String, dynamic>?;
                              if (data == null) {
                                return _buildNotificationTile(
                                  icon: Icons.local_hospital,
                                  color: Colors.blue,
                                  title: "Doctor Follow-Up",
                                  subtitle: "Invalid follow-up data",
                                );
                              }

                              String? patientId = data['patientUid'];
                              if (patientId == null || patientId.isEmpty) {
                                return _buildNotificationTile(
                                  icon: Icons.local_hospital,
                                  color: Colors.blue,
                                  title: "Doctor Follow-Up",
                                  subtitle: "No patient ID specified",
                                );
                              }

                              return FutureBuilder<DocumentSnapshot>(
                                // Fetch patient information based on patientId
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(patientId)
                                    .get(),
                                builder: (context, userSnapshot) {
                                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                                    return _buildNotificationTile(
                                      icon: Icons.local_hospital,
                                      color: Colors.blue,
                                      title: "Doctor Follow-Up",
                                      subtitle: "Loading patient information...",
                                    );
                                  }

                                  if (!userSnapshot.hasData || userSnapshot.data?.data() == null) {
                                    return _buildNotificationTile(
                                      icon: Icons.local_hospital,
                                      color: Colors.blue,
                                      title: "Doctor Follow-Up",
                                      subtitle: "Patient information not found",
                                    );
                                  }

                                  var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                                  String patientUsername = userData['username'] ?? 'Unknown Patient';
                                  String doctorName = data['doctorName'] ?? 'Unknown Doctor';

                                  return _buildNotificationTile(
                                    icon: Icons.local_hospital,
                                    color: Colors.blue,
                                    title: "Doctor Follow-Up",
                                    subtitle: "Doctor $doctorName has a follow-up with Patient $patientUsername",
                                  );
                                },
                              );
                            }).toList(),
                          ],
                          // Display message if no notifications
                          if (newUsers.isEmpty && newDoctors.isEmpty && followUps.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text("No Notifications Today",
                                    style: TextStyle(color: Colors.white, fontSize: 18)),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
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

  // Handle navigation when a bottom navigation item is tapped
  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminDashboard(email: widget.email)),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminUserManagement(email: widget.email)),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ReportPage(email: widget.email)),
      );
    } else if (index == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminSettingsPage(email: widget.email)),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Build section title for new users, new doctors, or follow-ups
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Build notification tile to display each notification
  Widget _buildNotificationTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 3,
      color: Colors.black54,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
      ),
    );
  }
}
