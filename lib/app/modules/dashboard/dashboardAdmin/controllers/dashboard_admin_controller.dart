import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:saksi_app/app/data/models/Complaint.dart';
import 'package:saksi_app/app/modules/chat/views/chat_list_view_admin.dart';
import 'package:saksi_app/app/modules/dashboard/dashboardAdmin/views/home_admin.dart';
import 'package:saksi_app/app/modules/profile/views/profile_view.dart';

class DashboardAdminController extends GetxController {
  final box = GetStorage();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var username = ''.obs;
  final currentIndex = 0.obs;
  late List<Widget> tabPages;
  final RxInt users = 0.obs;

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
      const HomeTabViewAdmin(),
      const ChatListViewAdmin(),
      const ProfileView(),
    ];

    loadUsername();
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }

  void logout() async {
    final box = GetStorage();
    await box.erase();
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

  /// Fungsi ini akan memantau koleksi complaints di Firestore secara real-time,
  /// dan otomatis mengupdate jumlah pengaduan berdasarkan statusPengaduan.
  /// Setiap ada perubahan data di Firestore, nilai RxInt akan langsung terupdate.
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
