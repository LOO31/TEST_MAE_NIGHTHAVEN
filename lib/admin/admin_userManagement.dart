import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 示例用户数据
class AdminUser {
  final String name;
  final String email;
  final String password;
  final String phoneNumber;
  final String avatarUrl;
  final bool isDoctor;

  AdminUser({
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.avatarUrl,
    required this.isDoctor,
  });
}

class AdminUserManagement extends StatefulWidget {
  const AdminUserManagement({super.key});

  @override
  _AdminUserManagementState createState() => _AdminUserManagementState();
}

class _AdminUserManagementState extends State<AdminUserManagement> {
  TextEditingController _searchController = TextEditingController();
  List<AdminUser> allUsers = [
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
        avatarUrl:
            'https://img.itouxiang.com/m12/b0/21/3608e94ec245.jpg',
        isDoctor: true),
      AdminUser(
        name: 'Xinyin',
        email: 'jane@example.com',
        password: 'abcd',
        phoneNumber: '0987654321',
        avatarUrl:
            'https://q0.itc.cn/q_70/images03/20240807/5a7118f6a75548c4970e3932b41a31cc.jpeg',
        isDoctor: true),
  ];

  List<AdminUser> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    filteredUsers = allUsers;
  }

  void _filterUsers() {
    setState(() {
      filteredUsers = allUsers.where((user) {
        return user.name
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            user.email
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('User Management',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF091E40),
              Color(0xFF66363A)
            ], // Apply the gradient similar to MobileLogin
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              _buildSearchField(),
              const SizedBox(height: 15),
              // 用户列表
              Expanded(
                child: ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return _buildUserCard(user, index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 添加用户逻辑
        },
        child: Icon(Icons.add),
        tooltip: 'Add User',
        backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Bright green for add action
      ),
    );
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

  Widget _buildUserCard(AdminUser user, int index) {
    return Container(
      margin: const EdgeInsets.only(
          bottom: 8.0), // Reduce the spacing between cards
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(12.0), // Slightly smaller border radius
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.4),
            Colors.white.withOpacity(0.4)
          ], // Subtle gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.2), // Softer shadow for a floating effect
            blurRadius: 15.0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Matching border radius
        ),
        color: Colors
            .transparent, // Card background is transparent to show gradient
        child: Padding(
          padding: const EdgeInsets.all(2.0), // Reduced padding inside the card
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user.avatarUrl),
              radius: 22.0, // Slightly smaller avatar
            ),
            title: Container(
              width:
                  MediaQuery.of(context).size.width * 0.4, // Limit title width
              child: Text(
                user.name,
                overflow: TextOverflow.ellipsis, // Prevent text overflow
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // Darker text for better readability
                ),
              ),
            ),
            subtitle: Text(
              '${user.email}\n${user.phoneNumber}',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min, // Minimize space for icons
              children: [
                _buildEditButton(),
                const SizedBox(width: 8),
                _buildDeleteButton(),
              ],
            ),
            onTap: () {
              // 点击用户进行更多操作，例如查看详情
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
    child: const Icon(Icons.edit, color: Colors.white), // 纯白色Icon
  );
}

Widget _buildDeleteButton() {
  return InkWell(
    onTap: () {
      // Delete user logic
    },
    child: const Icon(Icons.delete, color: Colors.white), // 纯白色Icon
  );
}

}
