import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DailyAppointmentsChart extends StatefulWidget {
  @override
  _DailyAppointmentsChartState createState() => _DailyAppointmentsChartState();
}

class _DailyAppointmentsChartState extends State<DailyAppointmentsChart> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, int> dailyCounts = {}; // Store daily appointment counts
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDailyAppointments();
  }

  Future<void> fetchDailyAppointments() async {
    String? adminId = FirebaseAuth.instance.currentUser?.uid;
    print("Current adminId: $adminId");

    if (adminId == null) {
      print("Admin is not logged in!");
      return;
    }

    DateTime now = DateTime.now();
    DateTime sevenDaysAgo = now.subtract(Duration(days: 7));

    Map<String, int> tempCounts = {};

    try {
      // Get all users
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();

      for (var userDoc in usersSnapshot.docs) {
        String userId = userDoc.id;

        // Get the appointments for this user
        QuerySnapshot appointmentsSnapshot = await _firestore
            .collection('appointments')
            .doc(userId)
            .collection('user_appointments')
            .where('timestamp',
                isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
            .get();

        for (var doc in appointmentsSnapshot.docs) {
          var data = doc.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('timestamp')) {
            Timestamp timestamp = data['timestamp'];
            DateTime date = timestamp.toDate();
            String dateKey =
                "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

            tempCounts[dateKey] = (tempCounts[dateKey] ?? 0) + 1;
          }
        }
      }

      print("Daily counts: $tempCounts");

      if (mounted) {
        setState(() {
          dailyCounts = tempCounts;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching appointments: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : _buildChart();
  }

  Widget _buildChart() {
    List<FlSpot> spots = [];
    List<String> labels = [];

    // Sort by date
    List<String> sortedKeys = dailyCounts.keys.toList()..sort();

    if (sortedKeys.isEmpty) {
      return Center(
        child: Text(
          "No Data Available",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    for (int i = 0; i < sortedKeys.length; i++) {
      spots.add(FlSpot(i.toDouble(), dailyCounts[sortedKeys[i]]!.toDouble()));
      labels.add(sortedKeys[i]);
    }

    return Container(
      padding: EdgeInsets.all(4),
      child: AspectRatio(
        aspectRatio: 1.4,
        child: LineChart(_buildChartData(spots, labels)),
      ),
    );
  }

  LineChartData _buildChartData(List<FlSpot> spots, List<String> labels) {
    return LineChartData(
      minX: 0,
      maxX: spots.length.toDouble() - 1,
      minY: 0,
      maxY: (spots.isNotEmpty
              ? spots.map((e) => e.y).reduce((a, b) => a > b ? a : b)
              : 1) +
          2,
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(
        topTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false, // Do not show top titles
            reservedSize: 20, // Reserve space for titles
            getTitlesWidget: (value, meta) {
              return Text(
                "", // Modify this if you want a custom title
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
            interval: 1, // Set interval for y-axis labels
            reservedSize: 30,
            getTitlesWidget: (value, meta) => Text(value.toInt().toString(),
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
            interval: 1, // Set interval for y-axis labels
            reservedSize: 20,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(
                    color: Color.fromARGB(255, 190, 190, 190), fontSize: 12),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              int index = value.toInt();
              if (index >= 0 && index < labels.length) {
                // Show the date in the format "03-25"
                String shortDate = labels[index].substring(5);
                return Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(shortDate,
                      style: TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center),
                );
              }
              return Container();
            },
            interval: 1,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.white),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          barWidth: 2,
          color: Colors.blueAccent,
          isStrokeCapRound: true,
          belowBarData:
              BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
              radius: 4,
              color: Colors.white,
              strokeColor: Colors.lightBlue,
              strokeWidth: 1,
            ),
          ),
        ),
      ],
    );
  }
}
