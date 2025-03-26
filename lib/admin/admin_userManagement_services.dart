import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// **Add User**
  Future<void> addUser({
    required String username,
    required String email,
    required String password,
    required String role,
    String profilePic =
        "https://i.pinimg.com/736x/c0/74/9b/c0749b7cc401421662ae901ec8f9f660.jpg",
  }) async {
    try {
      // Get the next available user ID
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .orderBy('created_at', descending: true)
          .limit(1)
          .get();

      int nextUid = 1;
      if (snapshot.docs.isNotEmpty) {
        var lastDoc = snapshot.docs.first;
        String lastId = lastDoc.id; // e.g., "u3"
        nextUid = int.parse(lastId.replaceAll('u', '')) + 1;
      }

      String customUid = 'u$nextUid';

      // Save user to Firestore
      await _firestore.collection('users').doc(customUid).set({
        'username': username,
        'email': email,
        'password': password,
        'role': role,
        'profilePic': profilePic,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Error adding user: $e");
    }
  }

  /// **Edit User**
  Future<void> editUser({
    required String userId,
    required String username,
    required String profilePic,
  }) async {
    try {
      // Update the user details in Firestore
      await _firestore.collection('users').doc(userId).update({
        'username': username,
        'profilePic': profilePic,
      });
    } catch (e) {
      throw Exception("Error editing user: $e");
    }
  }

  /// **Delete User from Firestore**
  Future<void> deleteUser(String userId) async {
    try {
      // Delete the user document from Firestore
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception("Error deleting user: $e");
    }
  }
}
