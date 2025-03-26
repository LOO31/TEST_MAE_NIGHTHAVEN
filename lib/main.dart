import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import screens
import 'screen/welcome_page.dart';
import 'screen/role_selection.dart';
import 'screen/mobile_register.dart';
import 'screen/mobile_login.dart';
import 'screen/main_page.dart';
import 'admin/admin_dashboard.dart';
import 'admin/admin_userManagement.dart';

// Import user-related screens
import '/user/sleep_tracker.dart';
import '/user/diary.dart';
import '/user/ai_doctor_service.dart';
import '/user/sleep_report.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/', // WelcomePage
      onGenerateRoute: (settings) {
        final args = settings.arguments as Map<String, dynamic>? ?? {};

        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => const WelcomePage());
          case '/roleSelection':
            return MaterialPageRoute(
                builder: (context) => const RoleSelection());
          case '/register':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (context) =>
                  MobileRegister(selectedRole: args['selectedRole']),
            );
          case '/login':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (context) =>
                  MobileLogin(selectedRole: args['selectedRole']),
            );
          case '/admin':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (context) => AdminDashboard(email: args['email']),
            );
          case '/user':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (context) => MainPage(email: args['email']),
            );
          case '/adminUserManagement':
            return MaterialPageRoute(
                builder: (context) => const AdminUserManagement());

          // routes for user features
          case '/sleepTracker':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (context) => SleepTracker(email: args['email']),
            );
          case '/diary':
            return MaterialPageRoute(
              builder: (context) =>
                  DiaryEmotionScreen(email: args['email'] ?? ''),
            );
          case '/aiDoctor':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (context) => AIDoctorService(email: args['email']),
            );
          case '/report':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            final userId = args['userId'] ?? '';
            return MaterialPageRoute(
                builder: (context) => SleepReport(userId: userId));

          default:
            return MaterialPageRoute(builder: (context) => const WelcomePage());
        }
      },
    );
  }
}
