import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PatientSleepDataPage extends StatelessWidget {
  final String email;
  final String patientName;

  const PatientSleepDataPage(
      {super.key, required this.email, required this.patientName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Sleep Data',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF091E40), Color(0xFF66363A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<String>(
            future: getUserIdByPatientName(patientName),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: Text('No user data found.'));
              }

              String patientId = snapshot.data!;
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('sleepTrack')
                    .doc(patientId) // Use patientId to fetch the specific user's sleep data
                    .snapshots(),
                builder: (context, sleepSnapshot) {
                  if (sleepSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (sleepSnapshot.hasError) {
                    return Center(child: Text('Error: ${sleepSnapshot.error}'));
                  }

                  if (!sleepSnapshot.hasData || !sleepSnapshot.data!.exists) {
                    return const Center(
                        child: Text('No sleep data available.'));
                  }

                  var sleepData =
                      sleepSnapshot.data!.data() as Map<String, dynamic>;

                  // Collecting all the sleep data from the nested date keys
                  List<Widget> sleepDataList = [];
                  sleepData.forEach((dateKey, data) {
                    // Extracting the date as a string (e.g., "2025-03-24")
                    var date = dateKey;

                    // Extracting alarmTime, bedtime, sleepDuration, chosenMusic
                    var alarmTime = data['alarmTime'];
                    var bedtime = data['bedtime'];
                    var sleepDuration = data['sleepDuration'];
                    var chosenMusic = data['chosenMusic'];

                    // Calculate sleep quality based on bedtime, alarmTime, and sleepDuration
                    var sleepQuality = calculateSleepQuality(
                        date, bedtime, alarmTime, sleepDuration);

                    sleepDataList.add(
                      SleepDataCard(
                        date: date,
                        bedtime: bedtime,
                        wakeTime: alarmTime,
                        sleepDuration: sleepDuration,
                        chosenMusic: chosenMusic,
                        sleepQuality: sleepQuality,
                      ),
                    );
                  });

                  // Display the patient name at the top of the list
                  return Center(
                    // Centering the content on the screen
                    child: Column(
                      mainAxisSize: MainAxisSize
                          .min, // Makes the column take up only as much space as it needs
                      children: [
                        Text(
                          patientName, // Display the patient's name here
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(
                            height:
                                10), // Add some space between the name and the list
                        Expanded(
                          child: ListView(children: sleepDataList),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // Fetch userId by patientName from users collection
  Future<String> getUserIdByPatientName(String patientName) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: patientName)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Get the document ID as the userId
      return snapshot.docs.first.id;
    } else {
      throw Exception('No user found for the given patient name.');
    }
  }

  String convertTo24HourFormat(String time) {
    // Extract time parts (hour, minute, AM/PM)
    int hour = int.parse(time.split(":")[0]);
    int minute = int.parse(time.split(":")[1].split(" ")[0]);
    String ampm = time.split(" ")[1].toUpperCase(); // AM or PM

    // Convert to 24-hour format
    if (ampm == "PM" && hour != 12) {
      hour += 12;
    } else if (ampm == "AM" && hour == 12) {
      hour = 0; // 12 AM is 00 in 24-hour format
    }

    // Format the time to "HH:mm" (24-hour format)
    return "$hour:${minute.toString().padLeft(2, '0')}";
  }

  String calculateSleepQuality(
      String date, String bedtime, String wakeTime, String sleepDuration) {
    try {
      // 1. Convert time to 24-hour format
      String bedtime24Hour = convertTo24HourFormat(bedtime);
      String wakeTime24Hour = convertTo24HourFormat(wakeTime);

      // 2. Parse date and time
      DateTime dateOnly = DateTime.parse(date);
      
      List<String> bedtimeParts = bedtime24Hour.split(':');
      DateTime bedtimeTime = DateTime(
        dateOnly.year,
        dateOnly.month,
        dateOnly.day,
        int.parse(bedtimeParts[0]),
        int.parse(bedtimeParts[1]),
      );
      
      List<String> wakeParts = wakeTime24Hour.split(':');
      DateTime wakeTimeParsed = DateTime(
        dateOnly.year,
        dateOnly.month,
        dateOnly.day,
        int.parse(wakeParts[0]),
        int.parse(wakeParts[1]),
      );

      // 3. Handle overnight sleep (if wake time is before bedtime, it's next day)
      if (wakeTimeParsed.isBefore(bedtimeTime)) {
        wakeTimeParsed = wakeTimeParsed.add(const Duration(days: 1));
      }

      // 4. Calculate actual sleep duration (hours)
      double actualHours = wakeTimeParsed.difference(bedtimeTime).inMinutes / 60.0;
      
      // 5. Parse recorded sleep duration
      double recordedHours = double.parse(sleepDuration.split(" ")[0]);

      // 6. Calculate sleep quality (considering three factors)
      // a. Duration score (0-40 points)
      double durationScore = 0;
      if (recordedHours >= 7 && recordedHours <= 9) {
        durationScore = 40; // Ideal duration
      } else if (recordedHours >= 6 && recordedHours < 7) {
        durationScore = 30; // Slightly short
      } else if (recordedHours > 9 && recordedHours <= 10) {
        durationScore = 30; // Slightly long
      } else if (recordedHours >= 5 && recordedHours < 6) {
        durationScore = 20; // Insufficient
      } else if (recordedHours > 10) {
        durationScore = 20; // Excessive
      } else {
        durationScore = 10; // Severely insufficient
      }

      // b. Sleep window score (0-30 points)
      double timeWindowScore = 0;
      int bedtimeHour = bedtimeTime.hour;
      if (bedtimeHour >= 22 && bedtimeHour <= 23) {
        timeWindowScore = 30; // Best sleep window (10PM-12AM)
      } else if (bedtimeHour >= 21 && bedtimeHour < 22) {
        timeWindowScore = 25; // Good (9PM-10PM)
      } else if (bedtimeHour >= 0 && bedtimeHour <= 3) {
        timeWindowScore = 15; // Too late (after midnight)
      } else {
        timeWindowScore = 20; // Other time
      }

      // c. Consistency score (0-30 points)
      double consistencyScore = 0;
      double discrepancy = (actualHours - recordedHours).abs();
      if (discrepancy <= 0.5) {
        consistencyScore = 30; // Very consistent
      } else if (discrepancy <= 1.0) {
        consistencyScore = 20; // Fairly consistent
      } else if (discrepancy <= 2.0) {
        consistencyScore = 10; // Significant difference
      }

      // 7. Total score calculation (max 100 points)
      double totalScore = durationScore + timeWindowScore + consistencyScore;

      // 8. Evaluate sleep quality
      if (totalScore >= 80) {
        return "Excellent";
      } else if (totalScore >= 70) {
        return "Good";
      } else if (totalScore >= 60) {
        return "Fair";
      } else {
        return "Poor";
      }
    } catch (e) {
      print("Error in calculateSleepQuality: $e");
      return "Unknown";
    }
  }
}

class SleepDataCard extends StatelessWidget {
  final String date;
  final String bedtime;
  final String wakeTime;
  final String sleepDuration;
  final String chosenMusic;
  final String sleepQuality;

  const SleepDataCard({
    super.key,
    required this.date,
    required this.bedtime,
    required this.wakeTime,
    required this.sleepDuration,
    required this.chosenMusic,
    required this.sleepQuality,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.2),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(date, style: const TextStyle(color: Colors.white)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Bedtime: $bedtime",
                style: TextStyle(color: Colors.grey[300])),
            Text("Wake Time: $wakeTime",
                style: TextStyle(color: Colors.grey[300])),
            Text("Duration: $sleepDuration",
                style: TextStyle(color: Colors.grey[300])),
            Text("Chosen Music: $chosenMusic",
                style: TextStyle(color: Colors.grey[300])),
            Text("Sleep Quality: $sleepQuality",
                style: TextStyle(color: Colors.grey[300])),
          ],
        ),
      ),
    );
  }
}