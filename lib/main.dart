import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:saksi/screens/dashboard/dashboardScreensAdmin.dart';
import 'package:saksi/auth/loginScreens.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:saksi/screens/dashboard/dashboardScreensUser.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Ambil informasi login dari SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    int userStatus = prefs.getInt('userStatus') ?? 0;

    // Jalankan aplikasi dengan informasi login
    runApp(MyApp(isLoggedIn: isLoggedIn, userStatus: userStatus));
  } catch (e) {
    print('Error initializing app: $e');
  }
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final int userStatus;

  const MyApp({required this.isLoggedIn, required this.userStatus});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Color(0xFFFFFFFF),
      debugShowCheckedModeBanner: false,
      initialRoute: _getInitialRoute(),
      routes: {
        '/login': (context) => const LoginScreens(),
        '/dashboardUser': (context) => const DashboardScreensUser(),
        '/dashboardAdmin': (context) => const DashboardScreensAdmin(),
      },
    );
  }

  String _getInitialRoute() {
    if (!isLoggedIn) {
      return '/login';
    }
    if (userStatus == 1) {
      return '/dashboardAdmin';
    } else if (userStatus == 2) {
      return '/dashboardUser';
    } else {
      return '/login';
    }
  }
}
