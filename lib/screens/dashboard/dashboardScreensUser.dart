import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:saksi/auth/loginExample.dart';
import 'package:saksi/components/dashboardUser.dart';
import 'package:saksi/screens/chatScreens.dart';
import 'package:saksi/auth/loginScreens.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreensUser extends StatefulWidget {
  const DashboardScreensUser({super.key});

  @override
  State<DashboardScreensUser> createState() => _DashboardScreensUserState();
}

class _DashboardScreensUserState extends State<DashboardScreensUser> {
  String? userName;
  int _currentIndex = 0;
  late List<Widget> body;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseServices _firebaseServices = FirebaseServices();

  @override
  void initState() {
    super.initState();
    body = [
      const DashboardUser(),
      const Chatscreens(),
      const Chatscreens(),
    ];
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        userName = user.displayName ?? user.email?.split('@')[0] ?? 'User';
      });
    }
  }

  Future<void> _logout() async {
    try {
      // Check if user is signed in with Google
      User? user = _auth.currentUser;
      if (user != null) {
        if (user.providerData.any((provider) => provider.providerId == 'google.com')) {
          // If signed in with Google, use Google sign out
          await _firebaseServices.signOut();
        } else {
          // Regular sign out
          await _auth.signOut();
        }
      }

      // Clear SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear all stored preferences

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreens()),
              (route) => false, // This removes all previous routes
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during logout: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard'),
            if (userName != null)
              Text(
                'Welcome, $userName',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: body[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
        items: const [
          BottomNavigationBarItem(
              label: 'Utama',
              icon: Icon(Icons.home)
          ),
          BottomNavigationBarItem(
              label: 'Chat',
              icon: Icon(Icons.history)
          ),
          BottomNavigationBarItem(
              label: 'Profile User',
              icon: Icon(Icons.person)
          )
        ],
      ),
    );
  }
}