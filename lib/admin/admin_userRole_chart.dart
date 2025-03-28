import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class UserRoleBarChart extends StatefulWidget {
  const UserRoleBarChart({super.key});

  @override
  _UserRoleBarChartState createState() => _UserRoleBarChartState();
}

class _UserRoleBarChartState extends State<UserRoleBarChart> {
  int userCount = 0;
  int doctorCount = 0;

  @override
  void initState() {
    super.initState();
    fetchUserCounts();
  }

  Future<void> fetchUserCounts() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    DateTime now = DateTime.now();
    DateTime sevenDaysAgo = now.subtract(Duration(days: 7));

    QuerySnapshot usersSnapshot = await firestore
        .collection('users')
        .where('role', isEqualTo: "User") // Filter by role to avoid indexing issues
        .get();

    QuerySnapshot doctorsSnapshot = await firestore
        .collection('users')
        .where('role', isEqualTo: "Doctor") // Filter by role to avoid indexing issues
        .get();

    // Manually filter locally by created_at >= 7 days ago
    int filteredUserCount = usersSnapshot.docs
        .where((doc) =>
            (doc['created_at'] as Timestamp).toDate().isAfter(sevenDaysAgo))
        .length;

    int filteredDoctorCount = doctorsSnapshot.docs
        .where((doc) =>
            (doc['created_at'] as Timestamp).toDate().isAfter(sevenDaysAgo))
        .length;

    setState(() {
      userCount = filteredUserCount;
      doctorCount = filteredDoctorCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (userCount + doctorCount).toDouble(),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [
              BarChartRodData(
                  fromY: 0, toY: userCount.toDouble(), color: Colors.blue)
            ]),
            BarChartGroupData(x: 1, barRods: [
              BarChartRodData(
                  fromY: 0, toY: doctorCount.toDouble(), color: Colors.green)
            ]),
          ],
          titlesData: FlTitlesData(
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true, // Show top titles
                reservedSize: 20, // Reserved space
                getTitlesWidget: (value, meta) {
                  return Text(
                    "", // You can change this to the title you want
                    style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1, 
                reservedSize: 25,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                        color: Color.fromARGB(255, 190, 190, 190),
                        fontSize: 12),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
                reservedSize: 20,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                        color: Color.fromARGB(255, 190, 190, 190),
                        fontSize: 12),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0:
                      return const Text("Users",
                          style: TextStyle(color: Colors.white, fontSize: 14));
                    case 1:
                      return const Text("Doctors",
                          style: TextStyle(color: Colors.white, fontSize: 14));
                    default:
                      return const Text("");
                  }
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true, // Enable grid lines (can keep it clean)
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
                color: const Color.fromARGB(255, 251, 251, 251),
                width: 1), // Border color & thickness
          ),
        ),
      ),
    );
  }
}
