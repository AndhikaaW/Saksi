import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// import 'package:saksi_app/app/modules/chat/views/chat_view.dart';
import 'package:saksi_app/app/modules/dashboard/dashboardUser/views/home_user.dart';
import 'package:saksi_app/app/data/models/UserProfile.dart';
import 'package:saksi_app/app/modules/profile/views/profile_view.dart';
import 'package:saksi_app/app/modules/progresComplaint/views/progres_complaint_view.dart';

class DashboardUserController extends GetxController {
  final box = GetStorage();
  var userProfile = Rx<UserProfile?>(null);

  final currentIndex = 0.obs;
  late List<Widget> tabPages;

  var email = ''.obs;
  var uid = ''.obs;
  var isLoading = true.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _complaintSubscription;
  late StreamSubscription<QuerySnapshot> _statuscomplaintSubscription;

  final RxList<Map<String, dynamic>> admins = <Map<String, dynamic>>[].obs;

  String get currentTitle {
    switch (currentIndex.value) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Progress Aduan';
      case 2:
        return 'Profil';
      default:
        return '';
    }
  }

  @override
  void onInit() {
    super.onInit();
    tabPages = [
      const HomeTabViewUser(),
      const ProgresComplaintView(),
      const ProfileView(),
    ];
    loadUid();
    loadUserdata();
    fetchUserProfile();
    _startComplaintListener();
    fetchAdminUsers();
    listenToComplaintStatusChanges();
  }

  @override
  void onClose() {
    _complaintSubscription?.cancel();
    super.onClose();
  }

// ubah tab
  void changeTab(int index) {
    currentIndex.value = index;
    if (currentIndex.value == 0) {
      fetchUserProfile();
    }
  }

// load user untuk user yang login saat itu
  void _startComplaintListener() {
    String userId = uid.value;
    _complaintSubscription = _firestore
        .collection('complaints')
        .where('uid', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      fetchUserProfile();
    });
  }

  void loadUid() {
    uid.value = box.read('uid') ?? 'not found';
  }

  void loadUserdata() {
    email.value = box.read('email') ?? 'not found';
  }

  Future<void> fetchUserProfile() async {
    try {
      String userId = uid.value;
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        userProfile.value =
            UserProfile.fromJson(userDoc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

// cek adakah pengaduan yang aktif jika ingin melakukan pengaduan lagi
  Future<bool> checkActiveComplaints() async {
    try {
      String userId = uid.value;
      QuerySnapshot complaints = await _firestore
          .collection('complaints')
          .where('uid', isEqualTo: userId)
          .where('statusPengaduan', whereIn: [0, 1]).get();

      if (complaints.docs.isEmpty) {
        return false;
      }

      return true;
    } catch (e) {
      print("Error checking active complaints: $e");
      return false;
    }
  }

// menampilkan struktur anggota ppks
  Future<void> fetchAdminUsers() async {
    try {
      isLoading.value = true;
      final QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('status', whereIn: [0, 1]).get();

      admins.value = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        String status = '';
        switch (data['status']) {
          case 2:
            status = 'User';
            break;
          default:
            status = '';
        }
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'status': status,
          'email': data['email'] ?? '',
          'photoUrl': data['photoUrl'] ?? '',
        };
      }).toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil data pengguna: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Memantau perubahan status pengaduan
  void listenToComplaintStatusChanges() {
    try {
      if (uid.isEmpty) {
        return;
      }

      // Buat query untuk memantau pengaduan milik pengguna ini
      final complaintQuery =
          _firestore.collection('complaints').where('uid', isEqualTo: uid.value);

      // Mulai mendengarkan perubahan
      _statuscomplaintSubscription = complaintQuery.snapshots().listen((snapshot) {
        if (snapshot.docChanges.isNotEmpty) {
          for (var change in snapshot.docChanges) {
            // Cek jika dokumen dimodifikasi (status berubah)
            if (change.type == DocumentChangeType.modified) {
              final data = change.doc.data() as Map<String, dynamic>;
              final int statusPengaduan = data['statusPengaduan'] ?? 0;
              final String complaintId = data['complaintId'] ?? '';

              String statusMessage = '';
              String title = '';

              // Tentukan pesan berdasarkan status
              switch (statusPengaduan) {
                case 1:
                  title = 'Pengaduan Diproses';
                  statusMessage =
                      'Pengaduan $complaintId sedang diproses oleh admin';
                  break;
                case 2:
                  title = 'Pengaduan Selesai';
                  statusMessage =
                      'Pengaduan $complaintId telah selesai diproses';
                  break;
                case 3:
                  title = 'Pengaduan Ditolak';
                  statusMessage = 'Pengaduan $complaintId telah ditolak';
                  break;
              }

              // Tampilkan notifikasi jika ada perubahan status
              if (statusMessage.isNotEmpty) {
                AwesomeNotifications().createNotification(
                  content: NotificationContent(
                    id: 11,
                    channelKey: 'complaint_channel',
                    title: title,
                    body: statusMessage,
                    notificationLayout: NotificationLayout.Default,
                    payload: {'complaintId': complaintId},
                    wakeUpScreen: true,
                    category: NotificationCategory.Message,
                    displayOnBackground: true,
                    displayOnForeground: true,
                    criticalAlert: true,
                  ),
                  // actionButtons: [
                  //   NotificationActionButton(
                  //     key: 'VIEW',
                  //     label: 'Lihat Detail',
                  //   ),
                  // ],
                );
              }
            }
          }
        }
      }, onError: (error) {
        print("Error listening to complaint changes: $error");
      });
    } catch (e) {
      print("Error setting up complaint listener: $e");
    }
  }
}
