import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:saksi_app/app/modules/dashboard/dashboardUser/controllers/dashboard_user_controller.dart';
import 'package:saksi_app/app/modules/dashboard/dashboardUser/views/dashboard_user_view.dart';
import 'package:saksi_app/app/data/models/UserProfile.dart';
import 'package:saksi_app/services/firestore_services.dart';

class ComplaintController extends GetxController {
  final DatabaseService databaseService = DatabaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final box = GetStorage();
  var uid = ''.obs;
  final userProfile = Rx<UserProfile?>(null);

  // Controller untuk input fields
  late String emailPelapor;
  final TextEditingController namaPelapor = TextEditingController();
  final TextEditingController noTeleponPelapor = TextEditingController();
  final TextEditingController domisiliPelapor = TextEditingController();
  final TextEditingController jenisKekerasan = TextEditingController();
  final TextEditingController ceritaSingkatPeristiwa = TextEditingController();
  final TextEditingController keteranganDisabilitas = TextEditingController();
  final TextEditingController noTeleponPihakLain = TextEditingController();
  final genderPelapor = TextEditingController();

  // Observable untuk jenis kelamin
  var selectedGender = RxnString();
  // Observable untuk disabilitas
  var selectedDisabilitas = RxnString();

  final TextEditingController alasanPengaduan = TextEditingController();
  final TextEditingController alasanPengaduanLainnya = TextEditingController();
  final TextEditingController identifikasiKebutuhan = TextEditingController();
  final TextEditingController identifikasiKebutuhanLainnya =
      TextEditingController();

  //Terlapor
  final TextEditingController statusTerlapor = TextEditingController();
  final genderTerlapor = TextEditingController();
  // Observable untuk disabilitas
  var StatusTerlapor = ''.obs;
  // Observable untuk jenis kelamin
  var selectedGenderTerlapor = RxnString();

  void setGenderTerlapor(String value) {
    selectedGenderTerlapor.value = value;
    genderTerlapor.text = value;
  }

  // loading
  var isLoading = false.obs;
  // Observable untuk melacak langkah saat ini
  final currentStep = 0.obs;
  // Observable untuk cek persetujuan pada langkah terakhir
  final agreementChecked = false.obs;

  void setDisabilitas(String value) {
    selectedDisabilitas.value = value;
    if (value == 'Iya') {
      keteranganDisabilitas.clear();
    }
    if (value == 'Tidak') {
      keteranganDisabilitas.text = value;
    }
  }

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
        // Validasi alamat email (opsional)
        if (noTeleponPelapor.text.isNotEmpty &&
            noTeleponPelapor.text.contains('@') &&
            !GetUtils.isEmail(noTeleponPelapor.text)) {
          _showError('Format email tidak valid');
          return false;
        }
        return true;

      case 1: // Detail Kejadian
        if (jenisKekerasan.text.isEmpty) {
          _showError('Jenis kekerasan harus diisi');
          return false;
        }
        if (ceritaSingkatPeristiwa.text.isEmpty) {
          _showError('Cerita singkat kejadian harus diisi');
          return false;
        }
        return true;

      case 2: // Bukti
        // Tidak ada validasi wajib pada langkah ini
        return true;

      case 3: // Konfirmasi
        // Sudah dihandle dengan disabling tombol submit
        return true;

      default:
        return true;
    }
  }

  //kirim form
  Future<void> submitForm() async {
    // Validasi semua data sebelum final submit
    if (!validateAllData()) {
      return;
    }
    try {
      isLoading.value = true; // Tampilkan indikator loading

      // Simulasi API Call
      // await Future.delayed(const Duration(seconds: 2));

      // Kirim data ke database
      await databaseService.createComplaint(
          // pelapor
          uid: uid.toString(),
          emailPelapor: emailPelapor,
          namaPelapor: namaPelapor.text,
          noTeleponPelapor: noTeleponPelapor.text,
          domisiliPelapor: domisiliPelapor.text,
          jenisKelaminPelapor: genderPelapor.text,
          jenisKekerasanSeksual: jenisKekerasan.text,
          noTeleponPihakLain: noTeleponPihakLain.text,
          // kejadian
          ceritaSingkatPeristiwa: ceritaSingkatPeristiwa.text,
          keteranganDisabilitas: keteranganDisabilitas.text,
          alasanPengaduan: alasanPengaduan.text,
          alasanPengaduanLainnya: alasanPengaduanLainnya.text,
          identifikasiKebutuhan: identifikasiKebutuhan.text,
          identifikasiKebutuhanLainnya: identifikasiKebutuhanLainnya.text,
          // terlapor
          statusTerlapor: statusTerlapor.text,
          jenisKelaminTerlapor: genderTerlapor.text);
      _showSuccess('Laporan Anda telah berhasil dikirim');
      resetForm();
      
      await Future.delayed(Duration(seconds: 1));

      Get.offAllNamed('/dashboard-user');
      Get.lazyPut(() => DashboardUserController());
      Get.find<DashboardUserController>().changeTab(1);
    } catch (e) {
      Get.snackbar("Error", "Gagal mengirim data");
    } finally {
      isLoading.value = false; // Sembunyikan indikator loading
    }

    // Reset form atau arahkan ke halaman konfirmasi
    // resetForm();
  }

  //validasi data
  bool validateAllData() {
    // Validasi dasar wajib
    if (namaPelapor.text.isEmpty) {
      _showError('Nama pelapor harus diisi');
      currentStep.value = 0; // Kembali ke step pertama
      return false;
    }

    if (jenisKekerasan.text.isEmpty) {
      _showError('Jenis kekerasan harus diisi');
      currentStep.value = 1; // Kembali ke step kedua
      return false;
    }

    if (ceritaSingkatPeristiwa.text.isEmpty) {
      _showError('Cerita singkat kejadian harus diisi');
      currentStep.value = 1; // Kembali ke step kedua
      return false;
    }

    if (!agreementChecked.value) {
      _showError('Anda harus menyetujui pernyataan sebelum mengirim laporan');
      return false;
    }

    return true;
  }

  //reset form
  void resetForm() {
    // Pelapor
    namaPelapor.clear();
    noTeleponPelapor.clear();
    domisiliPelapor.clear();
    jenisKekerasan.clear();
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

  void loadUid() {
    uid.value = box.read('uid') ?? 'not found';
  }

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

  void setGender(String value) {
    selectedGender.value = value;
    genderPelapor.text = value;
  }

  void populateFormWithProfileData() {
    if (userProfile.value != null) {
      final profile = userProfile.value!;

      emailPelapor = profile.email;
      namaPelapor.text = profile.name;
      noTeleponPelapor.text = profile.phone;
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
