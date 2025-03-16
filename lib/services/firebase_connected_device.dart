import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseConnectedDevice {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetches the custom UID from Firestore based on the Firebase Auth UID.
  Future<String?> _getCustomUid() async {
    User? user = _auth.currentUser;
    if (user == null) return null;

    try {
      QuerySnapshot query = await _firestore
          .collection("users")
          .where("auth_uid", isEqualTo: user.uid)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.id; // Custom UID (e.g., "U1", "U2")
      } else {
        print("Custom UID not found for user.");
      }
    } catch (e) {
      print("Error fetching custom UID: $e");
    }
    return null;
  }

  /// Updates the connected device for the authenticated user.
  Future<void> updateConnectedDevice(String? deviceName) async {
    String? customUid = await _getCustomUid();
    if (customUid == null) return;

    try {
      DocumentReference deviceDoc =
          _firestore.collection("connected_devices").doc(customUid);

      await deviceDoc.set({
        "uid": customUid,
        "connectedDevice": deviceName ?? "No Device",
        "timestamp": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print("Device updated successfully for $customUid!");
    } catch (e) {
      print("Error updating connected device: $e");
    }
  }

  /// Retrieves the connected device associated with the authenticated user.
  Future<String> getConnectedDevice() async {
    String? customUid = await _getCustomUid();
    if (customUid == null) return "No Device";

    try {
      DocumentSnapshot doc =
          await _firestore.collection("connected_devices").doc(customUid).get();

      if (doc.exists && doc.data() != null) {
        return doc["connectedDevice"] ?? "No Device";
      }
    } catch (e) {
      print("Error fetching connected device: $e");
    }
    return "No Device";
  }
}
