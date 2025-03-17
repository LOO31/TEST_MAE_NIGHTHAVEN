import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DiaryEmotionScreen extends StatefulWidget {
  final String email;

  const DiaryEmotionScreen({Key? key, required this.email}) : super(key: key);

  @override
  _DiaryEmotionScreenState createState() => _DiaryEmotionScreenState();
}

class _DiaryEmotionScreenState extends State<DiaryEmotionScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  bool _isDiary = true;
  TextEditingController _diaryController = TextEditingController();
  int _selectedIndex = 1;
  List<String> emojis = [
    '😊',
    '😢',
    '😡',
    '😱',
    '😌',
    '😍',
    '🤯',
    '😭',
    '😂',
    '🥳'
  ];
  String? selectedEmoji;

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
            colors: [Color(0xFF1C1C3C), Color(0xFF4A148C), Color(0xFF9B59B6)],
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
        backgroundColor: Color(0xFF4A148C),
        selectedItemColor: Colors.black,
        unselectedItemColor: Color(0xFF9C27B0),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text('Diary & Emotion',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          IconButton(
              icon: Icon(Icons.notifications, color: Colors.white),
              onPressed: () {}),
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
        backgroundColor:
            _isDiary == isDiary ? Colors.purpleAccent : Colors.grey,
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
          titleCentered: true,
          titleTextStyle: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      calendarStyle:
          CalendarStyle(defaultTextStyle: TextStyle(color: Colors.white)),
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
                hintStyle: TextStyle(color: Colors.white70)),
          ),
          SizedBox(height: 10),
          ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent),
              child: Text('Save', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  // Emoji Selector
  Widget _buildEmotionSelector() {
    return Column(
      children: [
        // Wrap inside SingleChildScrollView for horizontal scrolling
        SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Horizontal scrolling
          child: Wrap(
            spacing: 15,
            runSpacing: 15, // Emojis will wrap when they exceed the width
            alignment: WrapAlignment.center,
            children: emojis.map((emoji) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedEmoji = emoji;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selectedEmoji == emoji
                        ? Colors.purpleAccent
                        : Colors.purpleAccent.withAlpha((0.2 * 255).toInt()),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    emoji,
                    style: TextStyle(
                      fontSize: 40,
                      color:
                          selectedEmoji == emoji ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 30),

        // Save Button
        Center(
          child: ElevatedButton(
            onPressed: selectedEmoji == null
                ? null
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Emotion saved: $selectedEmoji'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purpleAccent,
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
