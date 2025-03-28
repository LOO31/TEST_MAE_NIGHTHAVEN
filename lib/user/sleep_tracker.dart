import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String chosenMusic = "No music selected";
  DateTime selectedDate = DateTime.now();
  Map<String, double> sleepData =
      {}; // Declare sleepData as a Map to store sleep records

  // retrieve the user ID
  Future<String?> _getCustomUid() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection("users")
          .where("auth_uid", isEqualTo: user.uid)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.id;
      } else {
        print("Custom ID not found for user.");
      }
    } catch (e) {
      print("Error fetching custom ID: $e");
    }
    return null;
  }

  Future<void> saveSleepData() async {
    try {
      String? userId = await _getCustomUid();

      if (userId == null) {
        print("Error: Custom ID not found!");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Custom ID not found!"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      String formatTime12Hour(TimeOfDay time) {
        final int hour =
            time.hour == 0 || time.hour == 12 ? 12 : time.hour % 12;
        final String period = time.hour < 12 ? "AM" : "PM";
        return "$hour:${time.minute.toString().padLeft(2, '0')} $period";
      }

      String formattedDate =
          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

      Map<String, dynamic> sleepData = {
        "bedtime": formatTime12Hour(bedtime),
        "alarmTime": formatTime12Hour(alarmTime),
        "sleepDuration": "${sleepDuration.toInt()} hr",
        "chosenMusic": chosenMusic,
        "timestamp": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection("sleepTrack")
          .doc(userId)
          .set({
        formattedDate: sleepData,
      }, SetOptions(merge: true));

      print("Sleep data saved successfully!");
      _showSuccessDialog();
    } catch (e) {
      print("Error saving sleep data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save sleep data!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 成功图标
                Icon(Icons.check_circle, color: Colors.green, size: 60),
                SizedBox(height: 15),

                /// 标题
                Text(
                  "Alarm Set Successfully!",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),

                /// 文字说明
                Text(
                  "Your alarm has been set. You can preview your selected music now.",
                  style: TextStyle(color: Colors.black38, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),

                /// 按钮区域
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// 取消按钮
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            Text("OK", style: TextStyle(color: Colors.black45)),
                      ),
                    ),
                    SizedBox(width: 10),

                    /// 播放音乐按钮
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AlarmNotificationPage(
                                  selectedMusic: chosenMusic),
                            ),
                          );
                        },
                        icon: Icon(Icons.music_note, color: Colors.white),
                        label: Text(
                          "Play Music",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Future<void> loadSleepData() async {
  //   try {
  //     String? userId = await _getCustomUid();
  //     if (userId == null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Custom ID not found!")),
  //       );
  //       return;
  //     }

  //     DocumentSnapshot snapshot = await FirebaseFirestore.instance
  //         .collection("sleepTrack")
  //         .doc(userId)
  //         .get();

  //     if (snapshot.exists) {
  //       var data = snapshot.data() as Map<String, dynamic>;

  //       setState(() {
  //         sleepDuration = (data['sleepDuration'] ?? 8).toDouble();
  //         chosenMusic = data['chosenMusic'] ?? "No music selected";

  //         List<String> bedtimeParts = (data['bedtime'] ?? "23:00").split(":");
  //         bedtime = TimeOfDay(
  //             hour: int.parse(bedtimeParts[0]),
  //             minute: int.parse(bedtimeParts[1]));

  //         List<String> alarmParts = (data['alarmTime'] ?? "07:00").split(":");
  //         alarmTime = TimeOfDay(
  //             hour: int.parse(alarmParts[0]), minute: int.parse(alarmParts[1]));
  //       });

  //       print("Sleep data loaded: $data");
  //     } else {
  //       print("No sleep data found.");
  //     }
  //   } catch (e) {
  //     print("Error loading sleep data: $e");
  //   }
  // }
  Future<void> loadSleepData() async {
    try {
      String? userId = await _getCustomUid();
      if (userId == null) return;

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("sleepTrack")
          .doc(userId)
          .collection("records") // 这里假设 Firestore 里有每天的 sleep 记录
          .orderBy("date", descending: true)
          .limit(7) // 只获取最近 7 天
          .get();

      if (snapshot.docs.isEmpty) {
        print("No sleep data found.");
        return;
      }

      Map<String, double> tempData = {};
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String date = data['date']; // 格式："2025-03-25"
        double duration = (data['sleepDuration'] ?? 0).toDouble();
        tempData[date] = duration;
      }

      setState(() {
        sleepData = tempData; // 这里存最近 7 天的数据
      });

      print("Sleep data loaded: $tempData");
    } catch (e) {
      print("Error loading sleep data: $e");
    }
  }

  bool _isStartButtonEnabled() {
    return sleepDuration >= 4 && chosenMusic != "No music selected";
  }

  TimeOfDay bedtime = TimeOfDay(hour: 23, minute: 0);

  void _setAlarmTime(TimeOfDay newTime) {
    setState(() {
      alarmTime = newTime;

      int bedtimeMinutes = bedtime.hour * 60 + bedtime.minute;
      int alarmMinutes = alarmTime.hour * 60 + alarmTime.minute;

      int durationMinutes = (alarmMinutes - bedtimeMinutes + 1440) % 1440;
      sleepDuration = durationMinutes / 60.0;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // 格式化日期为字符串
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void _setBedtime(TimeOfDay newTime) {
    setState(() {
      bedtime = newTime;

      int bedtimeMinutes = bedtime.hour * 60 + bedtime.minute;
      int alarmMinutes = alarmTime.hour * 60 + alarmTime.minute;

      int durationMinutes = (alarmMinutes - bedtimeMinutes + 1440) % 1440;
      sleepDuration = durationMinutes / 60.0;
    });
  }

  void _adjustSleepDuration(double hours) {
    setState(() {
      sleepDuration = hours;
      _updateBedtime(); // Ensure bedtime updates when sleep duration changes
    });
  }

  void _updateSleepDuration() {
    setState(() {
      int bedtimeMinutes =
          (alarmTime.hour * 60 + alarmTime.minute - sleepDuration * 60).toInt();
      if (bedtimeMinutes < 0) bedtimeMinutes += 1440;

      int alarmMinutes = alarmTime.hour * 60 + alarmTime.minute;
      int durationMinutes = (alarmMinutes - bedtimeMinutes + 1440) % 1440;

      sleepDuration = durationMinutes / 60.0;
    });
  }

  // void _updateBedtime() {
  //   setState(() {
  //     int bedtimeHour = (alarmTime.hour - sleepDuration.toInt()) % 24;
  //     if (bedtimeHour < 0) bedtimeHour += 24;
  //   });
  // }
  void _updateBedtime() {
    setState(() {
      DateTime alarmDT = DateTime(2000, 1, 1, alarmTime.hour, alarmTime.minute);
      DateTime bedtimeDT =
          alarmDT.subtract(Duration(hours: sleepDuration.toInt()));

      bedtime = TimeOfDay(hour: bedtimeDT.hour, minute: bedtimeDT.minute);
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF091E40), Color(0xFF66363A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
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
                height: 250, // 调整 Gauge 高度
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
                          colors: [
                            Color.fromARGB(255, 136, 206, 206),
                            Color.fromARGB(255, 71, 111, 119)
                          ],
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
              SizedBox(height: 15),
              _buildOptionCard(
                'Select Date',
                '${selectedDate.toLocal()}'.split(' ')[0],
                Icons.calendar_today,
                () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null && pickedDate != selectedDate) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildOptionCard('Bedtime', bedtime.format(context),
                      Icons.nightlight_round, () async {
                    TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: bedtime,
                    );
                    if (picked != null) _setBedtime(picked);
                  }),
                  SizedBox(width: 10),
                  _buildOptionCard(
                      'Alarm', alarmTime.format(context), Icons.alarm,
                      () async {
                    TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: alarmTime,
                    );
                    if (picked != null) _setAlarmTime(picked);
                  }),
                ],
              ),
              SizedBox(height: 10),
              _buildListTile(
                  'Sleep Duration', '${sleepDuration.toInt()} hr', Icons.timer),
              _buildListTile('Choose Music', chosenMusic, Icons.music_note,
                  () async {
                final selectedMusic = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SelectMusicPage()),
                );

                if (selectedMusic != null) {
                  setState(() {
                    chosenMusic = selectedMusic;
                  });
                }
              }),
              SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isStartButtonEnabled() ? Colors.black : Colors.blueGrey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                onPressed: _isStartButtonEnabled()
                    ? () async {
                        await saveSleepData();
                        _showSuccessDialog();
                      }
                    : null,
                child: Text('Start',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
      String title, String value, IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: EdgeInsets.all(20),
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
                    color: const Color.fromARGB(255, 102, 194, 227),
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
                    color: const Color.fromARGB(255, 102, 194, 227),
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
