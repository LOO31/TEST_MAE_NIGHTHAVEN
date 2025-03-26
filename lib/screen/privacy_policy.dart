import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  final String email;
  const PrivacyPolicyPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // Ensure the back button is visible
        title: Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.white),  // Set header text color to white
        ),
        backgroundColor: Colors.black,  // Set AppBar background color to black
        elevation: 0,  // Remove AppBar shadow
        iconTheme: IconThemeData(color: Colors.white),  // Set back arrow icon color to white
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF091E40), Color(0xFF66363A)],  // 渐变色背景
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              SizedBox(height: 16),
              Text(
                'Last updated: March 2025\n\n'
                'We take your privacy seriously. This Privacy Policy explains what data we collect and how we use, store, and protect it. By using our services, you agree to the collection and use of information in accordance with this policy.\n\n'
                '1. Information Collection and Use\n'
                'We collect personal information that you provide to us, such as your name, email address, and any other details you provide when using our services.\n\n'
                '2. Data Retention\n'
                'Your data will be stored securely for as long as necessary to fulfill the purposes outlined in this Privacy Policy.\n\n'
                '3. Data Sharing\n'
                'We do not share your personal information with third parties without your consent, except as required by law.\n\n'
                '4. Security\n'
                'We implement strict security measures to protect your personal information from unauthorized access or misuse.\n\n'
                '5. Changes to this Policy\n'
                'We may update this Privacy Policy from time to time. Any changes will be posted on this page with a new effective date.\n\n'
                'If you have any questions, feel free to contact us at nighthavenPrivacy@gmail.com.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.white,  // 文字颜色为白色
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
