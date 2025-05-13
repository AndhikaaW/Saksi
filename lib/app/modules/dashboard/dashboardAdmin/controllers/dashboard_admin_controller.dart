import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:saksi_app/app/data/models/Complaint.dart';
import 'package:saksi_app/app/modules/chat/views/chat_list_view.dart';
import 'package:saksi_app/app/modules/chat/views/chat_list_view_admin.dart';
import 'package:saksi_app/app/modules/dashboard/dashboardAdmin/views/home_admin.dart';
import 'package:saksi_app/app/modules/profile/views/profile_view.dart';

class DashboardAdminController extends GetxController {
  final box = GetStorage();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var username = ''.obs;
  final currentIndex = 0.obs; // Gunakan .obs untuk reaktivitas
  late List<Widget> tabPages;
  final RxInt users = 0.obs;

  final RxInt complaints = 0.obs;
  final RxInt pendingComplaints = 0.obs;
  final RxInt processedComplaints = 0.obs;
  final RxInt completedComplaints = 0.obs;
  late StreamSubscription<QuerySnapshot> _complaintSubscription;

  @override
  void onInit() {
    super.onInit();

    tabPages = [
      // const DashboardUserView(),   // Tab Utama
      const HomeTabViewAdmin(), // Tab Chat
      const ChatListViewAdmin(), // Tab Chat
      const ProfileView(), // Tab Chat
    ];

    loadUsername();
    _listenToComplaintChanges();
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }

  // Method untuk logout
  void logout() async {
    // Implementasi logout
    // Contoh:
    // await FirebaseAuth.instance.signOut();

    // Clear local storage
    final box = GetStorage();
    await box.erase();

    // Navigasi ke halaman login
    Get.offAllNamed('/login');
  }

  void loadUsername() {
    username.value = box.read('email') ?? 'Guest';
  }

  String get currentTitle {
    switch (currentIndex.value) {
      case 0:
        return 'Dashboard Admin';
      case 1:
        return 'Chat';
      case 2:
        return 'Profil';
      default:
        return '';
    }
  }


  void _listenToComplaintChanges() {
    try {
      // Buat query untuk memantau perubahan pada pengaduan dengan status = 0 (baru)
      final complaintQuery = _firestore
          .collection('complaints')
          .where('statusPengaduan', isEqualTo: 0);

      // Mulai mendengarkan perubahan
      _complaintSubscription = complaintQuery.snapshots().listen((snapshot) {
        // Update nilai complaints setiap kali ada perubahan
        complaints.value = snapshot.size;

        // Cek apakah ada pengaduan baru yang masuk
        if (snapshot.docChanges.isNotEmpty) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final complaint = Complaint.fromJson(change.doc.data()!);
              // Tampilkan notifikasi untuk pengaduan baru
              AwesomeNotifications().createNotification(
                content: NotificationContent(
                  id: 10,
                  channelKey: 'complaint_channel',
                  title: 'Pengaduan Baru',
                  body: 'Ada pengaduan baru dari ${complaint.namaPelapor}',
                  notificationLayout: NotificationLayout.Default,
                  payload: {'complaintId': complaint.complaintId},
                ),
              );
            }
          }
        }
      }, onError: (error) {
        Get.snackbar(
          'Error',
          'Gagal memantau data pengaduan: $error',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memulai pemantauan pengaduan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
