import 'package:flutter/material.dart';

class AppVersionPage extends StatefulWidget {
  final String email;
  const AppVersionPage({super.key, required this.email});

  @override
  _AppVersionPageState createState() => _AppVersionPageState();
}

class _AppVersionPageState extends State<AppVersionPage> {
  final String _appVersion = '1.2.1';  // 假设的版本号
  String _updateMessage = '';  // 用于显示更新信息

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // Ensure the back button is visible
        title: Text(
          'App Version',
          style: TextStyle(color: Colors.white),  // Set header text color to white
        ),
        backgroundColor: Colors.black,  // Set AppBar background color to black
        elevation: 0,  // Remove AppBar shadow
        iconTheme: IconThemeData(color: Colors.white),  // Set back arrow icon color to white
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF091E40), Color(0xFF66363A)],  // Gradient background
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(  // Ensure content is centered
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'App Version:',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,  // Set text color to white
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  _appVersion,  // Display the fake version number
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,  // Set text color to white
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Update message to "This is the latest version"
                    setState(() {
                      _updateMessage = 'This is the latest version. Please wait for the next update.';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,  // Button background color
                    foregroundColor: Colors.white,  // Button text color
                  ),
                  child: Text('Check for Updates'),
                ),
                // Display update message if not empty
                if (_updateMessage.isNotEmpty) 
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      _updateMessage,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,  // Set text color to white
                      ),
                      textAlign: TextAlign.center,  // Center the text
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
