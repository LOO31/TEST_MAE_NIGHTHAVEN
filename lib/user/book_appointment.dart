import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'appointment_list_page.dart';

class BookAppointmentPage extends StatefulWidget {
  final doctor;

  BookAppointmentPage({required this.doctor});

  @override
  _BookAppointmentPageState createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _problemController =
      TextEditingController(); // Added Problem input field
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  // Select date
  void _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // Select time
  void _selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  // Retrieve custom user_id (e.g., "u1", "u2") from Firestore
  Future<String?> _getCustomUid() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection("users")
          .where("auth_uid", isEqualTo: user.uid) // Query based on `auth_uid`
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.id; // Get custom user_id
      } else {
        print("Custom user ID not found.");
      }
    } catch (e) {
      print("Error fetching custom user ID: $e");
    }
    return null;
  }

  // Submit appointment form
  // 提交预约表单
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (selectedDate == null || selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select date and time")),
        );
        return;
      }

      String? customUserId = await _getCustomUid();
      if (customUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User data not found!")),
        );
        return;
      }

      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
      String formattedTime = selectedTime!.format(context);

      // 构建要存储的预约数据
      Map<String, dynamic> appointmentData = {
        "user_id": customUserId,
        "firstName": _firstNameController.text.trim(),
        "lastName": _lastNameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": _phoneController.text.trim(),
        "date": formattedDate,
        "time": formattedTime,
        "problem": _problemController.text.trim(),
        "doctor_id": widget.doctor.id,
        "doctor_name": widget.doctor.name, // 存医生姓名，方便前端查询
        "timestamp": FieldValue.serverTimestamp(), // Firestore 服务器时间
      };

      // **存储到 Firestore**
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // **1️⃣ 存储到 `appointments` 集合（文档 ID 直接使用 `u1`, `u2`）**
      await firestore
          .collection("appointments")
          .doc(customUserId) // 让 `user_id` 作为文档 ID
          .set(appointmentData, SetOptions(merge: true));

      // **2️⃣ 额外存储到 `users/{user_id}/{date}/{doctor_id}` 结构**
      await firestore
          .collection("users")
          .doc(customUserId)
          .collection(formattedDate) // 日期作为子集合
          .doc(widget.doctor.id) // 以医生 ID 作为文档 ID，避免重复
          .set(appointmentData, SetOptions(merge: true)); // 确保不会覆盖已有数据

// Show confirmation dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 80),
                SizedBox(height: 15),
                Text(
                  "Appointment Booked Successfully!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  _clearForm(); // Clear form inputs
                },
                child: Text("OK", style: TextStyle(fontSize: 16)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AppointmentListPage()),
                  ); // Navigate to appointment list
                },
                child:
                    Text("View Appointments", style: TextStyle(fontSize: 16)),
              ),
            ],
          );
        },
      );
    }
  }

  // Clear the form after submission
  void _clearForm() {
    _formKey.currentState!.reset();
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _problemController.clear(); // Clear problem input field
    setState(() {
      selectedDate = null;
      selectedTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book Appointment"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Doctor info card
            Card(
              color: Colors.grey[850],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(widget.doctor.image),
                  backgroundColor: Colors.grey[800],
                ),
                title: Text(widget.doctor.name,
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.doctor.specialty,
                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Appointment form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(labelText: "First Name"),
                    validator: (value) =>
                        value!.isEmpty ? "Enter First Name" : null,
                  ),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(labelText: "Last Name"),
                    validator: (value) =>
                        value!.isEmpty ? "Enter Last Name" : null,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: "Email"),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        value!.contains('@') ? null : "Enter valid Email",
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: "Phone"),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        value!.length >= 10 ? null : "Enter valid Phone Number",
                  ),
                  SizedBox(height: 20),

                  // Date & Time selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _selectDate,
                        child: Text(selectedDate == null
                            ? "Select Date"
                            : DateFormat('yyyy-MM-dd').format(selectedDate!)),
                      ),
                      ElevatedButton(
                        onPressed: _selectTime,
                        child: Text(selectedTime == null
                            ? "Select Time"
                            : selectedTime!.format(context)),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Problem input field
                  TextFormField(
                    controller: _problemController,
                    decoration:
                        InputDecoration(labelText: "Describe your problem"),
                    maxLines: 3,
                    validator: (value) =>
                        value!.isEmpty ? "Please describe your problem" : null,
                  ),
                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _submitForm,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text("Submit"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
