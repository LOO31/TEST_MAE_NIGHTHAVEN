import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import '../screen/app_versions.dart';
import '../screen/privacy_policy.dart';
import '../screen/terms_and_conditions.dart';
import '/user/edit_personal_info.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String username = "Fetching...";
  String email = "Fetching...";
  double _volume = 0.75; // 默认音量 75%

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _getVolume(); // 获取当前音量
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        username = "Fetching...";
        email = "Fetching...";
      });

      QuerySnapshot query = await _firestore
          .collection("users")
          .where("auth_uid", isEqualTo: user.uid)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        var userData = query.docs.first.data() as Map<String, dynamic>;
        setState(() {
          username = userData["username"] ?? "No username";
          email = userData["email"] ?? "No email";
        });
      } else {
        setState(() {
          username = "Not Found";
          email = "Not Found";
        });
      }
    }
  }

  Future<void> _getVolume() async {
    double? volume = await FlutterVolumeController.getVolume();
    setState(() {
      _volume = volume ?? 0.75; // If null, fallback to default 0.75
    });
  }

  void _setVolume(double value) {
    FlutterVolumeController.setVolume(value);
    _getVolume(); // Ensure UI updates properly
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF091E40), Color(0xFF66363A)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Personal Information Card
            Card(
              color: Colors.white12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Personal Information",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.white70),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditPersonalInfo(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    Divider(color: Colors.white30),
                    SizedBox(height: 10),
                    ListTile(
                      leading: Icon(Icons.person, color: Colors.white70),
                      title: Text(
                        username,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      subtitle: username == "Fetching..."
                          ? LinearProgressIndicator(
                              color: Colors.blueAccent,
                              backgroundColor: Colors.white24,
                            )
                          : null,
                    ),
                    ListTile(
                      leading: Icon(Icons.email, color: Colors.white70),
                      title: Text(
                        email,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      subtitle: email == "Fetching..."
                          ? LinearProgressIndicator(
                              color: Colors.blueAccent,
                              backgroundColor: Colors.white24,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Settings Section
            _buildSettingItem("Sound", "${(_volume * 100).toInt()}%",
                onTap: _showVolumeDialog),
            _buildSettingItem("Privacy Policy", "More", onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PrivacyPolicyPage(email: email)));
            }),
            _buildSettingItem("Terms & Conditions", "More", onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          TermsAndConditionsPage(email: email)));
            }),
            _buildSettingItem("App Version", "1.0.0", onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AppVersionPage(email: email)));
            }),
          ],
        ),
      ),
    );
  }

  /// 生成设置项
  Widget _buildSettingItem(String title, String subtitle,
      {VoidCallback? onTap}) {
    return ListTile(
      title: Text(title, style: TextStyle(color: Colors.white)),
      trailing: title == "Sound"
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(subtitle, style: TextStyle(color: Colors.white70)),
                IconButton(
                  icon: Icon(Icons.volume_up, color: Colors.white70),
                  onPressed: onTap,
                ),
              ],
            )
          : Text(subtitle, style: TextStyle(color: Colors.white70)),
      onTap: onTap,
    );
  }

  /// 显示音量调整对话框
  void _showVolumeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Adjust Volume"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: _volume,
                min: 0.0,
                max: 1.0,
                onChanged: (value) => _setVolume(value),
              ),
              Text("${(_volume * 100).toInt()}%"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
