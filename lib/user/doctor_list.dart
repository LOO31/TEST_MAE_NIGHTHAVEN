import 'package:flutter/material.dart';

class Doctor {
  final String name;
  final String specialty;
  final String qualification;
  final String image;

  Doctor({
    required this.name,
    required this.specialty,
    required this.qualification,
    required this.image,
  });
}

class DoctorListPage extends StatefulWidget {
  @override
  _DoctorListPageState createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Doctor> doctors = [
    Doctor(
      name: "Dr. Abu Saifuddin",
      specialty: "Sleep Therapist",
      qualification: "MD, M.PHIL, PHD",
      image: "assets/doctor1.png",
    ),
    Doctor(
      name: "Dr. James Merry",
      specialty: "Clinical Psychologist",
      qualification: "MD, M.PHIL, PHD",
      image: "assets/doctor2.png",
    ),
    Doctor(
      name: "Dr. William Henry",
      specialty: "Behavioural Health Specialist",
      qualification: "MD, M.PHIL, PHD",
      image: "assets/doctor3.png",
    ),
  ];

  List<Doctor> filteredDoctors = [];

  @override
  void initState() {
    super.initState();
    filteredDoctors = doctors;
  }

  void filterSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredDoctors = doctors;
      } else {
        filteredDoctors = doctors.where((doctor) {
          return doctor.name.toLowerCase().contains(query.toLowerCase()) ||
              doctor.specialty.toLowerCase().contains(query.toLowerCase()) ||
              doctor.qualification.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Doctor List", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 搜索框
            TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white),
              onChanged: filterSearch,
              decoration: InputDecoration(
                hintText: "Doctors, Clinics, Labs",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                prefixIcon: Icon(Icons.search, color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            // 医生列表
            Expanded(
              child: ListView.builder(
                itemCount: filteredDoctors.length,
                itemBuilder: (context, index) {
                  final doctor = filteredDoctors[index];
                  return Card(
                    color: Colors.grey[850],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundImage: AssetImage(doctor.image),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(doctor.name,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16)),
                                SizedBox(height: 5),
                                Text(doctor.specialty,
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 14)),
                                Text(doctor.qualification,
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // TODO: Implement Live Chat
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                ),
                                child: Text("Live Chat"),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  // TODO: Implement Appointment
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                ),
                                child: Text("Appointment"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
