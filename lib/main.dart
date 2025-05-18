import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:saksi_app/firebase_options.dart';

import 'app/routes/app_pages.dart';

// Fungsi untuk menangani notifikasi di background
@pragma('vm:entry-point')
Future<void> handleBackgroundNotification(ReceivedAction receivedAction) async {
  // Kode untuk menangani notifikasi di background
  if (receivedAction.payload != null &&
      receivedAction.payload!['complaintId'] != null) {
    // Simpan data untuk diproses saat aplikasi dibuka
    // final box = await GetStorage.init();
    GetStorage().write('pendingNotification', receivedAction.payload!['complaintId']);
  }
}

// Mendefinisikan metode global statis untuk menerima aksi notifikasi di background
@pragma('vm:entry-point')
Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  if (receivedAction.payload != null) {
    if (receivedAction.payload!['complaintId'] != null) {
      // Handle notifikasi pengaduan
      await GetStorage.init();
      GetStorage().write(
          'pendingNotification', receivedAction.payload!['complaintId']);
    } else if (receivedAction.payload!['roomId'] != null) {
      // Handle notifikasi chat di background
      // Simpan data untuk diproses saat aplikasi dibuka
      await GetStorage.init();
      GetStorage().write('pendingChatNotification', {
        'roomId': receivedAction.payload!['roomId'],
        'adminName': receivedAction.payload!['adminName'],
        'action': receivedAction.buttonKeyPressed
      });
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Awesome Notifications dengan perizinan
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
        enableVibration: true,
        enableLights: true,
        playSound: true,
        locked: true,
      ),
      NotificationChannel(
        channelKey: 'chat_channel',
        channelName: 'Chat Notifications',
        channelDescription: 'Notifikasi untuk pesan chat',
        defaultColor: Colors.green,
        ledColor: Colors.green,
        importance: NotificationImportance.High,
        channelShowBadge: true,
        enableVibration: true,
        enableLights: true,
        playSound: true,
        locked: false,
      ),
    ],
    debug: true,
  );

  // Minta izin notifikasi
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  // Daftarkan handler untuk notifikasi
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: onActionReceivedMethod,
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

  // Periksa apakah ada notifikasi yang tertunda
  final pendingNotification = box.read('pendingNotification');
  if (pendingNotification != null) {
    // Hapus data notifikasi tertunda
    box.remove('pendingNotification');
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
      // onInit: () {
      //   // Jika ada notifikasi tertunda, navigasikan ke halaman detail
      //   if (pendingNotification != null) {
      //     Future.delayed(Duration(seconds: 1), () {
      //       Get.toNamed('/detail-complaint', arguments: pendingNotification);
      //     });
      //   }
      // },
    ),
  );
}
