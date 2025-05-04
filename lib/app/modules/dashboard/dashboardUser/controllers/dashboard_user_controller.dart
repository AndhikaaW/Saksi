import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:saksi_app/app/modules/chat/views/chat_view.dart';
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
  }

  @override
  void onClose() {
    _complaintSubscription?.cancel();
    super.onClose();
  }

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

  void changeTab(int index) {
    currentIndex.value = index;
    if (currentIndex.value == 0){
      fetchUserProfile();
    }
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
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        userProfile.value = UserProfile.fromJson(userDoc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> checkActiveComplaints() async {
    try {
      String userId = uid.value;
      QuerySnapshot complaints = await _firestore
          .collection('complaints')
          .where('uid', isEqualTo: userId)
          .where('statusPengaduan', whereIn: [0, 1])
          .get();
      
      if (complaints.docs.isEmpty) {
        return false;
      }

      return true;
    } catch (e) {
      print("Error checking active complaints: $e");
      return false;
    }
  }

  Future<void> fetchAdminUsers() async {
    try {
      isLoading.value = true;
      final QuerySnapshot querySnapshot = await _firestore.collection('users').where('status', whereIn: [0, 1]).get();
      
      admins.value = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        String status = '';
        switch(data['status']) {
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
}