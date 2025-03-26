import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:math';

class NotesRecommendationsPage extends StatefulWidget {
  final String email;
  final String patientName;

  const NotesRecommendationsPage({
    super.key,
    required this.email,
    required this.patientName,
  });

  @override
  State<NotesRecommendationsPage> createState() =>
      _NotesRecommendationsPageState();
}

class _NotesRecommendationsPageState extends State<NotesRecommendationsPage> {
  String doctorId = "";
  String doctorName = "";
  String patientId = "";
  String patientEmail = "";

  final TextEditingController dateController = TextEditingController();
  final TextEditingController diagnosisController = TextEditingController();
  final TextEditingController treatmentController = TextEditingController();
  final TextEditingController lifestyleController = TextEditingController();
  final TextEditingController medicationController = TextEditingController();
  final TextEditingController additionalNotesController =
      TextEditingController();

  final Random _random = Random();
  final List<Map<String, dynamic>> _aiRecommendations = [
    {
      "Diagnosis": "Insomnia (Chronic & Acute)",
      "Treatment": [
        "Cognitive Behavioral Therapy (CBT-I)",
        "Medication Management"
      ],
      "Lifestyle": [
        "Establish a Regular Sleep Schedule",
        "Avoid Caffeine & Alcohol Before Bed"
      ],
      "Medication": "Melatonin Supplements",
    },
    {
      "Diagnosis": "Sleep Apnea",
      "Treatment": [
        "Continuous Positive Airway Pressure (CPAP)",
        "Behavioral Therapy"
      ],
      "Lifestyle": ["Improve Bedroom Ventilation", "Daily Physical Exercise"],
      "Medication": "Orexin Receptor Antagonists",
    },
    {
      "Diagnosis": "Restless Legs Syndrome (RLS)",
      "Treatment": ["Dopamine Agonists", "Relaxation Therapy"],
      "Lifestyle": [
        "Limit Screen Time Before Sleep",
        "Regular Sunlight Exposure"
      ],
      "Medication": "Dopamine Agonists",
    },
    {
      "Diagnosis": "Narcolepsy",
      "Treatment": ["Scheduled Napping", "Medication Management"],
      "Lifestyle": ["Maintain a Balanced Diet", "Daily Physical Exercise"],
      "Medication": "Modafinil (Stimulant)",
    },
  ];

  @override
  void initState() {
    super.initState();
    fetchDoctorAndPatientInfo();
    dateController.text = _formatDate(DateTime.now());
  }

  // Format date as YYYY-MM-DD
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Fetch doctor and patient information from Firestore
  Future<void> fetchDoctorAndPatientInfo() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Fetch doctor info
      var doctorQuery = await firestore
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .get();

      if (doctorQuery.docs.isNotEmpty) {
        var doctorDoc = doctorQuery.docs.first;
        var doctorData = doctorDoc.data();
        if (mounted) {
          setState(() {
            doctorId = doctorDoc.id;
            doctorName = doctorData['username'] ?? "Unknown";
          });
        }
      }

      // Fetch patient info
      var patientQuery = await firestore
          .collection('users')
          .where('username', isEqualTo: widget.patientName)
          .get();

