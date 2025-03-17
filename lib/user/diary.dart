import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DiaryScreen extends StatefulWidget {
  @override
  _DiaryScreenState createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  bool _isDiary = true;
  TextEditingController _diaryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1C1C3C), // Dark blue (top)
              Color(0xFF4A148C), // Deep purple (middle)
              Color(0xFF9B59B6), // Soft purple (bottom)
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar with back button and notification icon
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Diary & Emotion',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.notifications, color: Colors.white),
                      onPressed: () {
                        // Add functionality for notifications here
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              // Diary & Emotion toggle buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _toggleButton('Diary', true),
                  SizedBox(width: 10),
                  _toggleButton('Emotion', false),
                ],
              ),
              SizedBox(height: 10),
              // Calendar component
              TableCalendar(
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
                      color: Colors.white),
                  leftChevronIcon:
                      Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon:
                      Icon(Icons.chevron_right, color: Colors.white),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  weekendStyle: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.redAccent),
                ),
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Colors.purpleAccent,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(color: Colors.white),
                  weekendTextStyle: TextStyle(color: Colors.redAccent),
                ),
              ),
              SizedBox(height: 10),
              // Selected date display
              Text(
                '${_selectedDay.day}-${_selectedDay.month}-${_selectedDay.year}',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 10),
              // Diary input field
              _isDiary ? _buildDiaryInput() : Container(),
            ],
          ),
        ),
      ),
    );
  }

  // Toggle button widget
  Widget _toggleButton(String title, bool isDiary) {
    return ElevatedButton(
      onPressed: () {
        setState(() => _isDiary = isDiary);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _isDiary == isDiary ? Colors.purpleAccent : Colors.grey,
      ),
      child: Text(title, style: TextStyle(color: Colors.white)),
    );
  }

  // Diary input field
  Widget _buildDiaryInput() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white
                  .withOpacity(0.1), // Transparent purple background
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _diaryController,
              maxLines: 4,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Write your diary...',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Save diary logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purpleAccent,
            ),
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
