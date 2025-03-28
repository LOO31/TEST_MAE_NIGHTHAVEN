import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DiaryEmotionScreen extends StatefulWidget {
  final String email;

  const DiaryEmotionScreen({super.key, required this.email});

  @override
  _DiaryEmotionScreenState createState() => _DiaryEmotionScreenState();
}

class _DiaryEmotionScreenState extends State<DiaryEmotionScreen> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  bool _isDiary = true;
  final TextEditingController _diaryController = TextEditingController();
  int _selectedIndex = 1;
  List<Map<String, String>> emotions = [
    {"emoji": "😊", "name": "Happy"},
    {"emoji": "😢", "name": "Sad"},
    {"emoji": "😡", "name": "Angry"},
    {"emoji": "😱", "name": "Shocked"},
    {"emoji": "😌", "name": "Relaxed"},
    {"emoji": "😍", "name": "Love"},
    {"emoji": "🤯", "name": "Mind Blown"},
    {"emoji": "😭", "name": "Crying"},
    {"emoji": "😂", "name": "Laughing"},
    {"emoji": "🥳", "name": "Celebrating"},
  ];

  String? selectedEmoji;
  String? selectedEmotionName;

  Future<String?> _getCustomUid() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection("users")
          .where("auth_uid", isEqualTo: user.uid) // Query using `auth_uid`
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.id; // Retrieve customUid
      } else {
        print("Custom ID not found for user.");
      }
    } catch (e) {
      print("Error fetching custom ID: $e");
    }
    return null;
  }

  Future<void> _saveDiaryEntry() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("User not logged in!")));
        return;
      }

      bool isDiaryEmpty = _diaryController.text.trim().isEmpty;
      bool isEmotionEmpty = selectedEmotionName == null;

      if (isDiaryEmpty && isEmotionEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Diary and emotion cannot be empty!")));
        return;
      }

      // 获取用户自定义 UID
      String? userId;
      try {
        userId = await _getCustomUid();
      } catch (e) {
        print("Error fetching custom UID: $e");
      }

      if (userId == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Custom ID not found!")));
        return;
      }

      String formattedDate =
          "${_selectedDay.year}-${_selectedDay.month.toString().padLeft(2, '0')}-${_selectedDay.day.toString().padLeft(2, '0')}";

      // 仅存储不为空的字段
      Map<String, dynamic> diaryData = {
        if (!isDiaryEmpty) "diary": _diaryController.text.trim(),
        if (!isEmotionEmpty) "emotion": selectedEmotionName,
        if (selectedEmoji != null) "emoji": selectedEmoji,
        "timestamp": FieldValue.serverTimestamp(),
      };

      // 写入 Firestore
      await FirebaseFirestore.instance
          .collection("diary")
          .doc(userId)
          .set({formattedDate: diaryData}, SetOptions(merge: true));

      print("Diary entry saved successfully: $diaryData");

      // 清空输入
      _diaryController.clear();
      setState(() {
        selectedEmoji = null;
        selectedEmotionName = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Saved Successfully!"),
          duration: Duration(seconds: 2)));
    } catch (e) {
      print("Error saving diary entry: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to save diary entry!")));
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    String route = '';
    switch (index) {
      case 0:
        route = '/sleepTracker';
        break;
      case 1:
        return;
      case 2:
        route = '/aiDoctor';
        break;
      case 3:
        route = '/report';
        break;
    }

    if (route.isNotEmpty) {
      Navigator.pushReplacementNamed(
        context,
        route,
        arguments: {'email': widget.email},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF091E40), Color(0xFF66363A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _toggleButton('Diary', true),
                  SizedBox(width: 10),
                  _toggleButton('Emotion', false),
                ],
              ),
              SizedBox(height: 10),
              _buildCalendar(),
              SizedBox(height: 10),
              Text(
                '${_selectedDay.day} ${_getMonthName(_selectedDay.month)} ${_selectedDay.year}',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 10),
              _isDiary ? _buildDiaryInput() : _buildEmotionSelector(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bedtime), label: "Sleep"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Diary"),
          BottomNavigationBarItem(
              icon: Icon(Icons.medical_services), label: "AI"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Report"),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // 让内容居中
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Spacer(), // 添加 Spacer 让标题居中
          Text(
            'Diary & Emotion',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Spacer(), // 添加 Spacer 让标题居中
        ],
      ),
    );
  }

  Widget _toggleButton(String title, bool isDiary) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _isDiary = isDiary;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _isDiary == isDiary ? Colors.blueAccent : Colors.grey,
      ),
      child: Text(title, style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2000, 1, 1),
      lastDay: DateTime.utc(2100, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white), // 左箭头白色
        rightChevronIcon:
            Icon(Icons.chevron_right, color: Colors.white), // 右箭头白色
      ),
      calendarStyle: CalendarStyle(
        defaultTextStyle: TextStyle(color: Colors.white), // 默认文字颜色
        weekendTextStyle: TextStyle(
            color: Colors.red, fontWeight: FontWeight.bold), // 周六、周日日期变红色
        selectedDecoration: BoxDecoration(
          color: Colors.blueGrey,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold), // 周一到周五白色
        weekendStyle: TextStyle(
            color: Colors.red, fontWeight: FontWeight.bold), // 周六、周日红色
      ),
    );
  }

  Widget _buildDiaryInput() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _diaryController,
            maxLines: 4,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Write your diary...',
              hintStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white, width: 2),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              _saveDiaryEntry();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Emoji Selector
  Widget _buildEmotionSelector() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Wrap(
            spacing: 15,
            runSpacing: 15,
            alignment: WrapAlignment.center,
            children: emotions.map((emojiMap) {
              bool isSelected = selectedEmoji == emojiMap["emoji"];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedEmoji = emojiMap["emoji"];
                    selectedEmotionName = emojiMap["name"];
                  });
                },
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.purpleAccent
                            : Colors.purpleAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text(
                        emojiMap["emoji"]!,
                        style: TextStyle(
                          fontSize: 40,
                          color: isSelected ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      emojiMap["name"]!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 30),
        Center(
          child: ElevatedButton(
            onPressed: selectedEmoji == null
                ? null
                : () async {
                    await _saveDiaryEntry();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Emotion saved: $selectedEmoji ($selectedEmotionName)'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              disabledBackgroundColor: Colors.grey,
            ),
            child: Text('Save',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return monthNames[month - 1];
  }
}
