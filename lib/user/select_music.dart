import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SelectMusicPage extends StatefulWidget {
  @override
  _SelectMusicPageState createState() => _SelectMusicPageState();
}

class _SelectMusicPageState extends State<SelectMusicPage> {
  String selectedMusic = "";
  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;

  // 推荐音乐列表（标题 + 音乐文件）
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

  void playMusic(String filePath) async {
    await audioPlayer.stop(); // 停止当前音乐
    await audioPlayer.play(AssetSource(filePath)); //play music directly

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
    audioPlayer.dispose(); // 释放音频资源
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
        title: Text("Music Select", style: TextStyle(color: Colors.white54)),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
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

  /// 音乐封面网格
  Widget _buildMusicGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.5,
      ),
      itemCount: musicList.length,
      itemBuilder: (context, index) {
        String title = musicList[index]["title"]!;
        String filePath = musicList[index]["file"]!;
        bool isSelected = selectedMusic == title;

        return GestureDetector(
          onTap: () {
            setState(() {
              if (selectedMusic == title) {
                stopMusic();
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
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
