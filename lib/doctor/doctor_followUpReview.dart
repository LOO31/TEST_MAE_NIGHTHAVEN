import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'doctor_dashboard.dart';

class ReviewFollowUpPage extends StatelessWidget {
  final String email;
  const ReviewFollowUpPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Review Follow-Up Progress',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorDashboard(email: email),
                ),
              );
            },
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white, // Selected tab text color
            unselectedLabelColor: Colors.white70, // Unselected tab text color
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Ongoing'),
              Tab(text: 'Completed'),
            ],
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
          child: TabBarView(
            children: [
              FollowUpList(email: email, status: 'Pending'),
              FollowUpList(email: email, status: 'In Progress'),
              FollowUpList(email: email, status: 'Completed'),
            ],
          ),
        ),
      ),
    );
  }
}

class FollowUpList extends StatelessWidget {
  final String email;
  final String status;
  const FollowUpList({super.key, required this.email, required this.status});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final users = snapshot.data!.docs;
        if (users.isEmpty) {
          return const Center(
            child: Text(
              'No users found.',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final doctorId = users.first.id;
        print('Doctor ID: $doctorId');

        List<String> statusFilters = status == 'In Progress'
            ? ['In Progress', 'Improving', 'No Change', 'Critical']
            : [status];

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('follow_ups')
              .where('doctorId', isEqualTo: doctorId)
              .where('progress', whereIn: statusFilters)
              .snapshots(),
          builder: (context, followUpSnapshot) {
            if (followUpSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (followUpSnapshot.hasError) {
              return Center(child: Text('Error: ${followUpSnapshot.error}'));
            }

            List<QueryDocumentSnapshot> followUps = followUpSnapshot.data!.docs;

            followUps.sort((a, b) {
              String dateA = a['followUpDate'];
              String dateB = b['followUpDate'];
              String timeA = a['followUpTime'];
              String timeB = b['followUpTime'];

              int dateCompare = dateB.compareTo(dateA);
              if (dateCompare != 0) return dateCompare;
              return timeB.compareTo(timeA);
            });
            if (followUps.isEmpty) {
              return Center(
                child: Text(
                  'No $status Records Found.',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.all(12),
              children: followUps.map((followUp) {
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(followUp['patientUid'])
                      .get(),
                  builder: (context, userSnapshot) {
                    String patientName = 'Unknown Patient';
                    if (userSnapshot.hasData && userSnapshot.data!.exists) {
                      patientName = userSnapshot.data!.get('username') ??
                          'Unknown Patient';
                    }

                    return FollowUpProgressCard(
                      followUp: followUp,
                      patientName: patientName,
                      followUpId: followUp.id,
                    );
                  },
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}

class FollowUpProgressCard extends StatelessWidget {
  final QueryDocumentSnapshot followUp;
  final String patientName;
  final String followUpId;

  const FollowUpProgressCard({
    super.key,
    required this.followUp,
    required this.patientName,
    required this.followUpId,
  });

  @override
  Widget build(BuildContext context) {
    final data = followUp.data() as Map<String, dynamic>?;
    final String progress = data?['progress'] ?? 'Unknown';
    final String notes = data?['notes'] ?? 'No notes available';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              patientName,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              "Doctor: ${data?['doctorName'] ?? 'Unknown Doctor'}",
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const Divider(thickness: 1.5, height: 16),
            _buildInfoRow("Progress", progress),
            _buildInfoRow("Follow-Up Date", data?['followUpDate']),
            _buildInfoRow("Follow-Up Time", data?['followUpTime']),
            _buildInfoRow("Follow-Up Type", data?['followUpType']),
            const Divider(thickness: 1, height: 16),
            Text(
              "Notes:",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              notes,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            if (progress != 'Completed')
              UpdateButton(followUpId: followUpId, currentStatus: progress),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            value ?? "N/A",
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class UpdateButton extends StatelessWidget {
  final String followUpId;
  final String currentStatus;
  const UpdateButton({super.key, required this.followUpId, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => _updateFollowUpStatus(context, followUpId, currentStatus),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black, // Button background color
          foregroundColor: Colors.white, // Text color
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Update Progress',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _updateFollowUpStatus(BuildContext context, String followUpId, String currentStatus) {
    Map<String, List<String>> statusTransitions = {
      'Pending': ['In Progress'],
      'In Progress': ['No Change', 'Improving', 'Critical', 'Completed'],
      'No Change': ['In Progress', 'Improving', 'Critical', 'Completed'],
      'Improving': ['In Progress', 'No Change', 'Critical', 'Completed'],
      'Critical': ['In Progress', 'No Change', 'Improving', 'Completed'],
    };

    List<String> statusOptions = statusTransitions[currentStatus] ?? [];

    if (statusOptions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No updates available for this status')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Follow-Up Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: statusOptions.map((status) {
              return ListTile(
                title: Text(status),
                onTap: () async {
                  await FirebaseFirestore.instance
                      .collection('follow_ups')
                      .doc(followUpId)
                      .update({'progress': status});

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Status updated successfully')),
                  );
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
