import 'dart:async';

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:developer';

import 'package:saksi_app/app/data/models/Complaint.dart';
import 'package:saksi_app/services/firestore_services.dart';

class ProgresComplaintController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService databaseService = DatabaseService();
  final box = GetStorage();
  var uid = ''.obs;
  var errorMessage = ''.obs;
  var debugInfo = ''.obs;

  // Keep this as QueryDocumentSnapshot as requested
  final RxList<Complaint> userComplaints = <Complaint>[].obs;
  var isLoading = true.obs;
  StreamSubscription<QuerySnapshot>? _complaintSubscription;

  @override
  void onInit() {
    super.onInit();
    loadUid();
    loadComplaints();
    setupAutoRefresh();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    _complaintSubscription?.cancel();
    super.onClose();
  }

  void loadUid() {
    // First check if there's a currently logged in Firebase user
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      uid.value = currentUser.uid;
      debugInfo.value += 'Auth UID: ${uid.value}\n';
      log('Loaded UID from Firebase Auth: ${uid.value}');
    } else {
      // Fall back to stored UID if no current user
      uid.value = box.read('uid') ?? '';
      debugInfo.value += 'Storage UID: ${uid.value}\n';
      log('Loaded UID from GetStorage: ${uid.value}');
    }

    // If we still don't have a UID, we might need to handle the not-logged-in state
    if (uid.value.isEmpty) {
      errorMessage.value = 'No UID found. User may not be logged in.';
      log(errorMessage.value);
    }
  }

  void setupAutoRefresh() {
    _complaintSubscription = FirebaseFirestore.instance
        .collection('complaints')
        .where('uid', isEqualTo: uid.value)
        .snapshots()
        .listen((snapshot) {
      final complaints = snapshot.docs
          .map((doc) => Complaint.fromJson(doc.data()))
          .toList();
      userComplaints.value = complaints;

      if (complaints.isNotEmpty) {
        final complaint = complaints.first;
        debugInfo.value = 'Status: ${complaint.statusPengaduan}';
      } else {
        debugInfo.value = 'No complaints found.';
      }
    }, onError: (error) {
      errorMessage.value = 'Failed to load complaints: $error';
    });
  }

  Future<void> loadComplaints() async {
    isLoading.value = true;
    errorMessage.value = '';
    debugInfo.value = '';
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('complaints')
          .where('uid', isEqualTo: uid.value)
          .get();

      final complaints = snapshot.docs
          .map((doc) => Complaint.fromJson(doc.data()))
          .toList();

      userComplaints.value = complaints;

      if (complaints.isNotEmpty) {
        final complaint = complaints.first;
        debugInfo.value = 'Status: ${complaint.statusPengaduan}';
      } else {
        debugInfo.value = 'No complaints found.';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load complaints: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Manually refresh complaints data
  void refreshComplaints() {
    errorMessage.value = '';
    debugInfo.value = '';
    loadComplaints();
  }
}