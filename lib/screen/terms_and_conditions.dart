import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  final String email;
  const TermsAndConditionsPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // Ensure the back button is visible
        title: Text(
          'Terms and Conditions',
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
                'By accessing or using our services, you agree to be bound by the following terms and conditions. If you do not agree to these terms, you may not use our services.\n\n'
                '1. Use of Services\n'
                'You agree to use our services only for lawful purposes and in accordance with these terms and conditions.\n\n'
                '2. User Responsibilities\n'
                'You are responsible for maintaining the confidentiality of your account and password, and for all activities that occur under your account.\n\n'
                '3. Prohibited Activities\n'
                'You may not use our services for any unlawful, harmful, or fraudulent activities.\n\n'
                '4. Termination of Service\n'
                'We reserve the right to suspend or terminate your access to our services if you violate these terms.\n\n'
                '5. Limitation of Liability\n'
                'Our liability is limited to the maximum extent permitted by law. We are not responsible for any indirect, incidental, or consequential damages.\n\n'
                '6. Changes to Terms\n'
                'We may modify these terms from time to time. All updates will be posted on this page with a new effective date.\n\n'
                'If you have any questions, please contact us at nighthavenSupport@gmail.com.',
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
