import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class AlarmNotificationPage extends StatefulWidget {
  @override
  _AlarmNotificationPageState createState() => _AlarmNotificationPageState();
}

class _AlarmNotificationPageState extends State<AlarmNotificationPage> {
  double progress = 0.0;
  int totalTime = 240; // Total time in seconds (4 minutes)
  int remainingTime = 240;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        setState(() {
          remainingTime--;
          progress = (totalTime - remainingTime) / totalTime;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void stopAlarm() {
    timer?.cancel();
    setState(() {
      remainingTime = 0;
      progress = 1.0;
    });
    print("Alarm Stopped");
    Navigator.pop(context);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF091E40),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Back button
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),

            SizedBox(height: 10),

            // App Name
            Center(
              child: Text(
                "NightHaven",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
            ),

            SizedBox(height: 10),

            // Greeting Text
            Center(
              child: Text(
                "Good Night",
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),

            SizedBox(height: 10),

            // Countdown Timer + Progress Circle
            Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(180, 180),
                  painter: ArcPainter(progress),
                ),
                Column(
                  children: [
                    Text(
                      "${(remainingTime ~/ 60).toString().padLeft(2, '0')} : ${(remainingTime % 60).toString().padLeft(2, '0')}",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Image.asset('assets/images/sleep.jpg', width: 80),
                  ],
                ),
              ],
            ),

            SizedBox(height: 20),

            // Music Player & Alarm Time (ALARM MOVED BELOW MUSIC)
            Column(
              children: [
                // Music Player
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset('assets/images/music.webp',
                            width: 40, height: 40, fit: BoxFit.cover),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Song",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                                overflow: TextOverflow.ellipsis),
                            Text("Playing • 10 min",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12),
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10), // Spacing between Music and Alarm

                // Alarm Time
                Container(
                  width: 100,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.alarm, color: Colors.white, size: 20),
                      SizedBox(width: 5),
                      Text("04:00",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),

            // **Swipe Up to Stop** Gesture
            GestureDetector(
              onVerticalDragUpdate: (details) {
                // Debugging information
                print("Drag detected: ${details.primaryDelta}");
              },
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity != null &&
                    details.primaryVelocity! < -50) {
                  stopAlarm();
                }
              },
              child: Column(
                children: [
                  Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 40),
                  Text("Swipe up to Stop",
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Progress Bar Painter
class ArcPainter extends CustomPainter {
  final double progress;

  ArcPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    Paint circlePaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    Paint progressPaint = Paint()
      ..color = Colors.purpleAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.width / 2;

    canvas.drawCircle(center, radius, circlePaint);

    double startAngle = -pi / 2;
    double sweepAngle = progress * 2 * pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
