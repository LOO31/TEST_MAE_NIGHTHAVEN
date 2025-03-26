import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorReportsPage extends StatefulWidget {
  final String email;
  const DoctorReportsPage({super.key, required this.email});

  @override
  _DoctorReportsPageState createState() => _DoctorReportsPageState();
}

class _DoctorReportsPageState extends State<DoctorReportsPage> {
  String? doctorId;
  int monthlyAppointments = 0; // Define the monthly appointments variable
  int yearlyPatients = 0; // Define the yearly patients variable

  @override
  void initState() {
    super.initState();
    _fetchDoctorId(); // Fetch doctor ID when the page is initialized
  }

  // Fetch the doctorId from the users collection based on the email passed to the widget
  Future<void> _fetchDoctorId() async {
    String currentEmail = widget.email; // Use widget.email instead of FirebaseAuth
    if (currentEmail.isEmpty) {
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
      _fetchAppointmentsAndPatients(); // Fetch appointments and patients data after getting doctorId
    } else {
      print("Doctor not found");
    }
  }

  // Fetch appointments for the current month and count the unique patients for the current year
  Future<void> _fetchAppointmentsAndPatients() async {
    if (doctorId == null) return;

    try {
      // Get the current date
      DateTime now = DateTime.now();

      // Calculate the start and end date of the current month
      DateTime startOfMonth = DateTime(now.year, now.month, 1); // First day of the current month
      DateTime endOfMonth = DateTime(now.year, now.month + 1, 0); // Last day of the current month

      // Fetch appointments for the current month
      final appointmentsSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('timestamp', isGreaterThanOrEqualTo: startOfMonth)
          .where('timestamp', isLessThanOrEqualTo: endOfMonth)
          .get();

      int totalAppointmentsCurrentMonth = appointmentsSnapshot.docs.length;
      print("Total appointments for current month: $totalAppointmentsCurrentMonth");

      // Calculate the start date of the current year
      DateTime startOfYear = DateTime(now.year, 1, 1); // First day of the current year

      // Fetch unique patients (userId) for the current year
      Set<String> uniquePatients = Set();
      for (var appointmentDoc in appointmentsSnapshot.docs) {
        var appointmentData = appointmentDoc.data();
        DateTime appointmentDate = appointmentData['timestamp'].toDate();

        // Check if the appointment is from the current year
        if (appointmentDate.isAfter(startOfYear.subtract(Duration(days: 1)))) {
          uniquePatients.add(appointmentData['userId']); // Add unique userId
        }
      }

      int totalPatientsCurrentYear = uniquePatients.length;
      print("Total unique patients for current year: $totalPatientsCurrentYear");

      // Now, you can use these values to update your UI or state
      setState(() {
        // Update your state variables with the counts
        monthlyAppointments = totalAppointmentsCurrentMonth;
        yearlyPatients = totalPatientsCurrentYear;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Reports"),
        backgroundColor: Colors.black,
        centerTitle: false, // 让标题左对齐
        automaticallyImplyLeading: false, // 移除默认的返回箭头
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
              // Display monthly appointments and yearly patients
              InfoCard(title: 'Monthly Appts', value: '$monthlyAppointments'),
              const SizedBox(height: 20),
              InfoCard(title: 'Total Patients (2025)', value: '$yearlyPatients'),
            ],
          ),
        ),
      ),
    );
  }
}

// InfoCard widget for displaying statistics
class InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const InfoCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 190, 55, 55))),
        ],
      ),
    );
  }
}
