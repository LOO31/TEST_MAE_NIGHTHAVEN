import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'select_music.dart';

class SetAlarmScreen extends StatefulWidget {
  @override
  _SetAlarmScreenState createState() => _SetAlarmScreenState();
}

class _SetAlarmScreenState extends State<SetAlarmScreen> {
  TimeOfDay selectedTime = TimeOfDay(hour: 21, minute: 50);
  String alarmSound = "Good Morning";
  String remarks = "8:30 Class";

  void _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _navigateToSelectMusic() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectMusicPage()),
    );
    if (result != null) {
      setState(() {
        alarmSound = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Alarm", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => _selectTime(context),
            child: Center(
              child: Text(
                "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
                style: TextStyle(fontSize: 48, color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.music_note, color: Colors.white),
            title: Text("Alarm Sound", style: TextStyle(color: Colors.white)),
            trailing: Text(alarmSound, style: TextStyle(color: Colors.white)),
            onTap: _navigateToSelectMusic,
          ),
          ListTile(
            leading: Icon(Icons.notes, color: Colors.white),
            title: Text("Remarks", style: TextStyle(color: Colors.white)),
            trailing: Text(remarks, style: TextStyle(color: Colors.white)),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  TextEditingController controller =
                      TextEditingController(text: remarks);
                  return AlertDialog(
                    backgroundColor: Colors.black87,
                    title: Text("Enter Remarks",
                        style: TextStyle(color: Colors.white)),
                    content: TextField(
                      controller: controller,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          hintText: "Enter remarks",
                          hintStyle: TextStyle(color: Colors.white60)),
                    ),
                    actions: [
                      TextButton(
                        child: Text("Cancel",
                            style: TextStyle(color: Colors.white)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        child:
                            Text("Save", style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          setState(() {
                            remarks = controller.text;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text("Set Alarm",
                    style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
              onPressed: () {
                Navigator.pop(context, {
                  "time": selectedTime,
                  "sound": alarmSound,
                  "remarks": remarks
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
