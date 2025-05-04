import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:saksi_app/firebase_options.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Awesome Notifications
  await AwesomeNotifications().initialize(
    null, // null untuk menggunakan icon default
    [
      NotificationChannel(
        channelKey: 'complaint_channel',
        channelName: 'Pengaduan Notifications',
        channelDescription: 'Notifikasi untuk pengaduan',
        defaultColor: Colors.blue,
        ledColor: Colors.blue,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      ),
    ],
  );

  // Listener untuk notifikasi
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: (ReceivedAction receivedAction) async {
      if (receivedAction.payload != null &&
          receivedAction.payload!['complaintId'] != null) {
        // Navigasi ke halaman detail pengaduan
        Get.toNamed('/detail-complaint',
            arguments: receivedAction.payload!['complaintId']);
      }
    },
  );

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
