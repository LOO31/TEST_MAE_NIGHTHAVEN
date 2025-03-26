import 'package:flutter/material.dart';

class LogoutService {
  static void logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Logout"),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                print("Logged out Successfully");
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }
}
