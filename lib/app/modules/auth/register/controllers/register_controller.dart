import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:saksi_app/services/firestore_services.dart';
import 'dart:math';

class RegisterController extends GetxController {
  final dbService = DatabaseService();

  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final jenisKelaminController = TextEditingController();
  final noTeleponController = TextEditingController();

  var selectedGender = RxnString();
  void setGender(String value) {
    selectedGender.value = value;
    jenisKelaminController.text = value;
  }

  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isLoading = false.obs;

  // Toggle Password Visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Toggle Password Visibility
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // Generate UID 
  String generateUID() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    final randomString = List.generate(28, (index) => chars[random.nextInt(chars.length)]).join();
    return randomString;
  }

  // Register User
  Future<bool> registerUser() async {
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Password dan konfirmasi tidak sama',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    isLoading.value = true;

    try {
      String uid = generateUID();
      bool success = await dbService.createUsers(
          uid: uid,
          name: usernameController.text,
          email: emailController.text,
          password: confirmPasswordController.text,
          gender: jenisKelaminController.text,
          phone: noTeleponController.text,
          photoUrl: "",
          status: 2
      );

      if (success) {
        clearFields();
        Get.snackbar(
          'Sukses',
          'Registrasi berhasil',
          snackPosition: SnackPosition.TOP,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Email sudah terdaftar',
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Clear Fields
  void clearFields() {
    usernameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    jenisKelaminController.clear();
    noTeleponController.clear();
    selectedGender.value = null;
  }

  @override
  void onClose() {
    // Dispose controllers to prevent memory leaks
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    jenisKelaminController.dispose();
    noTeleponController.dispose();
    super.onClose();
  }
}