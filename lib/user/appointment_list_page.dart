import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentListPage extends StatelessWidget {
  // 🔥 Get current logged-in user ID
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
        return query.docs.first.id; // Custom user ID
      }
    } catch (e) {
      print("Error fetching custom user ID: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getCustomUid(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        String userId = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text("Appointment List"),
            backgroundColor: Colors.blueGrey[900],
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          backgroundColor: Colors.blueGrey[800],
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("appointments")
                .where("user_id", isEqualTo: userId)
                .orderBy("date", descending: true) // Sort by date
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    "No Appointments Found",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                );
              }

              List<Map<String, dynamic>> appointments = snapshot.data!.docs
                  .map((doc) => doc.data() as Map<String, dynamic>)
                  .toList();

              // 🔄 Group by Date
              Map<String, List<Map<String, dynamic>>> groupedAppointments = {};
              for (var appointment in appointments) {
                String date = appointment["date"];
                if (!groupedAppointments.containsKey(date)) {
                  groupedAppointments[date] = [];
                }
                groupedAppointments[date]!.add(appointment);
              }

              return ListView(
                padding: EdgeInsets.all(10),
                children: groupedAppointments.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 📅 Date Header
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                        margin: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.purple[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          entry.key, // Date
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      // 📋 Appointment Cards
                      ...entry.value
                          .map((appointment) => AppointmentCard(appointment))
                    ],
                  );
                }).toList(),
              );
            },
          ),
        );
      },
    );
  }
}

// 📌 Appointment Card Widget
class AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;

  AppointmentCard(this.appointment);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      color: Colors.blueGrey[700],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(
              "assets/doctor_placeholder.png"), // Replace with doctor image if available
          radius: 30,
        ),
        title: Text(
          appointment["doctor_name"],
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Problem: ${appointment["problem"]}",
                style: TextStyle(color: Colors.white70)),
            Text("Schedule: ${appointment["date"]} at ${appointment["time"]}",
                style: TextStyle(color: Colors.white70)),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white54),
        onTap: () {
          // Navigate to appointment details/edit page
        },
      ),
    );
  }
}
