import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentListPage extends StatelessWidget {
  const AppointmentListPage({super.key});

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
        return query.docs.first.id;
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
            title: Text(
              "Appointment List",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.black,
            iconTheme: IconThemeData(color: Colors.white),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF091E40), Color(0xFF66363A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("appointments")
                  .doc(userId)
                  .collection("user_appointments")
                  .orderBy("date", descending: false)
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

                List<Map<String, dynamic>> appointments =
                    snapshot.data!.docs.map((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  data["id"] = doc.id; // 添加 Firebase 文档 ID
                  return data;
                }).toList();

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
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                          margin: EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            entry.key,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ...entry.value
                            .map((appointment) =>
                                AppointmentCard(appointment, userId))
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

//appointment list widget
class AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final String userId;

  const AppointmentCard(this.appointment, this.userId, {super.key});

  Future<String?> _getDoctorImage(String doctorId) async {
    if (doctorId.isEmpty) return null;

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(doctorId)
          .get();
      if (doc.exists) {
        return doc["profilePic"] as String?;
      }
    } catch (e) {
      print("Error fetching doctor image: $e");
    }
    return null;
  }

  // 删除预约
  void _deleteAppointment(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection("appointments")
          .doc(userId)
          .collection("user_appointments")
          .doc(appointment["id"])
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Appointment deleted successfully")),
      );
    } catch (e) {
      print("Error deleting appointment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete appointment")),
      );
    }
  }

  void _editAppointment(BuildContext context) {
    DateTime selectedDate = DateTime.parse(appointment["date"]);
    TimeOfDay selectedTime = TimeOfDay(
      hour: int.parse(appointment["time"].split(":")[0]),
      minute: int.parse(appointment["time"].split(":")[1].split(" ")[0]),
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Edit Appointment"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title:
                        Text("Date: ${selectedDate.toLocal()}".split(' ')[0]),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: Text("Time: ${selectedTime.format(context)}"),
                    trailing: Icon(Icons.access_time),
                    onTap: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setState(() {
                          selectedTime = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      String newDate =
                          "${selectedDate.toLocal()}".split(' ')[0];
                      String newTime = selectedTime.format(context);
                      String newDocId = "${newDate}_$newTime";

                      FirebaseFirestore firestore = FirebaseFirestore.instance;

                      DocumentSnapshot oldDoc = await firestore
                          .collection("appointments")
                          .doc(userId)
                          .collection("user_appointments")
                          .doc(appointment["id"])
                          .get();

                      if (oldDoc.exists) {
                        Map<String, dynamic> oldData =
                            oldDoc.data() as Map<String, dynamic>;

                        await firestore
                            .collection("appointments")
                            .doc(userId)
                            .collection("user_appointments")
                            .doc(appointment["id"])
                            .delete();

                        oldData["date"] = newDate;
                        oldData["time"] = newTime;

                        await firestore
                            .collection("appointments")
                            .doc(userId)
                            .collection("user_appointments")
                            .doc(newDocId)
                            .set(oldData);

                        // Close the edit dialog first
                        Navigator.pop(context);

                        // Show success confirmation dialog
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              title: Column(
                                children: [
                                  Icon(Icons.check_circle,
                                      color: const Color.fromARGB(255, 236, 236, 236), size: 60),
                                  SizedBox(height: 10),
                                  Text("Change Appointment Info Successfully",
                                      textAlign: TextAlign.center),
                                ],
                              ),
                              actions: [
                                Center(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("OK",
                                        style: TextStyle(color: Colors.blue)),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Appointment not found")),
                        );
                      }
                    } catch (e) {
                      print("Error updating appointment: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to update appointment")),
                      );
                    }
                  },
                  child: Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getDoctorImage(appointment["doctorId"] ?? ""),
      builder: (context, snapshot) {
        String imageUrl = snapshot.data ?? "";

        return Card(
          margin: EdgeInsets.symmetric(vertical: 5),
          color: Colors.blueGrey[700],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  imageUrl.isNotEmpty && imageUrl.startsWith("http")
                      ? NetworkImage(imageUrl)
                      : null,
              radius: 30,
              child: imageUrl.isEmpty || !imageUrl.startsWith("http")
                  ? Icon(Icons.person, size: 10, color: Colors.white)
                  : null,
            ),
            title: Text(
              appointment["doctorName"] ?? "Unknown Doctor",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Problem: ${appointment["problem"] ?? "N/A"}\n"
              "Schedule: \n${appointment["date"]} at ${appointment["time"]}",
              style: TextStyle(color: Colors.white70),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.white),
                  onPressed: () => _editAppointment(context),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.white),
                  onPressed: () => _deleteAppointment(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
