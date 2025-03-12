import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bcrypt/bcrypt.dart'; // For password encryption

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Sign Up (with encrypted password)
  Future<String?> signUp(String username, String email, String password) async {
    try {
      //Register user with Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      String authUid = userCredential.user!.uid; // Firebase-generated UID

      //Hash the password
      String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

      //Get all existing UIDs from Firestore
      CollectionReference usersRef = _firestore.collection("users");
      QuerySnapshot userSnapshot = await usersRef.get();

      //Find the next available UID
      Set<int> existingIds = userSnapshot.docs
          .map((doc) =>
              int.tryParse(doc.id.substring(1)) ??
              0) // Extract number part of "uX"
          .toSet();

      int nextId = 1;
      while (existingIds.contains(nextId)) {
        nextId++; // Find the first missing number
      }

      String customUid = "u$nextId"; // Assign "uX" safely

      //Store in Firestore with custom UID
      await usersRef.doc(customUid).set({
        "uid": customUid, // Use custom UID
        "auth_uid": authUid, // Store Firebase Auth UID for reference
        "username": username,
        "email": email,
        "password": hashedPassword,
        "created_at": FieldValue.serverTimestamp(),
      });

      return null; // Success
    } catch (e) {
      print("Sign Up Error: $e");
      return _handleFirebaseAuthError(e);
    }
  }

  //Sign In (with password verification)
  Future<String?> signIn(String email, String password) async {
    try {
      // Get user data from Firestore
      QuerySnapshot query = await _firestore
          .collection("users")
          .where("email", isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return "No account found for this email.";
      }

      var userData = query.docs.first.data() as Map<String, dynamic>;
      String storedPassword = userData["password"];

      // Verify entered password with hashed password
      bool passwordMatches = BCrypt.checkpw(password, storedPassword);
      if (!passwordMatches) {
        return "Incorrect password. Try again.";
      }

      // Authenticate user in Firebase Auth
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Success
    } catch (e) {
      return _handleFirebaseAuthError(e);
    }
  }

  //Sign Out
  Future<String?> signOut() async {
    try {
      await _auth.signOut();
      return null; // Success
    } catch (e) {
      return "Error signing out: ${e.toString()}";
    }
  }

  //Get Current User
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  //Get User Data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    User? user = _auth.currentUser;
    if (user == null) return null;

    DocumentSnapshot doc =
        await _firestore.collection("users").doc(user.uid).get();
    return doc.data() as Map<String, dynamic>?;
  }

  // Firebase Auth Error Handling
  String _handleFirebaseAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case "email-already-in-use":
          return "The email is already in use. Try another.";
        case "weak-password":
          return "The password is too weak. Use at least 6 characters.";
        case "invalid-email":
          return "Invalid email format.";
        case "user-not-found":
          return "No account found for this email.";
        case "wrong-password":
          return "Incorrect password. Try again.";
        case "network-request-failed":
          return "Check your internet connection.";
        default:
          return e.message ?? "An unknown error occurred.";
      }
    }
    return "An error occurred. Please try again.";
  }
}