      if (patientQuery.docs.isNotEmpty) {
        var patientDoc = patientQuery.docs.first;
        var patientData = patientDoc.data();
        if (mounted) {
          setState(() {
            patientId = patientDoc.id;
            patientEmail = patientData['email'] ?? "Unknown";
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching doctor/patient info: $e');
    }
  }

  // Save recommendations to Firestore
  Future<void> saveRecommendations() async {
    if (dateController.text.isEmpty ||
        diagnosisController.text.isEmpty ||
        treatmentController.text.isEmpty ||
        lifestyleController.text.isEmpty ||
        medicationController.text.isEmpty ||
        additionalNotesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all the fields")),
      );
      return;
    }

    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference recommendations =
          firestore.collection('recommendations');

      // Generate new recommendation ID
      var querySnapshot = await recommendations.get();
      List<String> existingIds = querySnapshot.docs
          .map((doc) => doc['recommendationId'] as String)
          .toList();

      int maxId = 0;
      for (var id in existingIds) {
        var match = RegExp(r'r(\d+)').firstMatch(id);
        if (match != null) {
          int currentId = int.parse(match.group(1)!);
          maxId = max(maxId, currentId);
        }
      }

      String newRecommendationId = 'r${maxId + 1}';

      // Prepare recommendation data
      Map<String, dynamic> recommendationData = {
        'recommendationId': newRecommendationId,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'doctorEmail': widget.email,
        'patientName': widget.patientName,
        'patientId': patientId,
        'patientEmail': patientEmail,
        'recommendationDate': dateController.text,
        'Diagnosis': diagnosisController.text,
        'TreatmentPlan': treatmentController.text,
        'LifestyleChange': lifestyleController.text,
        'Medications': medicationController.text,
        'AdditionalNotes': additionalNotesController.text,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      await recommendations.doc(newRecommendationId).set(recommendationData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recommendations saved successfully!")),
        );

        // Clear form fields
        diagnosisController.clear();
        treatmentController.clear();
        lifestyleController.clear();
        medicationController.clear();
        additionalNotesController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error saving recommendations: ${e.toString()}")),
        );
      }
      debugPrint('Error saving recommendations: $e');
    }
  }

  // Show AI recommendations dialog
  void _showAIRecommendations() {
    final recommendation =
        _aiRecommendations[_random.nextInt(_aiRecommendations.length)];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("AI Recommendations"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAnimatedRecommendationItem(
                    "Diagnosis:", recommendation["Diagnosis"]),
                _buildAnimatedRecommendationItem(
                    "Treatment:", recommendation["Treatment"].join("\n• ")),
                _buildAnimatedRecommendationItem(
                    "Lifestyle:", recommendation["Lifestyle"].join("\n• ")),
                _buildAnimatedRecommendationItem(
                    "Medication:", recommendation["Medication"]),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
            TextButton(
              onPressed: () {
                diagnosisController.text = recommendation["Diagnosis"];
                treatmentController.text =
                    recommendation["Treatment"].join("\n");
                lifestyleController.text =
                    recommendation["Lifestyle"].join("\n");
                medicationController.text = recommendation["Medication"];
                Navigator.pop(context);
              },
              child: const Text("Use These"),
            ),
          ],
        );
      },
    );
  }

  // Build animated recommendation item
  Widget _buildAnimatedRecommendationItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                content,
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                speed: const Duration(milliseconds: 50),
              ),
            ],
            isRepeatingAnimation: false,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes and Recommendations',
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
          child: Form(
            child: ListView(
              children: [
                _buildReadOnlyField("Patient Name", widget.patientName),
                _buildReadOnlyField("Doctor Name", doctorName),
                _buildDateField(),
                const SizedBox(height: 16),
                _buildTextFormField(diagnosisController, "Diagnosis", 1),
                const SizedBox(height: 16),
                _buildTextFormField(treatmentController, "Treatment Plan", 2),
                const SizedBox(height: 16),
                _buildTextFormField(
                    lifestyleController, "Lifestyle Changes", 2),
                const SizedBox(height: 16),
                _buildTextFormField(medicationController, "Medication", 1),
                const SizedBox(height: 16),
                _buildTextFormField(
                    additionalNotesController, "Additional Notes", 2),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: saveRecommendations,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Save Recommendations"),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAIRecommendations,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.android, color: Colors.white),
        elevation: 5,
        splashColor: Colors.deepPurple,
      ),
    );
  }

  // Build text input field with custom styling
  Widget _buildTextFormField(
      TextEditingController controller, String labelText, int maxLines) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        fillColor: Colors.transparent.withOpacity(0.1),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepPurple),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        labelStyle: const TextStyle(color: Colors.white),
        hintStyle: const TextStyle(color: Colors.white),
      ),
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
    );
  }

  // Build read-only field
  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          fillColor: Colors.transparent.withOpacity(0.1),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepPurple),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          labelStyle: const TextStyle(color: Colors.white),
          hintStyle: const TextStyle(color: Colors.white),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  // Build date picker field
  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: dateController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: "Date",
          fillColor: Colors.transparent.withOpacity(0.1),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepPurple),
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (picked != null && picked != DateTime.now()) {
                dateController.text = _formatDate(picked);
              }
            },
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          labelStyle: const TextStyle(color: Colors.white),
          hintStyle: const TextStyle(color: Colors.white),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    dateController.dispose();
    diagnosisController.dispose();
    treatmentController.dispose();
    lifestyleController.dispose();
    medicationController.dispose();
    additionalNotesController.dispose();
    super.dispose();
  }
}