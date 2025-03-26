import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'doctor_appointments.dart';
import 'doctor_followUpPatient.dart';
import 'doctor_followUpReview.dart';
import 'doctor_notesRecommendationPatients.dart';
import 'doctor_patients.dart';
import 'doctor_reports.dart';
import 'doctor_settings.dart';
import 'doctor_sleepTrackPatients.dart';

class DoctorDashboard extends StatelessWidget {
  final String email;
  const DoctorDashboard({super.key, required this.email});

  void _onItemTapped(BuildContext context, int index) {
    final pages = [
      DoctorDashboard(email: email),
      DoctorPatientsPage(email: email),
      DoctorAppointmentsPage(email: email),
      DoctorReportsPage(email: email),
      DoctorSettingsPage(email: email),
    ];
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => pages[index]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Doctor Dashboard",
                style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF091E40), Color(0xFF66363A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardCards(),
              const SizedBox(height: 20),
              NotificationsSection(email: email),
              const SizedBox(height: 20),
              QuickActions(email: email),
            ],
          ),
        ),
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Patients'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Appts'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Reports'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        onTap: (index) => _onItemTapped(context, index),
      ),
    );
  }
}

class DashboardCards extends StatefulWidget {
  const DashboardCards({super.key});

  @override
  _DashboardCardsState createState() => _DashboardCardsState();
}

class _DashboardCardsState extends State<DashboardCards> {
  String? doctorId;
  int totalPatients = 0;
  int todaysPatients = 0;
  int todaysFollowUps = 0;

  @override
  void initState() {
    super.initState();
    _fetchDoctorData();
  }

  Future<void> _fetchDoctorData() async {
    String? currentEmail = FirebaseAuth.instance.currentUser?.email;
    if (currentEmail == null) {
      print("Doctor email is empty, cannot query data");
      return;
    }

    // Fetch doctorId using the email
    String? doctorId = await _getDoctorIdByEmail(currentEmail);
    if (doctorId == null) {
      print("Doctor ID not found");
      return;
    }

    setState(() {
      this.doctorId = doctorId;
    });

    print("Current doctor ID: $doctorId");

    await _fetchTotalPatients();
    await _fetchTodaysPatients();
    await _fetchTodaysFollowUps();
  }

  Future<String?> _getDoctorIdByEmail(String email) async {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1) // Ensure there's only one user with this email
        .get();

    if (userSnapshot.docs.isEmpty) {
      return null; // No user found with this email
    }

    // Return the doctorId from the user's document
    return userSnapshot.docs.first.id;
  }

  Future<void> _fetchTotalPatients() async {
    int count = 0;
    QuerySnapshot usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    print("Number of users queried: ${usersSnapshot.size}");

    for (var userDoc in usersSnapshot.docs) {
      String userId = userDoc.id;
      QuerySnapshot appointmentsSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .doc(userId)
          .collection('user_appointments')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      print("Number of appointments for user $userId: ${appointmentsSnapshot.size}");
      count += appointmentsSnapshot.size;
    }

    setState(() {
      totalPatients = count;
    });

    print("Total Patients: $totalPatients");
  }

  Future<void> _fetchTodaysPatients() async {
    int count = 0;
    DateTime today = DateTime.now();
    String todayStr = "${today.year}-${today.month}-${today.day}";

    print("Today's date: $todayStr");

    QuerySnapshot usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    for (var userDoc in usersSnapshot.docs) {
      String userId = userDoc.id;
      QuerySnapshot appointmentsSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .doc(userId)
          .collection('user_appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('date', isEqualTo: todayStr)
          .get();

      print("Today's appointments for user $userId: ${appointmentsSnapshot.size}");
      count += appointmentsSnapshot.size;
    }

    setState(() {
      todaysPatients = count;
    });

    print("Today's Patients: $todaysPatients");
  }

  Future<void> _fetchTodaysFollowUps() async {
    int count = 0;
    DateTime now = DateTime.now();
    String todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}"; // Format as "yyyy-MM-dd"
    
    print("Querying today's follow-ups, date: $todayStr");

    // Query follow-ups where followUpDate equals today's date
    QuerySnapshot followUpsSnapshot = await FirebaseFirestore.instance
        .collection('follow_ups')
        .where('doctorId', isEqualTo: doctorId)
        .where('followUpDate', isEqualTo: todayStr)
        .get();

    // Count the number of matching follow-up records
    count = followUpsSnapshot.size;

    setState(() {
      todaysFollowUps = count;
    });

    print("Today's Follow-Ups: $todaysFollowUps");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child:
                    _buildCard("Total Patients", "$totalPatients", Icons.person)),
            const SizedBox(width: 10),
            Expanded(
                child:
                    _buildCard("Today's Appointments", "$todaysPatients", Icons.calendar_today)),
          ],
        ),
        const SizedBox(height: 10),
        _buildCard("Today's Follow-Ups", "$todaysFollowUps", Icons.schedule, isWide: true),
      ],
    );
  }

  Widget _buildCard(String title, String count, IconData icon, {bool isWide = false}) {
    return Container(
      width: isWide ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: Colors.white),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 4),
          Text(count,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}



