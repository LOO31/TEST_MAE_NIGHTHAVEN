import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewNotesAndRecsPage extends StatelessWidget {
  final String email;

  const ReviewNotesAndRecsPage({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes and Recommendations', style: TextStyle(color: Colors.white)),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('recommendations')
                .where('doctorEmail', isEqualTo: email)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text("Error fetching data"));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No recommendations found"));
              }

              final recommendations = snapshot.data!.docs;

              return ListView.builder(
                itemCount: recommendations.length,
                itemBuilder: (context, index) {
                  final recommendation = recommendations[index].data() as Map<String, dynamic>;

                  final diagnosis = recommendation['Diagnosis'] ?? 'No Diagnosis Provided';
                  final lifestyleChange = recommendation['LifestyleChange'] ?? 'No Lifestyle Change Provided';
                  final medications = recommendation['Medications'] ?? 'No Medications Provided';
                  final treatmentPlan = recommendation['TreatmentPlan'] ?? 'No Treatment Plan Provided';
                  final furtherFollowUps = recommendation['FurtherFollowUps'] ?? 'No Follow-ups Provided';
                  final patientName = recommendation['patientName'] ?? 'Unknown Patient';
                  final recommendationDate = recommendation['recommendationDate'] ?? 'No Date Provided';

                  return _buildRecommendationCard(
                    patientName, recommendationDate,
                    diagnosis, lifestyleChange, medications, treatmentPlan, furtherFollowUps
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(
    String patientName, String recommendationDate, 
    String diagnosis, String lifestyleChange, 
    String medications, String treatmentPlan, 
    String furtherFollowUps
  ) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient & Date info (Top part of the card)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$patientName',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Date: $recommendationDate',
                  style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Color.fromARGB(255, 74, 74, 74)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Divider between sections for clarity
            const Divider(thickness: 1, color: Colors.grey, height: 5),

            // Recommendation sections with reduced spacing
            _buildRecommendationItem("Diagnosis", diagnosis),
            _buildRecommendationItem("Lifestyle Change", lifestyleChange),
            _buildRecommendationItem("Medications", medications),
            _buildRecommendationItem("Treatment Plan", treatmentPlan),
            _buildRecommendationItem("Further Follow Ups", furtherFollowUps),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6), // Reduced vertical spacing
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
