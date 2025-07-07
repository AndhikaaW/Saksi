import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
// import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:get_storage/get_storage.dart';
import 'package:saksi_app/app/data/models/Complaint.dart';
// import 'package:awesome_notifications/awesome_notifications.dart';

class ManageComplaintController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Complaint> userComplaints = <Complaint>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt selectedFilter = (-1).obs;
  final RxString searchQuery = ''.obs;
  var errorMessage = ''.obs;
  var debugInfo = ''.obs;
  StreamSubscription<QuerySnapshot>? _complaintSubscription;

  final TextEditingController statusController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController alasanTolak = TextEditingController();

  // Image picker
  final ImagePicker _picker = ImagePicker();
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString selectedImageBase64 = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadComplaints();
  }

  @override
  void onReady() {
    super.onReady();
    userComplaints.clear();
  }

  @override
  void onClose() {
    userComplaints.clear();
    _complaintSubscription?.cancel();
    super.onClose();
  }

  void loadComplaints() {
    isLoading.value = true;
    errorMessage.value = '';
    debugInfo.value = '';
    try {
      _complaintSubscription = _firestore
          .collection('complaints')
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
        } else {
          debugInfo.value = 'No complaints found.';
        }
        isLoading.value = false;
      }, onError: (error) {
        errorMessage.value = 'Failed to load complaints: $error';
        isLoading.value = false;
      });
    } catch (e) {
      errorMessage.value = 'Failed to setup complaint listener: $e';
      isLoading.value = false;
    }
  }
  
  // Fungsi untuk memproses pengaduan
  Future<void> processComplaint(String complaintId) async {
    try {
      // Periksa apakah dokumen ada sebelum melakukan update
      final snapshot = await FirebaseFirestore.instance
          .collection('complaints')
          .where('complaintId', isEqualTo: complaintId)
          .get();

      if (snapshot.docs.isEmpty) {
        Get.snackbar('Error', 'Dokumen pengaduan tidak ditemukan');
        return;
      }

      final docSnapshot = snapshot.docs.first;

      // Ambil data complaint
      // final complaintData = docSnapshot.data() as Map<String, dynamic>;
      // final complaint = Complaint.fromJson(complaintData);

      // Update status pengaduan menggunakan ID dokumen yang benar
      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(docSnapshot.id) // Gunakan document ID dari snapshot
          .update({'statusPengaduan': 1});

      Get.back();
      loadComplaints();
      Get.snackbar('Sukses', 'Pengaduan sedang diproses');
    } catch (error) {
      Get.snackbar('Error', 'Gagal memproses pengaduan: $error');
    }
  }

  Future<void> rejectComplaint(String complaintId) async {
    try {
      // Periksa apakah dokumen ada sebelum melakukan update
      final snapshot = await FirebaseFirestore.instance
          .collection('complaints')
          .where('complaintId', isEqualTo: complaintId)
          .get();

      if (snapshot.docs.isEmpty) {
        Get.snackbar('Error', 'Dokumen pengaduan tidak ditemukan');
        return;
      }

      final docSnapshot = snapshot.docs.first;

      // Update status pengaduan menjadi ditolak (3) dan simpan alasan penolakan
      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(docSnapshot.id)
          .update({
            'statusPengaduan': 3,
            'alasanTolak': alasanTolak.text, // simpan alasan tolak dari controller
          });

      Get.back();
      loadComplaints();
      Get.snackbar('Sukses', 'Pengaduan telah ditolak');
      alasanTolak.clear(); // reset field alasan tolak setelah submit
    } catch (error) {
      Get.snackbar('Error', 'Gagal menolak pengaduan: $error');
    }
  }

  // Fungsi untuk menambahkan progress pengaduan
  Future<void> addProgressToComplaint(String complaintId, Map<String, dynamic> progressData) async {
    try {
      // Periksa apakah dokumen ada sebelum melakukan update
      final snapshot = await FirebaseFirestore.instance
          .collection('complaints')
          .where('complaintId', isEqualTo: complaintId)
          .get();

      if (snapshot.docs.isEmpty) {
        Get.snackbar('Error', 'Dokumen pengaduan tidak ditemukan');
        return;
      }

      final docSnapshot = snapshot.docs.first;

      // Ambil data complaint yang ada
      final complaintData = docSnapshot.data() as Map<String, dynamic>;

      // Ambil array progress yang sudah ada atau buat baru jika belum ada
      List<dynamic> existingProgress = complaintData['progress'] ?? [];

      // Tambahkan progress baru ke array
      existingProgress.add(progressData);

      // Update dokumen dengan progress yang baru
      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(docSnapshot.id)
          .update({'progress': existingProgress});

      // Tambahkan listener untuk memantau perubahan dokumen secara real-time
      docSnapshot.reference.snapshots().listen((DocumentSnapshot snapshot) {
        if (snapshot.exists) {
          final updatedData = snapshot.data() as Map<String, dynamic>;
          final updatedComplaint = Complaint.fromJson(updatedData);

          // Update complaint di list jika ada
          final index =
              userComplaints.indexWhere((c) => c.complaintId == complaintId);
          if (index != -1) {
            userComplaints[index] = updatedComplaint;
          }
        }
      });

      // Get.snackbar('Sukses', 'Progress berhasil ditambahkan');
    } catch (error) {
      Get.snackbar('Error', 'Gagal menambahkan progress: $error');
    }
  }

  // Fungsi untuk menghapus pengaduan
  Future<void> deleteComplaint(String complaintId) async {
    try {
      // Periksa apakah dokumen ada sebelum melakukan delete
      final snapshot = await FirebaseFirestore.instance
          .collection('complaints')
          .where('complaintId', isEqualTo: complaintId)
          .get();

      if (snapshot.docs.isEmpty) {
        Get.snackbar('Error', 'Dokumen pengaduan tidak ditemukan');
        return;
      }

      final docSnapshot = snapshot.docs.first;

      // Hapus dokumen menggunakan document ID yang benar
      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(docSnapshot.id)
          .delete();

      Get.back();
      loadComplaints();
      Get.snackbar('Sukses', 'Pengaduan berhasil dihapus');
    } catch (error) {
      Get.snackbar('Error', 'Gagal menghapus pengaduan: $error');
    }
  }

  // Fungsi untuk menyelesaikan pengaduan
  Future<void> completeComplaint(String complaintId) async {
    try {
      // Periksa apakah dokumen ada sebelum melakukan update
      final snapshot = await FirebaseFirestore.instance
          .collection('complaints')
          .where('complaintId', isEqualTo: complaintId)
          .get();

      if (snapshot.docs.isEmpty) {
        Get.snackbar('Error', 'Dokumen pengaduan tidak ditemukan');
        return;
      }

      final docSnapshot = snapshot.docs.first;

      // Ambil data complaint
      // final complaintData = docSnapshot.data() as Map<String, dynamic>;
      // final complaint = Complaint.fromJson(complaintData);

      // Update status pengaduan menjadi selesai (2)
      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(docSnapshot.id)
          .update({'statusPengaduan': 2});

      Get.back();
      loadComplaints();
      Get.snackbar('Sukses', 'Pengaduan telah diselesaikan');
    } catch (error) {
      Get.snackbar('Error', 'Gagal menyelesaikan pengaduan: $error');
    }
  }

  // Fungsi untuk mencari pengaduan
  void searchComplaints(String query) {
    if (query.isEmpty) {
      loadComplaints();
      return;
    }

    final filteredComplaints = userComplaints.where((complaint) {
      final namaPelapor = complaint.namaPelapor?.toLowerCase() ?? '';
      final deskripsi = complaint.emailPelapor?.toLowerCase() ?? '';
      final searchLower = query.toLowerCase();

      return namaPelapor.contains(searchLower) ||
          deskripsi.contains(searchLower) ||
          complaint.uid.toLowerCase().contains(searchLower);
    }).toList();

    userComplaints.value = filteredComplaints;
  }

  // Fungsi untuk memfilter pengaduan berdasarkan status
  void filterComplaintsByStatus(int status) async {
    isLoading.value = true;
    try {
      QuerySnapshot snapshot;

      if (status == -1) {
        // Status -1 berarti tampilkan semua
        snapshot =
            await FirebaseFirestore.instance.collection('complaints').get();
      } else {
        snapshot = await FirebaseFirestore.instance
            .collection('complaints')
            .where('statusPengaduan', isEqualTo: status)
            .get();
      }

      final complaints = snapshot.docs
          .map((doc) => Complaint.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      userComplaints.value = complaints;
    } catch (e) {
      errorMessage.value = 'Failed to filter complaints: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        await _convertImageToBase64(image);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil gambar dari galeri: $e',
          snackPosition: SnackPosition.TOP);
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        await _convertImageToBase64(image);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil gambar dari kamera: $e',
          snackPosition: SnackPosition.TOP);
    }
  }

  Future<void> _convertImageToBase64(XFile image) async {
    try {
      Uint8List imageBytes = await image.readAsBytes();
      String base64String = base64Encode(imageBytes);
      selectedImageBase64.value = base64String;
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengkonversi gambar: $e',
          snackPosition: SnackPosition.TOP);
    }
  }

  void removeSelectedImage() {
    selectedImage.value = null;
    selectedImageBase64.value = '';
  }

  void showImageSourceDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Pilih Sumber Gambar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Get.back();
                pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Get.back();
                pickImageFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }
}