class NotificationsSection extends StatefulWidget {
  final String email;

  const NotificationsSection({super.key, required this.email});

  @override
  _NotificationsSectionState createState() => _NotificationsSectionState();
}

class _NotificationsSectionState extends State<NotificationsSection> {
  String? doctorId;

  @override
  void initState() {
    super.initState();
    _fetchDoctorId();
  }

  Future<void> _fetchDoctorId() async {
    try {
      var userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        setState(() {
          doctorId = userQuery.docs.first.id;
        });
        print("Doctor ID fetched: $doctorId");
      } else {
        print("Doctor ID not found for email: ${widget.email}");
      }
    } catch (e) {
      print("Error fetching doctor ID: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (doctorId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Notification", 
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1), // Semi-transparent background
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 300, // Fixed height
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('follow_ups')
                  .where('doctorId', isEqualTo: doctorId)
                  .snapshots(),
              builder: (context, followUpSnapshot) {
                if (followUpSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (followUpSnapshot.hasError) {
                  return const Center(
                    child: Text(
                      "Error fetching notifications",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                DateTime today = DateTime.now();
                DateTime todayStart = DateTime(today.year, today.month, today.day);

                List<DocumentSnapshot> followUps =
                    (followUpSnapshot.data?.docs ?? []).where((doc) {
                  var data = doc.data() as Map<String, dynamic>;

                  dynamic followUpValue = data['followUpDate'];
                  DateTime? followUpDate;

                  if (followUpValue is Timestamp) {
                    followUpDate = followUpValue.toDate();
                  } else if (followUpValue is String) {
                    try {
                      followUpDate = DateTime.parse(followUpValue);
                    } catch (e) {
                      print("Invalid date format: $followUpValue");
                      return false;
                    }
                  } else {
                    return false;
                  }

                  return !followUpDate.isBefore(todayStart);
                }).toList();

                return ListView(
                  shrinkWrap: true,
                  children: followUps.isNotEmpty
                      ? followUps.map((doc) {
                          var data = doc.data() as Map<String, dynamic>;
                          return _buildNotificationTile(
                            icon: Icons.local_hospital,
                            color: Colors.blue,
                            title: "Follow-Up Reminder",
                            subtitle: "Follow-up with ${data['patientName']} at ${data['followUpTime']}",
                            onTap: () {
                              print("Clicked on Follow-Up: ${data['patientUid']}");
                            },
                          );
                        }).toList()
                      : [
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                "No Follow-Up Notifications Today",
                                style: TextStyle(color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ),
                        ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap, // Added click event
  }) {
    return GestureDetector(
      onTap: onTap, // Bind click event
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}


class QuickActions extends StatelessWidget {
  final String email;
  const QuickActions({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Quick Actions",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 16),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.2,
          ),
          children: [
            QuickActionCard(
              label: "Add Follow-Up",
              icon: Icons.add,
              color: Colors.white.withOpacity(0.1),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PatientListPage(email: email)),
              ),
            ),
            QuickActionCard(
              label: "Review Follow-Up",
              icon: Icons.visibility,
              color: Colors.white.withOpacity(0.1),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ReviewFollowUpPage(email: email)),
              ),
            ),
            QuickActionCard(
              label: "Notes & Recs",
              icon: Icons.note_add,
              color: Colors.white.withOpacity(0.1),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        RecsPatientsListPage(email: email)),
              ),
            ),
            QuickActionCard(
              label: "View Recs",
              icon: Icons.remove_red_eye,
              color: Colors.white.withOpacity(0.1),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SleepDataPatientListPage(email: email)),
              ),
            ),
            QuickActionCard(
              label: "Patient Sleep Data",
              icon: Icons.bed,
              color: Colors.white.withOpacity(0.1),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SleepDataPatientListPage(email: email)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class QuickActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const QuickActionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      splashColor: Colors.white.withOpacity(0.3),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.white),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}