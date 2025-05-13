import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:saksi_app/app/modules/chat/views/chat_list_view.dart';
import 'package:saksi_app/app/modules/chat/views/chat_view.dart';
import 'package:saksi_app/app/modules/dashboard/dashboardSuperadmin/views/home_superadmin.dart';
import 'package:saksi_app/app/modules/profile/views/profile_view.dart';

class DashboardSuperadminController extends GetxController {
  final box = GetStorage();
  var username = ''.obs;
  final currentIndex = 0.obs; // Gunakan .obs untuk reaktivitas
  late List<Widget> tabPages;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxInt admins = 0.obs;
  final RxInt users = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    tabPages = [
      // const DashboardUserView(),   // Tab Utama
      const HomeTabViewSuperadmin(), // Tab Chat
      const ChatListView(), // Tab Chat
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

  String get currentTitle {
    switch (currentIndex.value) {
      case 0:
        return 'Dashboard Superadmin';
      case 1:
        return 'Chat';
      case 2:
        return 'Profil';
      default:
        return '';
    }
  }

  // Future<void> getLength() async {
  //   try {
  //     isLoading.value = true;

  //     // Get admin users count (status = 1)
  //     final QuerySnapshot adminSnapshot = await _firestore
  //         .collection('users')
  //         .where('status', whereIn: [0, 1])
  //         .get();
  //     admins.value = adminSnapshot.size;

  //     // Get regular users count (status = 2)
  //     final QuerySnapshot userSnapshot = await _firestore
  //         .collection('users')
  //         .where('status', isEqualTo: 2)
  //         .get();
  //     users.value = userSnapshot.size;
  //   } catch (e) {
  //     Get.snackbar(
  //       'Error',
  //       'Gagal mengambil data user: $e',
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
}
