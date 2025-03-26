import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screen/welcome_page.dart';
import 'screen/role_selection.dart';
import 'screen/mobile_register.dart';
import 'screen/mobile_login.dart';
import 'screen/main_page.dart';
import 'admin/admin_dashboard.dart';

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
      initialRoute: '/', // 默认进入 WelcomePage
      onGenerateRoute: (settings) {
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
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (context) => AdminDashboard(email: args['email']),
            );
          default:
            return MaterialPageRoute(builder: (context) => const WelcomePage());
        }
      },
    );
  }
}
