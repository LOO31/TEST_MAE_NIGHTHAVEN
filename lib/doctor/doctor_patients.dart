import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'doctor_dashboard.dart';
import 'doctor_appointments.dart';
import 'doctor_reports.dart';
import 'doctor_settings.dart';

class DoctorPatientsPage extends StatefulWidget {
  final String email;
  const DoctorPatientsPage({super.key, required this.email});

  @override
  _DoctorPatientsPageState createState() => _DoctorPatientsPageState();
}

class _DoctorPatientsPageState extends State<DoctorPatientsPage> {
  int _selectedIndex = 1;
  String searchQuery = "";
  List<Map<String, dynamic>> patients = [];
  String? doctorId;

  @override
  void initState() {
    super.initState();
    _fetchDoctorId();
  }

  Future<void> _fetchDoctorId() async {
    String? currentEmail = FirebaseAuth.instance.currentUser?.email;
    if (currentEmail == null) {
      print("Doctor email is empty, cannot fetch doctorId");
      return;
    }

    var doctorSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: currentEmail)
        .limit(1)
        .get();

    if (doctorSnapshot.docs.isNotEmpty) {
      setState(() {
        doctorId = doctorSnapshot.docs.first.id;
      });
      _loadPatients(doctorId!);
    } else {
      print("Doctor not found");
    }
  }

  Future<void> _loadPatients(String doctorId) async {
    try {
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      List<Map<String, dynamic>> patientList = [];

      for (var userDoc in usersSnapshot.docs) {
        String userId = userDoc.id;

        // Removed unused 'doc' variable by not declaring it
        var querySnapshot = await FirebaseFirestore.instance
            .collection('appointments')
            .doc(userId)
            .collection('user_appointments')
            .where('doctorId', isEqualTo: doctorId)
            .get();

        // Check if there are any appointments before fetching user data
        if (querySnapshot.docs.isNotEmpty) {
          var userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

          if (userDoc.exists) {
            var userData = userDoc.data();
            patientList.add({
              'name': userData?['username'] ?? 'Unknown',
              'email': userData?['email'] ?? 'Unknown',
            });
          }
        }
      }

      setState(() {
        patients = patientList;
      });
    } catch (e) {
      print('Error loading patients: $e');
    }
  }

  void _onItemTapped(int index) {
    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = DoctorDashboard(email: widget.email);
        break;
      case 1:
        nextPage = DoctorPatientsPage(email: widget.email);
        break;
      case 2:
        nextPage = DoctorAppointmentsPage(email: widget.email);
        break;
      case 3:
        nextPage = DoctorReportsPage(email: widget.email);
        break;
      case 4:
        nextPage = DoctorSettingsPage(email: widget.email);
        break;
      default:
        nextPage = DoctorPatientsPage(email: widget.email);
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredPatients = patients.where((patient) {
      String patientName = patient["name"]?.toLowerCase().trim() ?? '';
      String patientEmail = patient["email"]?.toLowerCase().trim() ?? '';
      String query = searchQuery.toLowerCase().trim();
      return patientName.contains(query) || patientEmail.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Patients", style: TextStyle(color: Colors.white)),
          ],
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: TextField(
                onChanged: (value) => setState(() => searchQuery = value),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search by name or email...",
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: Colors.black45,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filteredPatients.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.white.withOpacity(0.7),
                    child: ListTile(
                      title: Text(filteredPatients[index]["name"]!,
                          style: const TextStyle(color: Colors.black)),
                      subtitle: Text(filteredPatients[index]["email"]!,
                          style: const TextStyle(color: Colors.black54)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Patients'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Appts'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Reports'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}