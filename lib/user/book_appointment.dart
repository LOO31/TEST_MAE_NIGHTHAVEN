import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'appointment_list_page.dart';

class BookAppointmentPage extends StatefulWidget {
  final doctor;

  BookAppointmentPage({required this.doctor, Key? key}) : super(key: key);

  @override
  _BookAppointmentPageState createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

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
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  // void _selectTime() async {
  //   TimeOfDay? pickedTime = await showTimePicker(
  //     context: context,
  //     initialTime: TimeOfDay.now(),
  //   );
  //   if (pickedTime != null) {
  //     setState(() {
  //       selectedTime = pickedTime;
  //       _timeController.text = pickedTime.format(context);
  //     });
  //   }
  // }

  void _selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(alwaysUse24HourFormat: false), // Force 12-hour format
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
        _timeController.text =
            pickedTime.format(context); // Ensure AM/PM format
      });
    }
  }

  Future<String> _getCustomUid() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    try {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection("users")
          .where("auth_uid", isEqualTo: user.uid)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.id; // Get customUserId (u1, u2, etc.)
      } else {
        throw Exception("Custom ID not found for user.");
      }
    } catch (e) {
      throw Exception("Error fetching custom UID: $e");
    }
  }

  // Future<void> _submitAppointment() async {
  //   if (!_formKey.currentState!.validate()) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Please fill in all the information")),
  //     );
  //     return;
  //   }

  //   if (selectedDate == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Please select a date")),
  //     );
  //     return;
  //   }

  //   if (selectedTime == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Please select a time")),
  //     );
  //     return;
  //   }

  //   try {
  //     User? currentUser = FirebaseAuth.instance.currentUser;
  //     if (currentUser == null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("User not logged in!")),
  //       );
  //       return;
  //     }

  //     // 获取用户的 Custom UID（例如 u1, u2）
  //     String customUid = await _getCustomUid();

  //     // 格式化日期和时间
  //     String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
  //     String formattedTime =
  //         "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}";

  //     // 生成唯一的预约 ID
  //     String appointmentId = "${formattedDate}_$formattedTime";

  //     // Firestore 预约文档路径
  //     DocumentReference appointmentRef = FirebaseFirestore.instance
  //         .collection("appointments")
  //         .doc(customUid) // 用户 ID（确保 Firestore 允许此路径）
  //         .collection("user_appointments")
  //         .doc(appointmentId);

  //     // 检查是否已有相同的预约
  //     var snapshot = await appointmentRef.get();
  //     if (snapshot.exists) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("This time is not available")),
  //       );
  //       return;
  //     }

  //     // 存储预约信息到 Firestore
  //     await appointmentRef.set({
  //       "userId": customUid, // 使用 u1, u2 等
  //       "authUid": currentUser.uid, // Firebase Auth UID
  //       "doctorId": widget.doctor.id, // 医生 ID
  //       "doctorName": widget.doctor.name,
  //       "date": formattedDate, // 日期
  //       "time": formattedTime, // 时间
  //       "firstName": _firstNameController.text.trim(),
  //       "lastName": _lastNameController.text.trim(),
  //       "email": _emailController.text.trim(),
  //       "phone": _phoneController.text.trim(),
  //       "problem": _problemController.text.trim(),
  //       "timestamp": FieldValue.serverTimestamp(),
  //     });

  //     print("Appointment saved successfully!");

  //     // 成功后弹出对话框
  //     _showDialog("Appointment booked successfully");
  //   } catch (e) {
  //     print("Error booking appointment: ${e.toString()}");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error: ${e.toString()}")),
  //     );
  //   }
  // }

  Future<void> _submitAppointment() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all the information")),
      );
      return;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a date")),
      );
      return;
    }

    if (selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a time")),
      );
      return;
    }

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in!")),
        );
        return;
      }

      // Get custom user ID (e.g., u1, u2)
      String customUid = await _getCustomUid();

      // Format date and time
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
      String formattedTime =
          selectedTime!.format(context); // Ensure AM/PM format

      // Generate a unique appointment ID
      String appointmentId = "${formattedDate}_$formattedTime";

      // Firestore appointment document path
      DocumentReference appointmentRef = FirebaseFirestore.instance
          .collection("appointments")
          .doc(customUid) // User ID (ensure Firestore allows this path)
          .collection("user_appointments")
          .doc(appointmentId);

      // Check if the appointment already exists
      var snapshot = await appointmentRef.get();
      if (snapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("This time is not available")),
        );
        return;
      }

      // Save appointment details to Firestore
      await appointmentRef.set({
        "userId": customUid, // Custom user ID (e.g., u1, u2)
        "authUid": currentUser.uid, // Firebase Auth UID
        "doctorId": widget.doctor.id, // Doctor ID
        "doctorName": widget.doctor.name,
        "date": formattedDate, // Date
        "time": formattedTime, // Time with AM/PM
        "firstName": _firstNameController.text.trim(),
        "lastName": _lastNameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": _phoneController.text.trim(),
        "problem": _problemController.text.trim(),
        "timestamp": FieldValue.serverTimestamp(),
      });

      print("Appointment saved successfully!");

      // Show success dialog
      _showDialog("Appointment booked successfully");
    } catch (e) {
      print("Error booking appointment: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 50),
            SizedBox(height: 10),
            Text(message),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AppointmentListPage()),
              );
            },
            child: Text("View Appointment"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C1C3C), // 统一背景色，避免白色区域
      appBar: AppBar(
        title: Text("Book Appointment"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1C1C3C), Color(0xFF4A148C), Color(0xFF9B59B6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1C1C3C), Color(0xFF4A148C), Color(0xFF9B59B6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      color:
                          Colors.white.withOpacity(0.1), // Slight transparency
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: widget.doctor.image.isNotEmpty
                              ? NetworkImage(widget.doctor.image)
                              : AssetImage("assets/images/default.jpg")
                                  as ImageProvider,
                        ),
                        title: Text(
                          widget.doctor.name,
                          style: TextStyle(color: Colors.white), // White text
                        ),
                        subtitle: Text(
                          widget.doctor.email,
                          style: TextStyle(
                              color: Colors.white70), // Light white text
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(_firstNameController, "First Name"),
                          _buildTextField(_lastNameController, "Last Name"),
                          _buildTextField(_emailController, "Email"),
                          _buildTextField(_phoneController, "Phone"),
                          _buildTextField(
                              _problemController, "Describe your problem"),
                          _buildDateField(),
                          _buildTimeField(),
                          SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      /// bottomNavigationBar
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1C1C3C), Color(0xFF4A148C), Color(0xFF9B59B6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: ElevatedButton(
              onPressed: _submitAppointment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("Submit"),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: Colors.white), // White text
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white), // White label text
          filled: true,
          fillColor: Colors.black54, // **Dark semi-transparent background**
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: Colors.white, width: 2), // **White border**
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: Colors.white, width: 2), // **White border**
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: Colors.white,
                width: 2.5), // **Thicker white border when focused**
          ),
        ),
        validator: (value) => value!.isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: _dateController,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: "Date",
          labelStyle: TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.black54,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white, width: 2.5),
          ),
        ),
        readOnly: true,
        onTap: _selectDate,
      ),
    );
  }

  /// **Time Selection Field**
  Widget _buildTimeField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: _timeController,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: "Time",
          labelStyle: TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.black54,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white, width: 2.5),
          ),
        ),
        readOnly: true,
        onTap: _selectTime,
      ),
    );
  }
}
