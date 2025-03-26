import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SleepReport extends StatefulWidget {
  final String userId;

  const SleepReport({Key? key, required this.userId}) : super(key: key);

  @override
  _SleepReportState createState() => _SleepReportState();
}

class _SleepReportState extends State<SleepReport> {
  List<SleepData> sleepRecords = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    debugPrint('Initializing SleepReport for user: ${widget.userId}');
    _checkConnectivityAndLoad();
  }

  Future<void> _checkConnectivityAndLoad() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(
        () => _hasInternet = connectivityResult != ConnectivityResult.none);
    if (_hasInternet) {
      await _loadSleepData();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No internet connection';
      });
    }
  }

  Future<void> _loadSleepData() async {
    try {
      // Validate user ID
      if (widget.userId.isEmpty) {
        throw Exception('Invalid user ID');
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      debugPrint('Loading data for user: ${widget.userId}');

      // Get data with timeout implementation
      final firestoreRequest = FirebaseFirestore.instance
          .collection("sleepTrack")
          .doc(widget.userId)
          .get();

      final DocumentSnapshot doc = await Future.any([
        firestoreRequest,
        Future.delayed(const Duration(seconds: 10))
            .then((_) => throw Exception('Request timed out after 10 seconds'))
      ]);

      if (!doc.exists) {
        debugPrint('Document does not exist');
        throw Exception('No sleep data found for this user');
      }

      final data = doc.data() as Map<String, dynamic>?;
      debugPrint('Retrieved data keys: ${data?.keys.toList()}');

      if (data == null || data.isEmpty) {
        throw Exception('Document exists but contains no data');
      }

      final tempRecords = <SleepData>[];

      data.forEach((dateStr, entry) {
        try {
          if (!_isValidDateKey(dateStr)) {
            debugPrint('Skipping invalid date key: $dateStr');
            return;
          }

          debugPrint('Processing date: $dateStr, data: $entry');

          if (entry is! Map<String, dynamic>) {
            debugPrint('Invalid entry format for $dateStr');
            return;
          }

          final date = DateTime.tryParse(dateStr);
          if (date == null) {
            debugPrint('Invalid date format: $dateStr');
            return;
          }

          final durationStr = (entry['sleepDuration'] as String?) ?? '0 hr';
          final duration =
              double.tryParse(durationStr.replaceAll(' hr', '')) ?? 0;

          tempRecords.add(SleepData(date: date, duration: duration));
        } catch (e) {
          debugPrint('Error parsing $dateStr: $e');
        }
      });

      if (tempRecords.isEmpty) {
        throw Exception('No valid sleep records found');
      }

      // Sort by date (newest first)
      tempRecords.sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        sleepRecords = tempRecords.take(7).toList(); // Show last 7 days
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Load failed: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  bool _isValidDateKey(String key) {
    return RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF091E40),
      appBar: AppBar(
        title: const Text("Sleep Report"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _hasInternet ? _loadSleepData : null,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    debugPrint(
        'Building body. Loading: $_isLoading, Error: $_errorMessage, Records: ${sleepRecords.length}');

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading sleep data...',
                style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (!_hasInternet)
              ElevatedButton(
                onPressed: _checkConnectivityAndLoad,
                child: const Text('Check Connection'),
              )
            else
              ElevatedButton(
                onPressed: _loadSleepData,
                child: const Text('Try Again'),
              ),
          ],
        ),
      );
    }

    if (sleepRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.nightlight_round, size: 50, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No sleep records found',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSleepData,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        Expanded(
          child: SfCartesianChart(
            primaryXAxis: DateTimeAxis(
              title: AxisTitle(text: 'Date'),
              intervalType: DateTimeIntervalType.days,
              labelStyle: const TextStyle(color: Colors.white),
              axisLine: const AxisLine(color: Colors.white),
            ),
            primaryYAxis: NumericAxis(
              title: AxisTitle(text: 'Hours Slept'),
              minimum: 0,
              maximum: 12,
              interval: 2,
              labelStyle: const TextStyle(color: Colors.white),
              axisLine: const AxisLine(color: Colors.white),
            ),
            series: <CartesianSeries>[
              ColumnSeries<SleepData, DateTime>(
                dataSource: sleepRecords,
                xValueMapper: (data, _) => data.date,
                yValueMapper: (data, _) => data.duration,
                color: Colors.purpleAccent,
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Showing ${sleepRecords.length} most recent records',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

class SleepData {
  final DateTime date;
  final double duration;

  SleepData({required this.date, required this.duration});

  @override
  String toString() =>
      '${date.toLocal().toString().split(' ')[0]}: $duration hours';
}
