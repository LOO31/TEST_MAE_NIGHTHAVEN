import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart'; // For showing toast messages (optional)
import 'admin_userManagement.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key, required String email});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int activeUsers = 0;
  int _selectedIndex = 0;

  // Current selected user
  AdminUser? selectedUser;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _getActiveUserCount();
    });
  }

  void _getActiveUserCount() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        activeUsers = 1;
      });
    }

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        activeUsers = user != null ? 1 : 0;
      });
    });
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<String> pageTitles = [
    "Dashboard",
    "Users",
    "Reports",
    "Notifications",
    "Settings"
  ];

  // Function to handle logout
  void _logout() async {
    final bool confirmLogout = await _showLogoutConfirmationDialog();
    if (confirmLogout) {
      // Perform sign out operation
      await FirebaseAuth.instance.signOut();

      // Navigate to the role selection page after successful logout
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/roleSelection',
        (Route<dynamic> route) => false, // 清空所有导航栈
      );
      // Optional: Show a toast message for successful logout
      Fluttertoast.showToast(
          msg: "Successfully logged out!", toastLength: Toast.LENGTH_SHORT);
    }
  }

  // Show confirmation dialog before logging out
  Future<bool> _showLogoutConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false, // Prevent dismissal by tapping outside
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Confirm Logout"),
              content: Text("Are you sure you want to log out?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(false), // User presses Cancel
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(true), // User presses Logout
                  child: Text("Logout"),
                ),
              ],
            );
          },
        ) ??
        false; // Ensure the dialog always returns a valid boolean
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardScreen(activeUsers: activeUsers),
      UserManagementScreen(
        onUserTapped: (user) {
          setState(() {
            selectedUser = user;
          });
        },
      ),
      ReportsScreen(),
      NotificationsScreen(),
      SettingsScreen(),
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF091E40), Color(0xFF66363A)], // 🌈 深蓝到暗红渐变
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            pageTitles[_selectedIndex],
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          leading: _selectedIndex == 0
              ? null // Dashboard 不需要返回按钮
              : IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
          ],
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children:
              pages, // Use IndexedStack to ensure pages are not rebuilt unnecessarily
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 0.5,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onNavItemTapped,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white54,
            backgroundColor: Colors.black.withAlpha(150),
            elevation: 5,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true, // 选中的 Label 显示
            showUnselectedLabels: false, // 未选中的 Label 隐藏
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard), label: "Dashboard"),
              BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.analytics), label: "Reports"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.notifications), label: "Notification"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings), label: "Settings"),
            ],
          ),
        ),
      ),
    );
  }
}

// 🚀 **Dashboard 页面**
class DashboardScreen extends StatelessWidget {
  final int activeUsers;
  const DashboardScreen({super.key, required this.activeUsers});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        children: [
          _buildDashboardCard(context, Icons.group, "Total Users", "1"),
          _buildDashboardCard(context, Icons.check_circle, "Active Users",
              activeUsers.toString()),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
      BuildContext context, IconData icon, String title, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(77),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 10),
              Text(title,
                  style:
                      GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
              const SizedBox(height: 5),
              Text(value,
                  style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

// 📌 其他页面占位符
class UserManagementScreen extends StatefulWidget {
  final Function(AdminUser) onUserTapped;

  const UserManagementScreen({super.key, required this.onUserTapped});

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<AdminUser> users = []; // List of all users
  List<AdminUser> filteredUsers = []; // Filtered list of users

  @override
  void initState() {
    super.initState();
    // Initialize the list of users (mock data or fetch from a database)
    users = [
      AdminUser(
          name: 'John Doe',
          email: 'john@example.com',
          password: '1234',
          phoneNumber: '1234567890',
          avatarUrl:
              'https://gw.alicdn.com/imgextra/i2/1913062162/O1CN015OCjUY1RqFBeD5q7b_!!1913062162.jpg_300x300Q75.jpg_.webp',
          isDoctor: false),
      AdminUser(
          name: 'Dr. Jane Smith',
          email: 'jane@example.com',
          password: 'abcd',
          phoneNumber: '0987654321',
          avatarUrl:
              'https://q0.itc.cn/q_70/images03/20240807/5a7118f6a75548c4970e3932b41a31cc.jpeg',
          isDoctor: true),
      AdminUser(
          name: 'Xinyin',
          email: 'jane@example.com',
          password: 'abcd',
          phoneNumber: '0987654321',
          avatarUrl: 'https://img.itouxiang.com/m12/b0/21/3608e94ec245.jpg',
          isDoctor: true),
      AdminUser(
          name: 'Xinyin',
          email: 'jane@example.com',
          password: 'abcd',
          phoneNumber: '0987654321',
          avatarUrl:
              'https://q0.itc.cn/q_70/images03/20240807/5a7118f6a75548c4970e3932b41a31cc.jpeg',
          isDoctor: true),
      // Add more users here
    ];
    filteredUsers = List.from(users); // Start with all users
  }

  void _filterUsers() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredUsers = users.where((user) {
        return user.name.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query) ||
            user.phoneNumber.contains(query);
      }).toList();
    });
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => _filterUsers(),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white10,
        hintText: 'Search',
        hintStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(Icons.search, color: Colors.white70),
      ),
    );
  }

  Widget _buildUserCard(AdminUser user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.4),
            Colors.white.withOpacity(0.4)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15.0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user.avatarUrl),
              radius: 22.0,
            ),
            title: Text(
              user.name,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              '${user.email}\n${user.phoneNumber}',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEditButton(),
                const SizedBox(width: 8),
                _buildDeleteButton(),
              ],
            ),
            onTap: () {
              widget.onUserTapped(user); // Pass the selected user back
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEditButton() {
    return InkWell(
      onTap: () {
        // Edit user logic
      },
      child: const Icon(Icons.edit, color: Colors.white),
    );
  }

  Widget _buildDeleteButton() {
    return InkWell(
      onTap: () {
        // Delete user logic
      },
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(0, 140, 77, 77),
      appBar: AppBar(
        title: null, // Set title to null to remove it
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 0),
            _buildSearchField(),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return _buildUserCard(user);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add user logic
        },
        child: Icon(Icons.add),
        tooltip: 'Add User',
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
    );
  }
}

class ReportsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const PlaceholderWidget("Reports");
  }
}

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const PlaceholderWidget("Notifications");
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const PlaceholderWidget("Settings");
  }
}

// 通用占位 Widget
class PlaceholderWidget extends StatelessWidget {
  final String title;
  const PlaceholderWidget(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title,
          style: GoogleFonts.poppins(fontSize: 24, color: Colors.white)),
    );
  }
}
