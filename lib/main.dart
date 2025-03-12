import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mae_grp_assignment/screen/main_page.dart';
import 'package:mae_grp_assignment/screen/role_selection.dart';
import 'firebase_options.dart';
import 'screen/welcome_page.dart';
import 'screen/mobile_register.dart';
import 'screen/mobile_login.dart';
import 'admin/admin_dashboard.dart';
import 'admin/admin_userManagement.dart';

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
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(), // set as first page
        '/register': (context) => const MobileRegister(), // register page
        '/login': (context) => const MobileLogin(
              selectedRole: '',
            ),
        '/admin': (context) => const AdminDashboard(),
        '/adminUserManagement': (context) => const AdminUserManagement(), // 配置路由
      },
    );
  }
}
