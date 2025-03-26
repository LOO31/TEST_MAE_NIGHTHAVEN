import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'doctor_dashboard.dart';
import 'doctor_notesRecommendations.dart';

class RecsPatientsListPage extends StatefulWidget {
  final String email;
  const RecsPatientsListPage({super.key, required this.email});

  @override
  _RecsPatientsListPage createState() => _RecsPatientsListPage();
}

class _RecsPatientsListPage extends State<RecsPatientsListPage> {
  String? doctorId;
  List<Map<String, dynamic>> patients = [];

  @override
  void initState() {
    super.initState();
    _fetchDoctorId();
  }

  /// 获取 doctorId
  Future<void> _fetchDoctorId() async {
    try {
      var doctorSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .limit(1)
          .get();

      if (doctorSnapshot.docs.isNotEmpty) {
        setState(() {
          doctorId = doctorSnapshot.docs.first.id; // 假设 doc ID 就是 doctorId
        });
        _loadPatients(doctorId!);
      } else {
        print("Doctor not found");
      }
    } catch (e) {
      print("Error fetching doctorId: $e");
    }
  }

  /// 获取所有预约患者
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
        title: const Text('Patients Recommendations',
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
            colors: [Color(0xFF091E40), Color(0xFF66363A)], // 保持黑红渐变
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
                    color: Colors.white.withOpacity(0.2), // 透明黑色卡片
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(patient['name'],
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(patient['email'],
                          style: TextStyle(color: Colors.grey[300])),
                      trailing: const Icon(Icons.arrow_forward,
                          color: Colors.white), // 保持箭头
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotesRecommendationsPage(
                              email: widget.email,
                              patientName: patient['name'],
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
