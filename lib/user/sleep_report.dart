import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SleepReport extends StatefulWidget {
  final String userId;

  const SleepReport({Key? key, required this.userId}) : super(key: key);

  @override
  _SleepReportState createState() => _SleepReportState();
}

class _SleepReportState extends State<SleepReport> {
  List<SleepData> sleepRecords = [];

  @override
  void initState() {
    super.initState();
    loadSleepData(widget.userId);
  }

  Future<void> loadSleepData(String userId) async {
    try {
      print("Fetching sleep data for userId: $userId");

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("sleepTrack")
          .doc(userId)
          .collection("records")
          .orderBy("date", descending: true)
          .limit(7)
          .get();

      if (snapshot.docs.isEmpty) {
        print("No sleep data found.");
        return;
      }

      List<SleepData> tempRecords = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;

        // 处理日期格式
        DateTime date = DateTime.now();
        if (data['date'] != null) {
          if (data['date'] is Timestamp) {
            date = (data['date'] as Timestamp).toDate();
          } else if (data['date'] is String) {
            try {
              date = DateTime.parse(data['date']);
            } catch (e) {
              print("Date parsing error: $e");
            }
          }
        }

        // 处理 sleepDuration
        double duration = 0;
        if (data['sleepDuration'] is int) {
          duration = (data['sleepDuration'] as int).toDouble();
        } else if (data['sleepDuration'] is double) {
          duration = data['sleepDuration'];
        } else if (data['sleepDuration'] is String) {
          duration = double.tryParse(data['sleepDuration']) ?? 0;
        }

        return SleepData(date: date, duration: duration);
      }).toList();

      setState(() {
        sleepRecords = tempRecords;
      });

      print("Sleep data loaded: $sleepRecords");
    } catch (e) {
      print("Error loading sleep data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF091E40),
      appBar: AppBar(
        title: const Text("Sleep Report"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: sleepRecords.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Recent Sleep Duration",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                Expanded(
                  child: SfCartesianChart(
                    primaryXAxis: DateTimeAxis(),
                    series: <CartesianSeries<SleepData, DateTime>>[
                      LineSeries<SleepData, DateTime>(
                        dataSource: sleepRecords,
                        xValueMapper: (SleepData data, _) => data.date,
                        yValueMapper: (SleepData data, _) => data.duration,
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class SleepData {
  final DateTime date;
  final double duration;

  SleepData({required this.date, required this.duration});
}
