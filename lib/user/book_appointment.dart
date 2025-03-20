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

  void _selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
        _timeController.text = pickedTime.format(context);
      });
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

  // Future<void> _submitAppointment() async {
  //   if (!_formKey.currentState!.validate()) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("pls fill in all the information")),
  //     );
  //     return;
  //   }
  //   if (selectedDate == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("pls select date")),
  //     );
  //     return;
  //   }
  //   if (selectedTime == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("pls select time")),
  //     );
  //     return;
  //   }

  //   String userId = FirebaseAuth.instance.currentUser!.uid;
  //   String formattedTime = selectedTime!.format(context);
  //   String appointmentId = "${_dateController.text}_$formattedTime";

  //   DocumentReference appointmentRef = FirebaseFirestore.instance
  //       .collection("appointments")
  //       .doc(userId) // 用户ID作为document
  //       .collection("user_appointments") // 预约集合
  //       .doc(appointmentId); // 预约ID

  //   // 查询该用户是否已在该时间预约了其他医生
  //   var snapshot = await appointmentRef.get();
  //   if (snapshot.exists) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("this time is not available")),
  //     );
  //     return;
  //   }

  //   // 预约存储
  //   await appointmentRef.set({
  //     "userId": userId,
  //     "doctorId": widget.doctor.id,
  //     "date": _dateController.text,
  //     "time": formattedTime,
  //     "firstName": _firstNameController.text,
  //     "lastName": _lastNameController.text,
  //     "email": _emailController.text,
  //     "phone": _phoneController.text,
  //     "problem": _problemController.text,
  //   });

  //   print(
  //       "Appointment saved under: appointments/$userId/user_appointments/$appointmentId");

  //   _showDialog("Appointment booked successfully");
  // }

  Future<void> _submitAppointment() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all the information")),
      );
      return;
    }
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select both date and time")),
      );
      return;
    }

    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in!")),
      );
      return;
    }

    String userId = currentUser.uid;

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
    String formattedTime =
        "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}";

    Map<String, dynamic> appointmentData = {
      "userId": userId,
      "doctorId": widget.doctor.id,
      "firstName": _firstNameController.text.trim(),
      "lastName": _lastNameController.text.trim(),
      "email": _emailController.text.trim(),
      "phone": _phoneController.text.trim(),
      "problem": _problemController.text.trim(),
      "date": formattedDate,
      "time": formattedTime,
      "timestamp": FieldValue.serverTimestamp(),
    };

    try {
      await _firestore
          .collection("users")
          .doc(userId)
          .collection("appointments")
          .doc("$formattedDate-$formattedTime")
          .set(appointmentData);

      print("Appointment saved successfully: $appointmentData");

      _showDialog("Appointment booked successfully");
    } catch (e) {
      print("Error saving appointment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save appointment!")),
      );
    }
  }

  // Future<void> _submitAppointment() async {
  //   if (!_formKey.currentState!.validate()) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Please fill in all the information")),
  //     );
  //     return;
  //   }
  //   if (selectedDate == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Please select a date")),
  //     );
  //     return;
  //   }
  //   if (selectedTime == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Please select a time")),
  //     );
  //     return;
  //   }

  //   String userId = FirebaseAuth.instance.currentUser!.uid;
  //   String formattedTime = "${selectedTime!.hour}:${selectedTime!.minute}";
  //   String appointmentId =
  //       "${_dateController.text}_$formattedTime"; // Unique appointment ID

  //   // Correct Firestore DocumentReference
  //   DocumentReference appointmentRef = FirebaseFirestore.instance
  //       .collection("appointments") // Top-level collection
  //       .doc(userId) // User document
  //       .collection("appointments") // Subcollection for appointments
  //       .doc(appointmentId); // Appointment document

  //   // Check if the appointment already exists
  //   var snapshot = await appointmentRef.get();
  //   if (snapshot.exists) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("This time is not available")),
  //     );
  //     return;
  //   }

  //   // Save the appointment to Firestore
  //   await appointmentRef.set({
  //     "userId": userId,
  //     "doctorId": widget.doctor.id,
  //     "date": _dateController.text,
  //     "time": formattedTime,
  //     "firstName": _firstNameController.text,
  //     "lastName": _lastNameController.text,
  //     "email": _emailController.text,
  //     "phone": _phoneController.text,
  //     "problem": _problemController.text,
  //   }).then((_) {
  //     _showDialog("Appointment booked successfully");
  //   }).catchError((error) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Failed to book appointment: $error")),
  //     );
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Book Appointment")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: widget.doctor.image.isNotEmpty
                      ? NetworkImage(widget.doctor.image)
                      : AssetImage("assets/images/default.jpg")
                          as ImageProvider,
                ),
                title: Text(widget.doctor.name),
                subtitle: Text(widget.doctor.email),
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
                  _buildTextField(_problemController, "Describe your problem"),
                  _buildDateField(),
                  _buildTimeField(),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitAppointment,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
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

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
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
        decoration: InputDecoration(
          labelText: "Date",
          border: OutlineInputBorder(),
        ),
        readOnly: true,
        onTap: _selectDate,
      ),
    );
  }

  Widget _buildTimeField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: _timeController,
        decoration: InputDecoration(
          labelText: "Time",
          border: OutlineInputBorder(),
        ),
        readOnly: true,
        onTap: _selectTime,
      ),
    );
  }
}
