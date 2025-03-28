import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class SleepReport extends StatefulWidget {
  final String email;

  const SleepReport({super.key, required this.email});

  @override
  _SleepReportState createState() => _SleepReportState();
}

class _SleepReportState extends State<SleepReport> {
  DateTime _selectedDate = DateTime.now();
  double _sleepDuration = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSleepData();
  }

  Future<void> _fetchSleepData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: widget.email)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) {
        throw Exception("User not found");
      }

      final userId = userSnapshot.docs.first.id;
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

      final doc = await FirebaseFirestore.instance
          .collection("sleepTrack")
          .doc(userId)
          .get();

      if (!doc.exists || !doc.data()!.containsKey(formattedDate)) {
        throw Exception("No sleep data for $formattedDate");
      }

      final sleepData = doc.data()![formattedDate] as Map<String, dynamic>;
      final durationStr = sleepData['sleepDuration'] as String? ?? '0 hr';
      final duration = double.tryParse(durationStr.replaceAll(' hr', '')) ?? 0;

      setState(() {
        _sleepDuration = duration;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _sleepDuration = 0;
      });
    }
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
      _fetchSleepData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF091E40), Color(0xFF66363A)], // 背景渐变颜色
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // 让 Scaffold 背景透明
        appBar: AppBar(
          title: const Text("Sleep Report",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black, // Header 设为黑色
          iconTheme: const IconThemeData(color: Colors.white), // 返回箭头设为白色
        ),
        body: Column(
          children: [
            _buildDateSelector(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_left, color: Colors.white), // 箭头设为白色
            onPressed: () => _changeDate(-1),
          ),
          Text(
            DateFormat('yyyy-MM-dd').format(_selectedDate),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), // 字体设为白色
          ),
          IconButton(
            icon: const Icon(Icons.arrow_right, color: Colors.white), // 箭头设为白色
            onPressed: () => _changeDate(1),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    if (_errorMessage != null) {
      return Center(
        child: Text(_errorMessage!,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SfCartesianChart(
        backgroundColor: Colors.transparent, // 透明背景
        primaryXAxis: DateTimeAxis(
          title: AxisTitle(text: 'Slept Time', textStyle: const TextStyle(color: Colors.white)),
          labelStyle: const TextStyle(color: Colors.white),
          axisLine: const AxisLine(color: Colors.white),
          majorTickLines: const MajorTickLines(color: Colors.white),
          majorGridLines: const MajorGridLines(color: Colors.white54),
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(text: 'Hours Slept', textStyle: const TextStyle(color: Colors.white)),
          labelStyle: const TextStyle(color: Colors.white),
          axisLine: const AxisLine(color: Colors.white),
          majorTickLines: const MajorTickLines(color: Colors.white),
          majorGridLines: const MajorGridLines(color: Colors.white54),
        ),
        series: <CartesianSeries<SleepData, DateTime>>[
          ColumnSeries<SleepData, DateTime>(
            dataSource: [SleepData(_selectedDate, _sleepDuration)],
            xValueMapper: (data, _) => data.date,
            yValueMapper: (data, _) => data.duration,
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(color: Colors.white),
            ),
            color: const Color.fromARGB(255, 138, 209, 227), // 柱状图颜色设为白色
          ),
        ],
      ),
    );
  }
}

class SleepData {
  final DateTime date;
  final double duration;

  SleepData(this.date, this.duration);
}
