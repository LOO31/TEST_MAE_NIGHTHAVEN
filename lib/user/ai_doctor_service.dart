import 'package:flutter/material.dart';
import 'ai_chat_page.dart';

class AIDoctorService extends StatefulWidget {
  final String email;

  const AIDoctorService({Key? key, required this.email}) : super(key: key);

  @override
  _AIDoctorServiceState createState() => _AIDoctorServiceState();
}

class _AIDoctorServiceState extends State<AIDoctorService> {
  int _selectedIndex = 2; // AI Doctor Service is selected by default

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; // Prevent redundant clicks

    setState(() {
      _selectedIndex = index;
    });

    String route = '';
    switch (index) {
      case 0:
        route = '/sleepTracker';
        break;
      case 1:
        route = '/diary';
        break;
      case 2:
        return; // Already on AI Doctor Service
      case 3:
        route = '/report';
        break;
    }

    if (route.isNotEmpty) {
      Navigator.pushReplacementNamed(
        context,
        route,
        arguments: {'email': widget.email}, // Keep email during navigation
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purpleAccent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'AI & Doctor',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: Colors.white, //title color
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        width: double.infinity, // ✅ 让背景填满整个屏幕宽度
        height: double.infinity, // ✅ 让背景填满整个屏幕高度
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1C1C3C), Color(0xFF4A148C), Color(0xFF9B59B6)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  minimumSize: const Size(200, 50),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AIChatPage()),
                  );
                },
                child: const Text('AI Chat',
                    style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  minimumSize: const Size(200, 50),
                ),
                onPressed: () {
                  // Implement doctor consultation navigation
                },
                child:
                    const Text('Doctor', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF4A148C),
        selectedItemColor: Colors.black,
        unselectedItemColor: Color(0xFF9C27B0),
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bedtime), label: "Sleep"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Diary"),
          BottomNavigationBarItem(
              icon: Icon(Icons.medical_services), label: "AI"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Report"),
        ],
      ),
    );
  }
}
