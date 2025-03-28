import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'doctor_dashboard.dart';
import 'doctor_patients.dart';
import 'doctor_reports.dart';
import 'doctor_settings.dart';

class DoctorAppointmentsPage extends StatefulWidget {
  final String email;
  const DoctorAppointmentsPage({super.key, required this.email});

  @override
  _DoctorAppointmentsPageState createState() => _DoctorAppointmentsPageState();
}

class _DoctorAppointmentsPageState extends State<DoctorAppointmentsPage> {
  final int _selectedIndex = 2;
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<Map<String, String>>> _appointments =
      {}; // Initialize as empty Map
  String? doctorId;

  @override
  void initState() {
    super.initState();
    _fetchDoctorId(); // Fetch doctorId
  }

  // Fetch doctorId from Firestore using current user's email
  Future<void> _fetchDoctorId() async {
    String? currentEmail = FirebaseAuth.instance.currentUser?.email;
    if (currentEmail == null) return;

    var doctorSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: currentEmail)
        .limit(1)
        .get();

    if (doctorSnapshot.docs.isNotEmpty) {
      setState(() {
        doctorId = doctorSnapshot.docs.first.id;
      });
      _fetchAppointments(); // Fetch appointments after getting doctorId
    }
  }

  // Fetch all appointments for the current doctor
  Future<void> _fetchAppointments() async {
    if (doctorId == null) return;

    try {
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      Map<DateTime, List<Map<String, String>>> fetchedAppointments = {};

      // Iterate through all user documents
      for (var userDoc in usersSnapshot.docs) {
        String userId = userDoc.id;

        // Get appointments for this user
        final querySnapshot = await FirebaseFirestore.instance
            .collection('appointments')
            .doc(userId)
            .collection('user_appointments')
            .where('doctorId', isEqualTo: doctorId)
            .get();

        for (var doc in querySnapshot.docs) {
          var data = doc.data();
          String dateStr = data['date'] ?? '';
          DateTime appointmentDate = DateTime.parse(dateStr);

          // Get patient email from appointment
          String patientEmail = data['email'] ?? '';

          // Get username associated with this email
          String username = await _getUsernameFromEmail(patientEmail);

          // Ensure we use date-only format (without time)
          DateTime dateOnly = _getDateWithoutTime(appointmentDate);

          // Add appointment to fetchedAppointments
          if (!fetchedAppointments.containsKey(dateOnly)) {
            fetchedAppointments[dateOnly] = [];
          }

          fetchedAppointments[dateOnly]?.add({
            "username": username, // Add username
            "patientEmail": patientEmail,
            "time": data['time'] ?? '',
            "date": dateStr,
            "problem": data['problem'] ?? '',
          });
        }
      }

      setState(() {
        _appointments = fetchedAppointments; // Update appointments data
      });
    } catch (e) {
      // Error handling would go here in production
    }
  }

  // Get username from email by querying Firestore
  Future<String> _getUsernameFromEmail(String email) async {
    try {
      var userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        return userSnapshot.docs.first['username'] ?? 'Unknown';
      } else {
        return 'Unknown';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  // Helper function to get date without time component
  DateTime _getDateWithoutTime(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Handle bottom navigation bar item taps
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
        nextPage = DoctorAppointmentsPage(email: widget.email);
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get appointments for selected day (empty list if none)
    final selectedAppointments =
        _appointments[_getDateWithoutTime(_selectedDay)] ?? [];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Appointments", style: TextStyle(color: Colors.white)),
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
        child: Column(
          children: [
            // Calendar widget
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TableCalendar(
                  firstDay: DateTime(2024, 1, 1),
                  lastDay: DateTime(2026, 12, 31),
                  focusedDay: _selectedDay,
                  selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: const Color.fromARGB(255, 122, 128, 138),
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(color: Colors.white),
                    weekendTextStyle: TextStyle(
                      color: const Color.fromARGB(255, 235, 86, 81),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    defaultTextStyle: TextStyle(
                      color: Colors
                          .white, // This styles the weekday numbers (not the labels)
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    outsideTextStyle: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                    ),
                    outsideDaysVisible: true,
                  ),
                  headerStyle: HeaderStyle(
                    titleTextStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    formatButtonVisible: false,
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 30,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 30,
                    ),
                    headerMargin: EdgeInsets.only(bottom: 8),
                    titleCentered: true,
                    headerPadding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black
                          .withOpacity(0.4), // Darker header background
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                  ),
                  // This styles the weekday labels (Sun, Mon, Tue, etc.)
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: Colors.white, // Weekday labels (M, T, W, etc.)
                      fontWeight: FontWeight.bold,
                    ),
                    weekendStyle: TextStyle(
                      color: Colors.white, // Weekend labels (S, S)
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    todayBuilder: (context, day, focusedDay) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // List of appointments for selected day
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: selectedAppointments.length,
                itemBuilder: (context, index) {
                  final appointment = selectedAppointments[index];
                  return Card(
                    color: Colors.white.withOpacity(0.2),
                    child: ListTile(
                      leading: const Icon(Icons.event, color: Colors.white),
                      title: Text(appointment["username"]!,
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                        "Email: ${appointment["patientEmail"]}\nDate: ${appointment["date"]} | Time: ${appointment["time"]}\nProblem: ${appointment["problem"]}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                },
              ),
            )
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
