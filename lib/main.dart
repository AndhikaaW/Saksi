import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:saksi_app/firebase_options.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase berhasil diinisialisasi');
  } catch (e) {
    print('Error saat inisialisasi Firebase: $e');

  }
  await GetStorage.init();

  final box = GetStorage();
  final isLoggedIn = box.read('isLoggedIn') ?? false;
  final userStatus = box.read('userStatus');

  String initialRoute = Routes.LOGIN;

  if (isLoggedIn) {
    if (userStatus == 0) {
      initialRoute = Routes.DASHBOARD_SUPERADMIN;
    } else if (userStatus == 1) {
      initialRoute = Routes.DASHBOARD_ADMIN;
    } else if (userStatus == 2) {
      initialRoute = Routes.DASHBOARD_USER;
    }
  }

  runApp(
    GetMaterialApp(
      title: "Saksi",
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        fontFamily: 'Poppins',
      ),
    ),
  );
}
