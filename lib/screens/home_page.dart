import 'package:flutter/material.dart';
import 'grades_page.dart';
import 'payments_page.dart';
import 'login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');

    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      GradesPage(user: widget.user),
      PaymentsPage(user: widget.user),
    ];

    final titles = ['Grades', 'Payments'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF05056A),
        title: Text(
          titles[_selectedIndex],
          style: const TextStyle(color: Colors.white), // Title color
        ),
        iconTheme: const IconThemeData(color: Colors.white), // Icon color
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),

      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF05056A),
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Grades'),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments),
            label: 'Payments',
          ),
        ],
      ),
    );
  }
}
