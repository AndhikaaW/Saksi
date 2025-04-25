import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:saksi_app/app/modules/chat/views/chat_view.dart';
import 'package:saksi_app/app/modules/dashboard/dashboardAdmin/views/home_admin.dart';
import 'package:saksi_app/app/modules/profile/views/profile_view.dart';

class DashboardAdminController extends GetxController {
  final box = GetStorage();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var username = ''.obs;
  final currentIndex = 0.obs; // Gunakan .obs untuk reaktivitas
  late List<Widget> tabPages;
  final RxInt users = 0.obs;
  
  late StreamSubscription<QuerySnapshot> _userSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenToUserChanges();

    tabPages = [
      // const DashboardUserView(),   // Tab Utama
      const HomeTabViewAdmin(),   // Tab Chat
      const ChatView(),   // Tab Chat
      const ProfileView(),   // Tab Chat
    ];

    loadUsername();
    // Mulai mendengarkan perubahan data user
  }

  @override
  void onClose() {
    // Batalkan subscription saat controller dihapus
    _userSubscription.cancel();
    super.onClose();
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

  void _listenToUserChanges() {
    try {
      // Buat query untuk memantau perubahan pada user dengan status = 2
      final userQuery = _firestore
          .collection('users')
          .where('status', isEqualTo: 2);

      // Mulai mendengarkan perubahan
      _userSubscription = userQuery.snapshots().listen((snapshot) {
        // Update nilai users setiap kali ada perubahan
        users.value = snapshot.size;
      }, onError: (error) {
        Get.snackbar(
          'Error',
          'Gagal memantau data user: $error',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memulai pemantauan user: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
