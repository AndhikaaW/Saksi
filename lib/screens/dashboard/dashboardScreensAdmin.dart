import 'package:flutter/material.dart';
import 'package:saksi/screens/chatScreens.dart';
import 'package:saksi/auth/loginScreens.dart';
import 'package:saksi/components/dashboardAdmin.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DashboardScreensAdmin extends StatefulWidget {
  const DashboardScreensAdmin({super.key});

  @override
  State<DashboardScreensAdmin> createState() => _DashboardScreensAdminState();
}

class _DashboardScreensAdminState extends State<DashboardScreensAdmin> {
  String? email;
  int _currentIndex = 0;
  late List<Widget> body;

  @override
  void initState() {
    super.initState();
    body = [
      const DashboardAdmin(),
      const Chatscreens(),
      const Chatscreens(),
      // HomeScreens(),
    ];
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreens()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard '),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: body[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int newIndex){
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
              label: 'Profile Admin',
              icon: Icon(Icons.person)
          )
        ],
      ),
    );
  }
}
