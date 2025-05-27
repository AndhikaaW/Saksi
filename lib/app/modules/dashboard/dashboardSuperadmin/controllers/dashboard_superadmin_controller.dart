import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:saksi_app/app/data/models/Complaint.dart';
import 'package:saksi_app/app/modules/chat/views/chat_list_view_admin.dart';
import 'package:saksi_app/app/modules/dashboard/dashboardSuperadmin/views/home_superadmin.dart';
import 'package:saksi_app/app/modules/profile/views/profile_view.dart';

class DashboardSuperadminController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final box = GetStorage();
  var username = ''.obs;
  final currentIndex = 0.obs; 
  late List<Widget> tabPages;
  
  final RxInt admins = 0.obs;
  final RxInt users = 0.obs;
  final RxBool isLoading = false.obs;

  StreamSubscription<QuerySnapshot>? _complaintSubscription;
  // Tambahkan RxInt untuk setiap status pengaduan
  final RxInt pendingComplaints = 0.obs; // statusPengaduan = 0 (Menunggu Persetujuan)
  final RxInt processedComplaints = 0.obs; // statusPengaduan = 1 (Diproses/Aktif)
  final RxInt completedComplaints = 0.obs; // statusPengaduan = 2 (Selesai)
  final RxInt rejectedComplaints = 0.obs; // statusPengaduan = 3 (Ditolak)

  @override
  void onInit() {
    super.onInit();
    _listenToComplaintChanges();
    tabPages = [
      // const DashboardUserView(),   // Tab Utama
      const HomeTabViewSuperadmin(), // Tab Chat
      const ChatListViewAdmin(), // Tab Chat
      const ProfileView(), // Tab Chat
    ];
    // getLength();
    loadUsername();
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }

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

  // String get currentTitle {
  //   switch (currentIndex.value) {
  //     case 0:
  //       return 'Dashboard Superadmin';
  //     case 1:
  //       return 'Chat';
  //     case 2:
  //       return 'Profil';
  //     default:
  //       return '';
  //   }
  // }
void _listenToComplaintChanges() {
    try {
      // Simpan subscription agar bisa di-cancel jika perlu
      _complaintSubscription?.cancel();
      _complaintSubscription = _firestore.collection('complaints').snapshots().listen(
        (QuerySnapshot snapshot) {
          // Hitung jumlah pengaduan berdasarkan statusPengaduan
          int pending = 0;
          int processed = 0;
          int completed = 0;
          int rejected = 0;

          for (var doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['statusPengaduan'];
            if (status == 0) {
              pending++;
            } else if (status == 1) {
              processed++;
            } else if (status == 2) {
              completed++;
            } else if (status == 3) {
              rejected++;
            }
          }

          // Update RxInt agar UI otomatis terupdate
          pendingComplaints.value = pending;
          processedComplaints.value = processed;
          completedComplaints.value = completed;
          rejectedComplaints.value = rejected;

          // Notifikasi jika ada pengaduan baru masuk (status 0)
          if (snapshot.docChanges.isNotEmpty) {
            for (var change in snapshot.docChanges) {
              if (change.type == DocumentChangeType.added) {
                final data = change.doc.data() as Map<String, dynamic>;
                if (data['statusPengaduan'] == 0) {
                  final complaint = Complaint.fromJson(data);
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
          }
        },
        onError: (error) {
          Get.snackbar(
            'Error',
            'Gagal memantau data pengaduan: $error',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memulai pemantauan pengaduan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
