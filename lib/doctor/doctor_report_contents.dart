import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'doctor_appointments.dart';
import 'doctor_dashboard.dart';
import 'doctor_patients.dart';
import 'doctor_settings.dart';

class DoctorReportsPage extends StatefulWidget {
  final String email;
  const DoctorReportsPage({super.key, required this.email});

  @override
  _DoctorReportsPageState createState() => _DoctorReportsPageState();
}

class _DoctorReportsPageState extends State<DoctorReportsPage> {
  final int _selectedIndex = 3; // 当前选中 "Reports"
  String? doctorId;
  int monthlyAppointments = 0; // 月度预约数
  int yearlyPatients = 0; // 年度患者数
  List<int> monthlyAppointmentsCount = List.filled(12, 0); // List for monthly appointment counts

  final List<String> _pageTitles = [
    'Doctor Dashboard',
    'Patients',
    'Appointments',
    'Reports',
    'Settings'
  ];

  @override
  void initState() {
    super.initState();
    _fetchDoctorId(); // 获取 doctorId
  }

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
      List<int> appointmentsCount = await fetchForEveryMonthApptsCounts();
      setState(() {
        monthlyAppointmentsCount = appointmentsCount;
      });
    }
  }

  Future<List<int>> fetchForEveryMonthApptsCounts() async {
    if (doctorId == null) return List.filled(12, 0);

    List<int> monthlyAppointmentsCount = List.filled(12, 0);

    try {
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();

      for (var userDoc in usersSnapshot.docs) {
        String userId = userDoc.id;

        final appointmentsSnapshot = await FirebaseFirestore.instance
            .collection('appointments')
            .doc(userId)
            .collection('user_appointments')
            .where('doctorId', isEqualTo: doctorId)
            .get();

        for (var appointmentDoc in appointmentsSnapshot.docs) {
          var appointmentData = appointmentDoc.data();
          var appointmentDate = appointmentData['date'];

          if (appointmentDate is String) {
            appointmentDate = DateTime.parse(appointmentDate);
          }

          if (appointmentDate is DateTime) {
            int month = appointmentDate.month;
            monthlyAppointmentsCount[month - 1]++;
          }
        }
      }
    } catch (e) {
      print("Error fetching monthly appointment counts: $e");
    }

    return monthlyAppointmentsCount;
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = DoctorDashboard(email: widget.email);
        break;
      case 1:
        page = DoctorPatientsPage(email: widget.email);
        break;
      case 2:
        page = DoctorAppointmentsPage(email: widget.email);
        break;
      case 3:
        page = DoctorReportsPage(email: widget.email);
        break;
      case 4:
        page = DoctorSettingsPage(email: widget.email);
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _pageTitles[_selectedIndex],
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        centerTitle: false,
        automaticallyImplyLeading: false,
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0), // Added padding to prevent content from touching screen edges
        child: SingleChildScrollView(
          child: Column(
            children: [
              ReportCards(
                monthlyAppointments: monthlyAppointments,
                yearlyPatients: yearlyPatients,
              ),
              const SizedBox(height: 20),
              MonthlyAppointmentsChart(monthlyAppointmentsCount: monthlyAppointmentsCount),
              const SizedBox(height: 20),
              AIAlerts(), // Your AI Alerts here
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Patients'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Appts'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
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

class MonthlyAppointmentsChart extends StatelessWidget {
  final List<int> monthlyAppointmentsCount;

  const MonthlyAppointmentsChart({super.key, required this.monthlyAppointmentsCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4), // Make background more transparent
        borderRadius: BorderRadius.circular(15),
      ),
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: true, getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.black.withOpacity(0.1), 
              strokeWidth: 1,
            );
          }),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2,  // Adjust interval to show every 2 months
                getTitlesWidget: (double value, TitleMeta meta) {
                  switch (value.toInt()) {
                    case 0:
                      return Text('Jan');
                    case 1:
                      return Text('Feb');
                    case 2:
                      return Text('Mar');
                    case 3:
                      return Text('Apr');
                    case 4:
                      return Text('May');
                    case 5:
                      return Text('Jun');
                    case 6:
                      return Text('Jul');
                    case 7:
                      return Text('Aug');
                    case 8:
                      return Text('Sep');
                    case 9:
                      return Text('Oct');
                    case 10:
                      return Text('Nov');
                    case 11:
                      return Text('Dec');
                    default:
                      return Text('');
                  }
                },
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false), // Hide top titles
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false), // Hide right titles
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(12, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: monthlyAppointmentsCount[index].toDouble(),
                  color: Colors.tealAccent,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}


class AIAlerts extends StatelessWidget {
  const AIAlerts({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("AI Alerts",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(15)),
          child: Column(
            children: const [
              AIAlertItem(patient: "John Doe", alert: "Possible hypertension detected."),
              AIAlertItem(patient: "Jane Smith", alert: "Unusual heart rate variations."),
              AIAlertItem(patient: "Michael Brown", alert: "High risk of diabetes detected."),
            ],
          ),
        ),
      ],
    );
  }
}

class AIAlertItem extends StatelessWidget {
  final String patient;
  final String alert;

  const AIAlertItem({super.key, required this.patient, required this.alert});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(patient,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          Expanded(
            child: Text(alert,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 14, color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class ReportCards extends StatelessWidget {
  final int monthlyAppointments;
  final int yearlyPatients;

  const ReportCards({
    super.key,
    required this.monthlyAppointments,
    required this.yearlyPatients,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        InfoCard(
          title: 'Monthly Appts',
          value: '$monthlyAppointments',
          icon: Icons.event,
          color: Colors.tealAccent,
        ),
        InfoCard(
          title: '2025 Total Patients',
          value: '$yearlyPatients',
          icon: Icons.people,
          color: Colors.tealAccent,
        ),
      ],
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}