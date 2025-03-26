import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctor_followUpReview.dart';

class FollowUpPage extends StatefulWidget {
  final String email;
  final String patientName;

  FollowUpPage({required this.email, required this.patientName});

  @override
  _FollowUpPageState createState() => _FollowUpPageState();
}

class _FollowUpPageState extends State<FollowUpPage> {
  final _formKey = GlobalKey<FormState>();
  String progress = '';
  String notes = '';
  DateTime followUpDate = DateTime.now();
  String followUpTime = '';
  String followUpType = 'Phone Call';
  String doctorName = '';
  String doctorId = '';
  String patientUid = '';
  TextEditingController doctorNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getDoctorInfo();
    getPatientUid();
  }

  // Fetch doctor information from Firestore
  Future<void> getDoctorInfo() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: widget.email)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var data = snapshot.docs.first.data() as Map<String, dynamic>;
      setState(() {
        doctorName = data['username'] ?? 'Unknown';
        doctorId = snapshot.docs.first.id;
        doctorNameController.text = doctorName;
      });
    }
  }

  // Fetch patient UID from Firestore
  Future<void> getPatientUid() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: widget.patientName)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        patientUid = snapshot.docs.first.id;
      });
    }
  }

  // Generate a new follow-up ID
  Future<String> generateFollowUpId() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('follow_ups')
        .orderBy('fid', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      String lastFid = snapshot.docs.first['fid'];
      int lastNumber = int.parse(lastFid.substring(1));
      return 'f${lastNumber + 1}';
    } else {
      return 'f1';
    }
  }

  // Save follow-up data to Firestore
  Future<void> saveFollowUpData() async {
    if (_formKey.currentState!.validate()) {
      if (progress.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a progress status.')),
        );
        return;
      }

      String newFid = await generateFollowUpId();

      try {
        await FirebaseFirestore.instance
            .collection('follow_ups')
            .doc(newFid)
            .set({
          'fid': newFid,
          'patientUid': patientUid,
          'patientName': widget.patientName,
          'doctorId': doctorId,
          'doctorName': doctorName,
          'progress': progress,
          'notes': notes,
          'followUpDate': "${followUpDate.toLocal()}".split(' ')[0],
          'followUpTime': followUpTime,
          'followUpType': followUpType,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Follow-up saved successfully!')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ReviewFollowUpPage(email: widget.email)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to save data. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Follow Up', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF091E40), Color(0xFF66363A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Center(
                child: Text(
                  'Patient Follow Up Form',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              buildTextField(
                  controller: doctorNameController,
                  label: 'Doctor Name',
                  enabled: false),
              buildTextField(
                  label: 'Patient Name',
                  initialValue: widget.patientName,
                  enabled: false),
              buildDropdown(),
              buildProgressButtons(),
              buildTextField(label: 'Notes', onChanged: (val) => notes = val),
              buildDatePicker(),
              buildTimePicker(),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: saveFollowUpData,
                  child: const Text('Submit Follow Up',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build progress status selection buttons
  Widget buildProgressButtons() {
    List<String> statuses = [
      'Pending', 'In Progress', 'Improving',
      'No Change', 'Critical', 'Completed'
    ];

    List<Color> statusColors = [
      Colors.orange,  // Pending
      Colors.blue,    // In Progress
      Colors.green,   // Improving
      Colors.grey,    // No Change
      Colors.red,     // Critical
      Colors.green,   // Completed
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Follow Up Progress',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(statuses.length, (index) {
              return SizedBox(
                width: (MediaQuery.of(context).size.width - 48) / 3,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: progress == statuses[index]
                        ? statusColors[index]
                        : Colors.black54,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      progress = statuses[index];
                    });
                  },
                  child: Text(statuses[index]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // Build a text input field
  Widget buildTextField(
      {TextEditingController? controller,
      String label = '',
      String? initialValue,
      bool enabled = true,
      Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.black54,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          labelStyle: const TextStyle(color: Colors.white),
        ),
        enabled: enabled,
        style: const TextStyle(color: Colors.white),
        onChanged: onChanged,
      ),
    );
  }

  // Build follow-up type dropdown
  Widget buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: followUpType,
        onChanged: (value) => setState(() => followUpType = value!),
        items: ['Phone Call', 'In Person', 'Email']
            .map((type) => DropdownMenuItem(
                value: type,
                child: Text(type, style: const TextStyle(color: Colors.white))))
            .toList(),
        dropdownColor: Colors.black,
        decoration: InputDecoration(
          labelText: 'Follow Up Type',
          filled: true,
          fillColor: Colors.black54,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          labelStyle: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // Build date picker field
  Widget buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: TextEditingController(
            text: "${followUpDate.toLocal()}".split(' ')[0]),
        decoration: InputDecoration(
          labelText: 'Follow Up Date',
          filled: true,
          fillColor: Colors.black54,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          labelStyle: const TextStyle(color: Colors.white),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: followUpDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                setState(() {
                  followUpDate = pickedDate;
                });
              }
            },
          ),
        ),
        style: const TextStyle(color: Colors.white),
        readOnly: true,
      ),
    );
  }

  // Build time picker field
  Widget buildTimePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: TextEditingController(text: followUpTime),
        decoration: InputDecoration(
          labelText: 'Follow Up Time',
          filled: true,
          fillColor: Colors.black54,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          labelStyle: const TextStyle(color: Colors.white),
          suffixIcon: IconButton(
            icon: const Icon(Icons.access_time, color: Colors.white),
            onPressed: () async {
              TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime != null) {
                setState(() {
                  followUpTime = pickedTime.format(context);
                });
              }
            },
          ),
        ),
        style: const TextStyle(color: Colors.white),
        readOnly: true,
      ),
    );
  }
}