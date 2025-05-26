import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:saksi_app/app/data/models/UserProfile.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  final box = GetStorage();
  var uid = ''.obs;
  var userProfile = Rx<UserProfile?>(null);
  var isLoading = true.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Map<String, String> fieldMapping = {
    "Nama": "name",
    "Email": "email",
    "Gender": "gender",
    "Tempat Tanggal Lahir": "ttl",
    "Alamat": "address",
    "Nomor Ponsel": "phone",
    "Status Pengguna": "statusPengguna"
  };

  @override
  void onInit() {
    super.onInit();
    loadUid();
    fetchUserProfile();
  }

    //notifikasi error
  void showError(String message) {
    Get.snackbar(
      'Perhatian',
      message,
      backgroundColor: Colors.red.shade400,
      colorText: Colors.white,
    );
  }

  //notifikasi berhasil
  void showSuccess(String message) {
    Get.snackbar(
      'Berhasil',
      message,
      backgroundColor: Colors.green.shade400,
      colorText: Colors.white,
    );
  }


  void loadUid() {
    uid.value = box.read('uid') ?? 'not found';
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

  Future<void> updateUserProfile(String uiField, String newValue) async {
    try {
      isLoading.value = true;
      String userId = uid.value;
      DocumentReference userDocRef = _firestore.collection('users').doc(userId);

      String? field = fieldMapping[uiField];
      if (field == null) {
        print("Field tidak ditemukan!");
        return;
      }

      DocumentSnapshot userDoc = await userDocRef.get();
      if (userDoc.exists) {
        await userDocRef.set({field: newValue}, SetOptions(merge: true));

        userProfile.update((user) {
          if (user != null) {
            userProfile.value = user.copyWith(
              name: field == "name" ? newValue : user.name,
              email: field == "email" ? newValue : user.email,
              gender: field == "gender" ? newValue : user.gender,
              ttl: field == "ttl" ? newValue : user.ttl,
              address: field == "address" ? newValue : user.address,
              phone: field == "phone" ? newValue : user.phone,
              statusPengguna: field == "statusPengguna" ? newValue : user.statusPengguna,
            );
          }
        });
        showSuccess("Data berhasil diperbarui!");
        isLoading.value = false;
      } else {
        showError("Data pengguna tidak ditemukan.");
      }
    } catch (e) {
      print("Error updating profile: $e");
      showError("Gagal memperbarui data.");
      isLoading.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<XFile?> pickImageFromGallery() async {
    // Fungsi ini menggunakan image_picker untuk memilih gambar dari galeri
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      return pickedFile;
    } catch (e) {
      print("Gagal memilih gambar dari galeri: $e");
      return null;
    }
  }

  Future<XFile?> pickImageFromCamera() async {
    // Fungsi ini menggunakan image_picker untuk mengambil gambar dari kamera
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      return pickedFile;
    } catch (e) {
      print("Gagal mengambil gambar dari kamera: $e");
      return null;
    }
  }

  Future<void> uploadProfilePhoto(XFile pickedFile) async {
    if (pickedFile == null) {
      showError("Tidak ada file yang dipilih.");
      return;
    }
    // Ada batas maksimal upload foto jika disimpan sebagai string base64 di Firestore.
    // Berdasarkan error: "The value of property 'photoUrl' is longer than 1048487 bytes."
    // Artinya, ukuran maksimal field photoUrl di Firestore adalah sekitar 1MB (1.048.487 bytes).
    // Jadi, sebelum upload, sebaiknya cek ukuran file setelah di-encode base64.

    try {
      isLoading.value = true;
      String userId = uid.value;
      // Baca file sebagai bytes
      final bytes = await File(pickedFile.path).readAsBytes();
      // Encode ke base64
      String base64Image = base64Encode(bytes);

      // Cek batas maksimal 1MB (1.048.487 bytes)
      if (base64Image.length > 1048487) {
        showError("Ukuran foto terlalu besar. Maksimal 1MB.");
        return;
      }

      // Update field photoUrl di Firestore dengan base64 string
      await _firestore.collection('users').doc(userId).update({'photoUrl': base64Image});

      // Update di local userProfile
      userProfile.update((user) {
        if (user != null) {
          userProfile.value = user.copyWith(photoUrl: base64Image);
        }
      });

      showSuccess("Foto profil berhasil diperbarui!");
      isLoading.value = false;
    } catch (e) { 
      print("Gagal upload foto profil: $e");
      showError("Gagal upload foto profil. $e");
      isLoading.value = false;
    } finally {
      isLoading.value = false;
    }
  }


  void logout() async {
    // Implementasi logout
    // Contoh:
    // await FirebaseAuth.instance.signOut();

    await _auth.signOut();
    await _googleSignIn.signOut();

    // Clear local storage
    final box = GetStorage();
    await box.erase();

    // Navigasi ke halaman login
    Get.offAllNamed('/login');
  }
}
