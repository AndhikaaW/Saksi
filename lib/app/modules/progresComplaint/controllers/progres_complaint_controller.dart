import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:developer';

import 'package:saksi_app/app/data/models/Complaint.dart';
import 'package:saksi_app/services/firestore_services.dart';

class ProgresComplaintController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService databaseService = DatabaseService();
  final box = GetStorage();
  var uid = ''.obs;
  var errorMessage = ''.obs;
  var debugInfo = ''.obs;

  final RxList<Complaint> userComplaints = <Complaint>[].obs;
  var isLoading = true.obs;
  StreamSubscription<QuerySnapshot>? _complaintSubscription;

  // Tambahkan variabel untuk menyimpan gambar dalam base64
  var ktpImageBase64 = ''.obs;
  var buktiImageBase64 = ''.obs;
  var hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUid();
    loadComplaints();
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
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      uid.value = currentUser.uid;
      debugInfo.value += 'Auth UID: ${uid.value}\n';
      log('Loaded UID from Firebase Auth: ${uid.value}');
    } else {
      uid.value = box.read('uid') ?? '';
      debugInfo.value += 'Storage UID: ${uid.value}\n';
      log('Loaded UID from GetStorage: ${uid.value}');
    }

    if (uid.value.isEmpty) {
      errorMessage.value = 'No UID found. User may not be logged in.';
      hasError.value = true;
      log(errorMessage.value);
    }
  }

  void loadComplaints() {
    isLoading.value = true;
    errorMessage.value = '';
    debugInfo.value = '';
    try {
      _complaintSubscription = _firestore
          .collection('complaints')
          .where('uid', isEqualTo: uid.value)
          .snapshots()
          .listen((QuerySnapshot snapshot) {
        final complaints = snapshot.docs
            .map(
                (doc) => Complaint.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
        userComplaints.value = complaints;
        if (complaints.isNotEmpty) {
          final complaint = complaints.first;
          debugInfo.value = 'Status: ${complaint.statusPengaduan}';
          // Simpan gambar base64 dari complaint dengan error handling yang lebih baik
          try {
            if (complaint.lampiranKtp != null && complaint.lampiranKtp.isNotEmpty) {
              // Coba bersihkan string base64 dari karakter yang tidak valid
              final cleanedKtpBase64 = complaint.lampiranKtp.replaceAll(RegExp(r'\s+'), '');
              // Verifikasi format base64 yang valid
              if (RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(cleanedKtpBase64)) {
                ktpImageBase64.value = cleanedKtpBase64;
                print('KTP image loaded successfully');
              } else {
                print('Format KTP image tidak valid, mencoba ambil dari Storage');
              }
            } else {
              ktpImageBase64.value = '';
              print('KTP image kosong atau tidak ditemukan');
            }
          } catch (e) {
            ktpImageBase64.value = '';
            print('Error saat memuat gambar KTP: $e');
          }
          try {
            if (complaint.lampiranBukti != null && complaint.lampiranBukti.isNotEmpty) {
              // Bersihkan string base64 dari karakter yang tidak valid
              final cleanedBuktiBase64 = complaint.lampiranBukti.replaceAll(RegExp(r'\s+'), '');
              // Verifikasi format base64 yang valid
              if (RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(cleanedBuktiBase64)) {
                buktiImageBase64.value = cleanedBuktiBase64;
                log('Bukti pendukung berhasil dimuat');
              } else {
                log('Format bukti pendukung tidak valid, mencoba ambil dari Storage');
              }
            } else {
              buktiImageBase64.value = '';
              log('Bukti pendukung kosong atau tidak ditemukan');
            }
          } catch (e) {
            buktiImageBase64.value = '';
            log('Error saat memuat bukti pendukung: $e');
            // Coba ambil dari Firebase Storage sebagai fallback
            // _fetchImageFromStorage('bukti_images/${complaint.complaintId}', (base64String) {
            //   buktiImageBase64.value = base64String;
            // });
          }

          hasError.value = false;
        } else {
          debugInfo.value = 'No complaints found.';
          hasError.value = true;
        }
        isLoading.value = false;
      }, onError: (error) {
        errorMessage.value = 'Failed to load complaints: $error';
        hasError.value = true;
        isLoading.value = false;
      });
    } catch (e) {
      errorMessage.value = 'Failed to setup complaint listener: $e';
      hasError.value = true;
      isLoading.value = false;
    }
  }

  // Future<void> fetchActiveComplaints() async {
  //   try {
  //     isLoading.value = true;

  //     final QuerySnapshot querySnapshot = await _firestore
  //         .collection('complaints')
  //         .where('uid', isEqualTo: uid.value)
  //         .where('statusPengaduan', whereIn: [0, 1]).get();

  //     final List<Complaint> complaints = [];

  //     for (var doc in querySnapshot.docs) {
  //       Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  //       data['uid'] = doc.id;
  //       complaints.add(Complaint.fromJson(data));
  //     }

  //     userComplaints.assignAll(complaints);
  //   } catch (error) {
  //     Get.snackbar(
  //       'Error',
  //       'Gagal mengambil data pengaduan: $error',
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  void refreshComplaints() {
    errorMessage.value = '';
    debugInfo.value = '';
    loadComplaints();
  }
}
