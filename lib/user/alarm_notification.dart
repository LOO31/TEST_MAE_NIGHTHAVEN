import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:math';

class AlarmNotificationPage extends StatefulWidget {
  final String selectedMusic;

  AlarmNotificationPage({required this.selectedMusic});

  @override
  _AlarmNotificationPageState createState() => _AlarmNotificationPageState();
}

class _AlarmNotificationPageState extends State<AlarmNotificationPage>
    with SingleTickerProviderStateMixin {
  double progress = 0.0;
  int totalTime = 240; // 4 minutes
  int remainingTime = 240;
  Timer? timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  late AnimationController _animationController;
  late Animation<Offset> _arrowAnimation;

  @override
  void initState() {
    super.initState();
    startTimer();
    playMusic(widget.selectedMusic);

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _arrowAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(0, -0.3),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
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

  final List<Map<String, String>> musicList = [
    {"title": "Romantic", "file": "assets/audio/romantic.mp3"},
    {"title": "Christmas", "file": "assets/audio/christmas.mp3"},
    {"title": "Dream", "file": "assets/audio/dream.mp3"},
    {"title": "Hip Hop", "file": "assets/audio/hiphop.mp3"},
    {"title": "Holiday", "file": "assets/audio/holiday.mp3"},
    {"title": "Relax", "file": "assets/audio/relax.mp3"},
    {"title": "Yoga", "file": "assets/audio/yoga.mp3"},
    {"title": "New Start", "file": "assets/audio/newstart.mp3"},
    {"title": "Blue Day", "file": "assets/audio/blueday.mp3"},
    {"title": "Night Sky", "file": "assets/audio/nightsky.mp3"},
  ];

  Future<void> playMusic(String musicTitle) async {
    try {
      Map<String, String>? musicItem = musicList.firstWhere(
        (music) => music["title"] == musicTitle,
        orElse: () => {"file": ""},
      );

      String? musicPath = musicItem["file"];
      if (musicPath == null || musicPath.isEmpty) return;

      String assetPath = musicPath.replaceFirst('assets/', '');

      await _audioPlayer.stop();
      await _audioPlayer.setSource(AssetSource(assetPath));
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.resume();

      setState(() {
        isPlaying = true;
      });
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  void stopMusic() async {
    if (!isPlaying) return;
    await _audioPlayer.stop();
    await _audioPlayer.release();
    setState(() {
      isPlaying = false;
    });
  }

  void stopAlarm() {
    timer?.cancel();
    stopMusic();
    setState(() {
      remainingTime = 0;
      progress = 1.0;
    });
    Navigator.pop(context);
  }

  @override
  void dispose() {
    timer?.cancel();
    _audioPlayer.dispose();
    _animationController.dispose();
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
            // Header
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "NightHaven",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 30),

            // Countdown Timer
            Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(180, 180),
                  painter: ArcPainter(progress),
                ),
                Text(
                  "${(remainingTime ~/ 60).toString().padLeft(2, '0')} : ${(remainingTime % 60).toString().padLeft(2, '0')}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            SizedBox(height: 80),

            // Music Player
Padding(
  padding: EdgeInsets.symmetric(horizontal: 20),
  child: Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white10,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/images/music.webp',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.selectedMusic,
                style: TextStyle(color: Colors.white, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                isPlaying ? "Playing" : "Paused",
                style: TextStyle(
                  color: isPlaying ? Colors.white70 : Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
            color: Colors.white,
            size: 35,
          ),
          onPressed: () {
            if (isPlaying) {
              stopMusic();
            } else {
              playMusic(widget.selectedMusic);
            }
          },
        ),
      ],
    ),
  ),
),


            Spacer(),

            // Swipe Up to Stop
            GestureDetector(
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity != null && details.primaryVelocity! < -50) {
                  stopAlarm();
                }
              },
              child: Column(
                children: [
                  SlideTransition(
                    position: _arrowAnimation,
                    child: Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 40),
                  ),
                  Text("Swipe up to Stop", style: TextStyle(color: Colors.white, fontSize: 16)),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArcPainter extends CustomPainter {
  final double progress;
  ArcPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = Colors.white30
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    Paint progressPaint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2, backgroundPaint);
    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
