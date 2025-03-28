import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'appointment_list_page.dart';

class BookAppointmentPage extends StatefulWidget {
  final doctor;

  const BookAppointmentPage({required this.doctor, super.key});

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
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
        _timeController.text = pickedTime.format(context);
      });
    }
  }

  Future<String> _getCustomUid() async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    var query = await _firestore
        .collection("users")
        .where("auth_uid", isEqualTo: user.uid)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) return query.docs.first.id;
    throw Exception("User ID not found");
  }

  Future<void> _submitAppointment() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all the fields")),
      );
      return;
    }

    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a date and time")),
      );
      return;
    }

    try {
      String customUid = await _getCustomUid();
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
      String formattedTime = selectedTime!.format(context);
      String appointmentId = "${formattedDate}_$formattedTime";

      DocumentReference appointmentRef = _firestore
          .collection("appointments")
          .doc(customUid)
          .collection("user_appointments")
          .doc(appointmentId);

      var snapshot = await appointmentRef.get();
      if (snapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("This time is not available")),
        );
        return;
      }

      await appointmentRef.set({
        "userId": customUid,
        "authUid": _auth.currentUser!.uid,
        "doctorId": widget.doctor.id,
        "doctorName": widget.doctor.name,
        "date": formattedDate,
        "time": formattedTime,
        "firstName": _firstNameController.text.trim(),
        "lastName": _lastNameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": _phoneController.text.trim(),
        "problem": _problemController.text.trim(),
        "timestamp": FieldValue.serverTimestamp(),
      });

      _showDialog("Appointment booked successfully");
    } catch (e) {
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
            child: Text("View Appointments"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 102, 54, 58),
      appBar: AppBar(
        title: Text("Book Appointment", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
                width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF091E40), Color(0xFF66363A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildDoctorInfo(),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
  bottomNavigationBar: Padding(
    padding: EdgeInsets.all(16),
    child: GestureDetector(
      onTap: _submitAppointment,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purpleAccent, Colors.deepPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          "Book Now",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  ),

    );
  }
Widget _buildDoctorInfo() {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    color: Colors.white.withOpacity(0.1),
    elevation: 5,
    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40, // 放大头像
            backgroundImage: widget.doctor.image.isNotEmpty
                ? NetworkImage(widget.doctor.image)
                : AssetImage("assets/images/default.jpg") as ImageProvider,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctor.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20, // 字体更大
                    fontWeight: FontWeight.bold, // 加粗
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  widget.doctor.email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16, // 字体稍微大一点
                  ),
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
    padding: EdgeInsets.symmetric(vertical: 8),
    child: TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.white), // 输入的文本颜色
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white), // Label 文字颜色
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white), // 默认边框颜色
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.deepPurpleAccent), // 选中时的边框颜色
        ),
      ),
    ),
  );
}

Widget _buildDateField() {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: TextFormField(
      controller: _dateController,
      readOnly: true,
      style: TextStyle(color: Colors.white), // 输入的文本颜色
      decoration: InputDecoration(
        labelText: "Select Date",
        labelStyle: TextStyle(color: Colors.white), // Label 文字颜色
        suffixIcon: Icon(Icons.calendar_today, color: Colors.white), // 图标颜色
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white), // 默认边框颜色
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.deepPurpleAccent), // 选中时的边框颜色
        ),
      ),
      onTap: _selectDate,
    ),
  );
}

Widget _buildTimeField() {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: TextFormField(
      controller: _timeController,
      readOnly: true,
      style: TextStyle(color: Colors.white), // 输入的文本颜色
      decoration: InputDecoration(
        labelText: "Select Time",
        labelStyle: TextStyle(color: Colors.white), // Label 文字颜色
        suffixIcon: Icon(Icons.access_time, color: Colors.white), // 图标颜色
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white), // 默认边框颜色
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.deepPurpleAccent), // 选中时的边框颜色
        ),
      ),
      onTap: _selectTime,
    ),
  );
}
}
