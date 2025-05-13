import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:saksi_app/app/modules/dashboard/dashboardUser/controllers/dashboard_user_controller.dart';
// import 'package:saksi_app/app/modules/dashboard/dashboardUser/views/dashboard_user_view.dart';
import 'package:saksi_app/app/data/models/UserProfile.dart';
import 'package:saksi_app/services/firestore_services.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class ComplaintController extends GetxController {
  final DatabaseService databaseService = DatabaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final userProfile = Rx<UserProfile?>(null);
  
  // Get Storage
  final box = GetStorage();
  var uid = ''.obs;
  late String complaintId;

  // Controller untuk input fields
  late String emailPelapor;
  final TextEditingController namaPelapor = TextEditingController();
  final TextEditingController noTeleponPelapor = TextEditingController();
  final statusPelapor = TextEditingController();
  final TextEditingController domisiliPelapor = TextEditingController();
  final TextEditingController bentukKekerasan = TextEditingController();
  final TextEditingController ceritaSingkatPeristiwa = TextEditingController();
  final TextEditingController keteranganDisabilitas = TextEditingController();
  final TextEditingController noTeleponPihakLain = TextEditingController();
  final genderPelapor = TextEditingController();
  var selectedGender = RxnString();
  void setGender(String value) {
    selectedGender.value = value;
    genderPelapor.text = value;
  }
  
  var selectedDisabilitas = RxnString();
  void setDisabilitas(String value) {
    selectedDisabilitas.value = value;
    if (value == 'Iya') {
      keteranganDisabilitas.clear();
    }
    if (value == 'Tidak') {
      keteranganDisabilitas.text = value;
    }
  }

  final TextEditingController alasanPengaduan = TextEditingController();
  final TextEditingController alasanPengaduanLainnya = TextEditingController();
  final TextEditingController identifikasiKebutuhan = TextEditingController();
  final TextEditingController identifikasiKebutuhanLainnya = TextEditingController();

  //Terlapor
  final TextEditingController statusTerlapor = TextEditingController();
  final genderTerlapor = TextEditingController();
  var selectedGenderTerlapor = RxnString();
  void setGenderTerlapor(String value) {
    selectedGenderTerlapor.value = value;
    genderTerlapor.text = value;
  }

  // Observable untuk foto KTP
  var ktpImage = Rxn<File>();
  var buktiImage = Rxn<File>();
  // final ImagePicker _picker = ImagePicker();
  // final TextEditingController maxWidthController = TextEditingController();
  // final TextEditingController maxHeightController = TextEditingController();
  // final TextEditingController qualityController = TextEditingController();

  // Future<void> pickKtpImage() async {
  //   try {
  //     final XFile? pickedFile = await _picker.pickImage(
  //       source: ImageSource.gallery,
  //       maxWidth: maxWidthController.text.isNotEmpty
  //           ? double.parse(maxWidthController.text)
  //           : 1024,
  //       maxHeight: maxHeightController.text.isNotEmpty
  //           ? double.parse(maxHeightController.text)
  //           : 1024,
  //       imageQuality: qualityController.text.isNotEmpty
  //           ? int.parse(qualityController.text)
  //           : 50,
  //     );

  //     if (pickedFile != null) {
  //       final File imageFile = File(pickedFile.path);
  //       if (await imageFile.exists()) {
  //         ktpImage.value = imageFile;
  //         Get.snackbar('Berhasil', 'Foto KTP berhasil dipilih');
  //       } else {
  //         Get.snackbar('Gagal', 'File foto tidak ditemukan');
  //       }
  //     }
  //   } catch (e) {
  //     Get.snackbar('Error', 'Terjadi kesalahan saat memilih foto KTP');
  //     print('Error picking KTP image: $e');
  //   }
  // }

  // Future<void> pickBuktiImage() async {
  //   try {
  //     final XFile? pickedFile = await _picker.pickImage(
  //       source: ImageSource.gallery,
  //       maxWidth: maxWidthController.text.isNotEmpty
  //           ? double.parse(maxWidthController.text)
  //           : 1024,
  //       maxHeight: maxHeightController.text.isNotEmpty
  //           ? double.parse(maxHeightController.text)
  //           : 1024,
  //       imageQuality: qualityController.text.isNotEmpty
  //           ? int.parse(qualityController.text)
  //           : 50,
  //     );

  //     if (pickedFile != null) {
  //       final File imageFile = File(pickedFile.path);
  //       if (await imageFile.exists()) {
  //         buktiImage.value = imageFile;
  //         Get.snackbar('Berhasil', 'Bukti pendukung berhasil dipilih');
  //       } else {
  //         Get.snackbar('Gagal', 'File bukti tidak ditemukan');
  //       }
  //     }
  //   } catch (e) {
  //     Get.snackbar('Error', 'Terjadi kesalahan saat memilih bukti pendukung');
  //     print('Error picking evidence image: $e');
  //   }
  // }

  // Observable untuk disabilitas
  // var StatusTerlapor = ''.obs;
  // Observable untuk jenis kelamin

  // Jika function seperti ini, variabelnya bisa didefinisikan sebagai berikut:
  var selectedStatusPelapor = RxnString();
  void setStatusPelapor(String value) {
    selectedStatusPelapor.value = value;
    statusPelapor.text = value;
  }

  // loading
  var isLoading = false.obs;
  // Observable untuk melacak langkah saat ini
  final currentStep = 0.obs;
  // Observable untuk cek persetujuan pada langkah terakhir
  final agreementChecked = false.obs;

  

  @override
  void onInit() {
    super.onInit();
    loadUid();
    fetchUserProfile();
  }

  // Validasi khusus per langkah
  bool validateCurrentStep() {
    switch (currentStep.value) {
      case 0: // Data Diri
        if (namaPelapor.text.isEmpty) {
          _showError('Nama pelapor harus diisi');
          return false;
        }
        if (noTeleponPelapor.text.isEmpty) {
          _showError('No telepon harus diisi');
          return false;
        }
        if (genderPelapor.text.isEmpty) {
          _showError('Jenis kelamin belum dipilih');
          return false;
        }
        if (domisiliPelapor.text.isEmpty) {
          _showError('Domisili harus diisi');
          return false;
        }
        if (keteranganDisabilitas.text.isEmpty) {
          _showError('Keterangan Disabilitas belum dipilih');
          return false;
        }
        if (noTeleponPihakLain.text.isEmpty) {
          _showError('No Telepon Pihak Lain harus diisi');
          return false;
        }
        return true;

      case 1: // Detail Kejadian
        if (bentukKekerasan.text.isEmpty) {
          _showError('Bentuk kekerasan harus diisi');
          return false;
        }
        if (ceritaSingkatPeristiwa.text.isEmpty) {
          _showError('Cerita singkat kejadian harus diisi');
          return false;
        }
        if (alasanPengaduan.text.isEmpty) {
          _showError('Alasan pengaduan harus diisi');
          return false;
        }
        if (identifikasiKebutuhan.text.isEmpty) {
          _showError('Identifikasi kebutuhan harus diisi');
          return false;
        }
        return true;

      case 2: // Bukti
        if (statusTerlapor.text.isEmpty) {
          _showError('Status terlapor belum dipilih');
          return false;
        }
        if (genderTerlapor.text.isEmpty) {
          _showError('Gender terlapor belum dipilih');
          return false;
        }
        return true;

      case 3: // Konfirmasi
        if (!agreementChecked.value) {
          _showError(
              'Anda harus menyetujui pernyataan sebelum mengirim laporan');
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  //kirim form
  Future<void> submitForm() async {
    generateComplaintId();
    await Future.delayed(Duration(seconds: 1));

    try {
      isLoading.value = true;

      String ktpImageBase64 = '';
      String buktiImageBase64 = '';

      if (ktpImage.value != null) {
        List<int> imageBytes = await ktpImage.value!.readAsBytes();
        ktpImageBase64 = base64Encode(imageBytes);
      }

      if (buktiImage.value != null) {
        List<int> imageBytes = await buktiImage.value!.readAsBytes();
        buktiImageBase64 = base64Encode(imageBytes);
      }

      await databaseService.createComplaint(
          complaintId: complaintId,
          uid: uid.toString(),
          emailPelapor: emailPelapor,
          namaPelapor: namaPelapor.text,
          noTeleponPelapor: noTeleponPelapor.text,
          statusPelapor: statusPelapor.text,
          domisiliPelapor: domisiliPelapor.text,
          jenisKelaminPelapor: genderPelapor.text,
          bentukKekerasanSeksual: bentukKekerasan.text,
          noTeleponPihakLain: noTeleponPihakLain.text,
          ceritaSingkatPeristiwa: ceritaSingkatPeristiwa.text,
          keteranganDisabilitas: keteranganDisabilitas.text,
          alasanPengaduan: alasanPengaduan.text,
          alasanPengaduanLainnya: alasanPengaduanLainnya.text,
          identifikasiKebutuhan: identifikasiKebutuhan.text,
          identifikasiKebutuhanLainnya: identifikasiKebutuhanLainnya.text,
          statusTerlapor: statusTerlapor.text,
          jenisKelaminTerlapor: genderTerlapor.text,
          ktpImageUrl: ktpImageBase64,
          buktiImageUrl: buktiImageBase64);

      // Tampilkan notifikasi
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 10,
          channelKey: 'complaint_channel',
          title: 'Pengaduan Berhasil',
          body: 'Pengaduan Anda telah berhasil dikirim dan sedang diproses',
          notificationLayout: NotificationLayout.Default,
        ),
      );

      resetForm();

      await Future.delayed(Duration(seconds: 1));

      Get.offAllNamed('/dashboard-user');
      Get.lazyPut(() => DashboardUserController());
      Get.find<DashboardUserController>().changeTab(1);
    } catch (e) {
      Get.snackbar("Error", "Gagal mengirim data");
    } finally {
      isLoading.value = false;
    }
  }

  //reset form
  void resetForm() {
    // Pelapor
    namaPelapor.clear();
    noTeleponPelapor.clear();
    domisiliPelapor.clear();
    bentukKekerasan.clear();
    ceritaSingkatPeristiwa.clear();
    selectedDisabilitas.value = '';
    selectedGender.value = '';
    ceritaSingkatPeristiwa.clear();
    noTeleponPihakLain.clear();

    alasanPengaduan.clear();
    alasanPengaduanLainnya.clear();
    identifikasiKebutuhan.clear();
    identifikasiKebutuhanLainnya.clear();
    // Terlapor
    statusTerlapor.clear();
    selectedGenderTerlapor.value = '';

    currentStep.value = 0;
    agreementChecked.value = false;
  }

  //notifikasi error
  void _showError(String message) {
    Get.snackbar(
      'Perhatian',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  //notifikasi berhasil
  void _showSuccess(String message) {
    Get.snackbar(
      'Berhasil',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  //ambil data dari profil
  //set uid
  void loadUid() {
    uid.value = box.read('uid') ?? 'not found';
  }

  //set data profil
  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;
      String userId = uid.value;

      if (userId == 'not found') {
        print("User ID not found in storage");
        return;
      }

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        userProfile.value = UserProfile.fromJson(userData);

        // Auto-populate the form fields with user profile data
        populateFormWithProfileData();
      } else {
        print("User document does not exist");
      }
    } catch (e) {
      print("Error fetching profile: $e");
      _showError('Gagal mengambil data profil');
    } finally {
      isLoading.value = false;
    }
  }

  // Populate form with profile data
  void populateFormWithProfileData() {
    if (userProfile.value != null) {
      final profile = userProfile.value!;

      emailPelapor = profile.email;
      namaPelapor.text = profile.name;
      noTeleponPelapor.text = profile.phone;
      statusPelapor.text = profile.statusPengguna;
      domisiliPelapor.text = profile.address;

      if (profile.gender.isNotEmpty) {
        if (profile.gender == 'Laki-laki' || profile.gender == 'Perempuan') {
          setGender(profile.gender);
        }
      }

      _showSuccess('Data profil berhasil dimuat');
    }
  }

  bool isGenderSelected(String gender) {
    return selectedGender.value == gender;
  }

  // Generate Complaint ID
  void generateComplaintId() async {
    final now = DateTime.now();
    final datePart =
        "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";

    // Mendapatkan jumlah dokumen yang ada untuk hari ini
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));

    final querySnapshot = await FirebaseFirestore.instance
        .collection('complaints')
        .where('tanggalPelaporan', isGreaterThanOrEqualTo: today)
        .where('tanggalPelaporan', isLessThan: tomorrow)
        .get();

    final sequenceNumber = querySnapshot.docs.length + 1;
    complaintId = "${datePart}_$sequenceNumber";
  }

  // @override
  // void onClose() {
  //   // Bersihkan resources
  //   namaPelapor.dispose();
  //   noTeleponPelapor.dispose();
  //   domisiliPelapor.dispose();
  //   jenisKekerasan.dispose();
  //   ceritaSingkatPeristiwa.dispose();
  //   super.onClose();
  // }
}
