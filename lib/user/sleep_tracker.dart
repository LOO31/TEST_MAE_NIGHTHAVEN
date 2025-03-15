import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'set_alarm.dart';
import 'select_music.dart';
import 'alarm_notification.dart';

class SleepTracker extends StatefulWidget {
  final String email;

  const SleepTracker({super.key, required this.email});

  @override
  _SleepTrackerState createState() => _SleepTrackerState();
}

class _SleepTrackerState extends State<SleepTracker> {
  TimeOfDay alarmTime = TimeOfDay(hour: 7, minute: 0);
  double sleepDuration = 8;
  int musicDuration = 15;

  TimeOfDay get bedtime {
    int hour = alarmTime.hour - sleepDuration.toInt();
    if (hour < 0) hour += 24;
    return TimeOfDay(hour: hour, minute: alarmTime.minute);
  }

  void _setAlarmTime(TimeOfDay newTime) {
    setState(() {
      alarmTime = newTime;
    });
  }

  void _setBedtime(TimeOfDay newTime) {
    setState(() {
      Duration diff = Duration(
        hours: alarmTime.hour - newTime.hour,
        minutes: alarmTime.minute - newTime.minute,
      );
      sleepDuration = diff.inHours.toDouble();
    });
  }

  void _adjustSleepDuration(double hours) {
    setState(() {
      sleepDuration = hours;
    });
  }

  void _setMusicDuration(int minutes) {
    setState(() {
      musicDuration = minutes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF091E40),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Sleep Tracker', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 250,
            child: SfRadialGauge(
              axes: [
                RadialAxis(
                  minimum: 4,
                  maximum: 12,
                  interval: 1,
                  startAngle: 270,
                  endAngle: 270,
                  axisLineStyle: AxisLineStyle(
                    thickness: 20,
                    gradient: SweepGradient(
                      colors: [Colors.purpleAccent, Color(0xFF66363A)],
                    ),
                  ),
                  pointers: [
                    MarkerPointer(
                      value: sleepDuration,
                      markerHeight: 20,
                      markerWidth: 20,
                      markerType: MarkerType.circle,
                      color: Colors.white,
                      enableDragging: true,
                      onValueChanged: _adjustSleepDuration,
                    ),
                  ],
                  annotations: [
                    GaugeAnnotation(
                      widget: Text(
                        '${sleepDuration.toInt()} hr 00m',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      angle: 90,
                      positionFactor: 0.5,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildOptionCard('Bedtime', '${bedtime.format(context)}',
                  Icons.nightlight_round, () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: bedtime,
                );
                if (picked != null) _setBedtime(picked);
              }),
              SizedBox(width: 10),
              _buildOptionCard('Alarm', alarmTime.format(context), Icons.alarm,
                  () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: alarmTime,
                );
                if (picked != null) _setAlarmTime(picked);
              }),
            ],
          ),
          SizedBox(height: 20),
          _buildListTile(
              'Sleep Duration', '${sleepDuration.toInt()} hr', Icons.timer),
          _buildListTile('Choose Music', '$musicDuration min', Icons.music_note,
              () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SelectMusicPage()));
          }),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purpleAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AlarmNotificationPage()),
              );
            },
            child: Text('Start', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
      String title, String value, IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(height: 5),
            Text(title, style: TextStyle(color: Colors.white)),
            SizedBox(height: 5),
            Text(value,
                style: TextStyle(
                    color: Colors.purpleAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(String title, String value, IconData icon,
      [VoidCallback? onTap]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white),
                SizedBox(width: 10),
                Text(title, style: TextStyle(color: Colors.white)),
              ],
            ),
            Text(value,
                style: TextStyle(
                    color: Colors.purpleAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
