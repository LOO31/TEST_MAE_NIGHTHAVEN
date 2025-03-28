import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SelectMusicPage extends StatefulWidget {
  const SelectMusicPage({super.key});

  @override
  _SelectMusicPageState createState() => _SelectMusicPageState();
}

class _SelectMusicPageState extends State<SelectMusicPage> {
  String selectedMusic = "";
  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;

  final List<Map<String, String>> musicList = [
    {
      "title": "Romantic",
      "file": "assets/audio/romantic.mp3",
      "image": "assets/images/Romantic.jpg"
    },
    {
      "title": "Christmas",
      "file": "assets/audio/christmas.mp3",
      "image": "assets/images/Christmas.jpg"
    },
    {
      "title": "Dream",
      "file": "assets/audio/dream.mp3",
      "image": "assets/images/Dream.jpeg"
    },
    {
      "title": "Hip Hop",
      "file": "assets/audio/hiphop.mp3",
      "image": "assets/images/HipHop.jpg"
    },
    {
      "title": "Holiday",
      "file": "assets/audio/holiday.mp3",
      "image": "assets/images/Holiday.jpg"
    },
    {
      "title": "Relax",
      "file": "assets/audio/relax.mp3",
      "image": "assets/images/Relax.jpg"
    },
    {
      "title": "Yoga",
      "file": "assets/audio/yoga.mp3",
      "image": "assets/images/Yoga.jpg"
    },
    {
      "title": "New Start",
      "file": "assets/audio/newstart.mp3",
      "image": "assets/images/NewStart.jpeg"
    },
    {
      "title": "Blue Day",
      "file": "assets/audio/blueday.mp3",
      "image": "assets/images/BlueDay.jpg"
    },
    {
      "title": "Night Sky",
      "file": "assets/audio/nightsky.mp3",
      "image": "assets/images/NightSky.jpg"
    },
  ];

  void playMusic(String filePath) async {
    await audioPlayer.stop();
    await audioPlayer.play(AssetSource(filePath.replaceFirst('assets/', '')));

    setState(() {
      isPlaying = true;
    });
  }

  void stopMusic() async {
    await audioPlayer.stop();
    setState(() {
      isPlaying = false;
      selectedMusic = "";
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Select Music", style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {
              if (selectedMusic.isNotEmpty) {
                showSuccessDialog();
              }
            },
            child: Text(
              "Choose",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Music",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildMusicGrid()),
          ],
        ),
      ),
    );
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.black87,
          title: Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 10),
              Text(
                "Music Choose Success",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, selectedMusic);
                },
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMusicGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.4,
      ),
      itemCount: musicList.length,
      itemBuilder: (context, index) {
        String title = musicList[index]["title"]!;
        String filePath = musicList[index]["file"]!;
        String imagePath = musicList[index]["image"]!;
        bool isSelected = selectedMusic == title;

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                stopMusic();
                selectedMusic = "";
              } else {
                selectedMusic = title;
                playMusic(filePath);
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              border:
                  isSelected ? Border.all(color: Colors.blue, width: 3) : null,
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[800],
            ),
            child: Stack(
              children: [
                /// 背景图片填充整个容器
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.music_note,
                        color: Colors.white54,
                        size: 50,
                      ),
                    ),
                  ),
                ),

                /// 遮罩层（让文字更清晰）
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                /// 标题文本
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.8),
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
