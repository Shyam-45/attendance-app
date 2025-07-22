import 'package:flutter/material.dart';
import 'package:attendance_app/screens/upload_screen.dart';
import 'package:attendance_app/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    UploadScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1B23),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF2D2E3F),
        selectedItemColor: const Color(0xFF4F46E5),
        unselectedItemColor: Colors.white.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.cloud_upload_outlined, size: 24),
            ),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.person_outline, size: 24),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
