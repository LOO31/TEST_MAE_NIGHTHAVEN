import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mae_grp_assignment/screen/main_page.dart';
import 'package:mae_grp_assignment/screen/role_selection.dart';
import 'firebase_options.dart';
import 'screen/welcome_page.dart';
import 'screen/mobile_register.dart'; // 确保这个文件存在
import 'screen/mobile_login.dart'; // 确保这个文件存在
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
      initialRoute: '/', // 设置初始路由
      routes: {
        '/': (context) => const WelcomePage(), // 默认首页]
        '/main': (context) => const MainPage(), // 注册页面
        '/roleSelection': (context) => const RoleSelection(), // 注册页面
        '/register': (context) => const MobileRegister(), // 注册页面
        '/login': (context) => const MobileLogin(
              selectedRole: '',
            ), // 登录页面
        '/admin': (context) => const AdminDashboard(),
        '/adminUserManagement': (context) => const AdminUserManagement(), // 配置路由
      },
    );
  }
}
