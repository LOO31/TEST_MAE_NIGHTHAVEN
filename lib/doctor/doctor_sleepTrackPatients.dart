import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'doctor_dashboard.dart';
import 'doctor_sleepTrack.dart';

class SleepDataPatientListPage extends StatefulWidget {
  final String email;
  const SleepDataPatientListPage({super.key, required this.email});

  @override
  _SleepDataPatientListPage createState() => _SleepDataPatientListPage();
}

class _SleepDataPatientListPage extends State<SleepDataPatientListPage> {
  String? doctorId;
  List<Map<String, dynamic>> patients = [];

  @override
  void initState() {
    super.initState();
    _fetchDoctorId();
  }

  /// Fetch doctor ID from Firestore
  Future<void> _fetchDoctorId() async {
    try {
      var doctorSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .limit(1)
          .get();

      if (doctorSnapshot.docs.isNotEmpty) {
        setState(() {
          doctorId = doctorSnapshot.docs.first.id; // Assuming doc ID is doctorId
        });
        _loadPatients(doctorId!);
      } else {
        print("Doctor not found");
      }
    } catch (e) {
      print("Error fetching doctorId: $e");
    }
  }

  /// Load all patients who have appointments with this doctor
  Future<void> _loadPatients(String doctorId) async {
    try {
      List<Map<String, dynamic>> patientList = [];
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      for (var userDoc in usersSnapshot.docs) {
        String userId = userDoc.id;

        final querySnapshot = await FirebaseFirestore.instance
            .collection('appointments')
            .doc(userId)
            .collection('user_appointments')
            .where('doctorId', isEqualTo: doctorId)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          var userData = userDoc.data();
          var patient = {
            'name': userData['username'] ?? 'Unknown',
            'email': userData['email'] ?? 'Unknown',
          };

          patientList.add(patient);
        }
      }

      setState(() {
        patients = patientList;
      });
    } catch (e) {
      print('Error loading patients: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient\'s Sleep Data', 
               style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DoctorDashboard(email: widget.email),
              ),
            );
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF091E40), Color(0xFF66363A)], // Dark blue to dark red gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: patients.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: patients.length,
                itemBuilder: (context, index) {
                  var patient = patients[index];
                  return Card(
                    color: Colors.white.withOpacity(0.2), // Semi-transparent white card
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(patient['name'],
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(patient['email'],
                          style: TextStyle(color: Colors.grey[300])),
                      trailing: const Icon(Icons.arrow_forward,
                          color: Colors.white),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PatientSleepDataPage(
                              patientName: patient['name'],
                              email: widget.email,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}