import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book_appointment.dart';

class Doctor {
  final String id;
  final String name;
  final String email;
  final String image;

  Doctor({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
  });

  // 处理 null 值，避免类型转换错误
  factory Doctor.fromFirestore(String id, Map<String, dynamic> data) {
    return Doctor(
      id: id,
      name: (data['username'] ?? 'Unknown').toString(),
      email: (data['email'] ?? 'No Email').toString(),
      image: (data['profilePic'] ?? '').toString(),
    );
  }
}

class DoctorListPage extends StatefulWidget {
  @override
  _DoctorListPageState createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Doctor> doctors = [];
  List<Doctor> filteredDoctors = [];

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  void _loadDoctors() {
    FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Doctor')
        .snapshots()
        .listen((snapshot) {
      List<Doctor> fetchedDoctors = snapshot.docs
          .map((doc) => Doctor.fromFirestore(doc.id, doc.data()))
          .toList();
      setState(() {
        doctors = fetchedDoctors;
        filteredDoctors = doctors;
      });
    });
  }

  void filterSearch(String query) {
    setState(() {
      filteredDoctors = doctors
          .where((doctor) =>
              doctor.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1C1C3C), Color(0xFF4A148C), Color(0xFF9B59B6)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 50),
              TextField(
                controller: _searchController,
                onChanged: filterSearch,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Search Doctors",
                  prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: filteredDoctors.isEmpty
                    ? Center(
                        child: Text(
                          "No doctors available",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredDoctors.length,
                        itemBuilder: (context, index) {
                          final doctor = filteredDoctors[index];
                          return Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: doctor.image.isNotEmpty
                                    ? NetworkImage(doctor.image)
                                    : AssetImage("assets/images/default.jpg")
                                        as ImageProvider,
                                onBackgroundImageError: (_, __) {},
                              ),
                              title: Text(doctor.name,
                                  style: TextStyle(color: Colors.black)),
                              subtitle: Text(doctor.email,
                                  style: TextStyle(color: Colors.black54)),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            BookAppointmentPage(
                                                doctor: doctor)),
                                  );
                                },
                                child: Text("Appointment"),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
