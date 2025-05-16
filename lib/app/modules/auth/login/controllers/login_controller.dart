import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:saksi_app/app/routes/app_pages.dart';
import 'package:saksi_app/services/auth_services.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isPasswordVisible = false.obs;
  final isLoading = false.obs;
  final isLoadinggoogle = false.obs;

  final AuthService authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final box = GetStorage();

  Rx<User?> firebaseUser = Rx<User?>(null);

  // Toggle Password Visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// Login dengan Email & Password
  Future<void> login() async {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Email dan password harus diisi',
          snackPosition: SnackPosition.TOP);
      return;
    }

    isLoading.value = true;
    final result = await authService.login(email, password);
    isLoading.value = false;

    if (result != null && result['isSuccess'] == true) {
      final userStatus = result['status'];
      final uid = result['uid'];

      await box.write('isLoggedIn', true);
      await box.write('email', email);
      await box.write('userStatus', userStatus);
      await box.write('uid', uid);

      if (userStatus == 0) {
        Get.offAllNamed(Routes.DASHBOARD_SUPERADMIN);
      } else if (userStatus == 1) {
        Get.offAllNamed(Routes.DASHBOARD_ADMIN);
      } else if (userStatus == 2) {
        Get.offAllNamed(Routes.DASHBOARD_USER);
      }
    } else {
      Get.snackbar('Error', 'Login gagal', snackPosition: SnackPosition.TOP);
    }
  }

  /// Login dengan Google
  Future<bool> loginWithGoogle() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      // Hanya untuk Android & iOS
      if (GetPlatform.isAndroid || GetPlatform.isIOS) {
        await _googleSignIn
            .signOut(); // Logout sebelumnya untuk memastikan fresh login

        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          print('User membatalkan proses sign in');
          return false;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        User? user = userCredential.user;

        if (user != null) {
          await saveUserToFirestore(user);
          return true;
        } else {
          print('Authentication Error');
          return false;
        }
      } else {
        print('Platform tidak didukung');
        return false;
      }
    } catch (e) {
      print('Error dalam signInWithGoogle: $e');
      return false;
    }
  }

  // Simpan user ke firestore 
  Future<void> saveUserToFirestore(User user) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(user.uid).get();

    if (!userDoc.exists) {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
        'phone': user.phoneNumber ?? '',
        'status': 2,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // Setelah menyimpan, lanjut ke pengecekan user dan navigasi ke dashboard
    await checkUserAndNavigate(user.uid);
  }

  // Pengecekan user dan navigasi ke dashboard
  Future<void> checkUserAndNavigate(String uid) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(uid).get();

    if (userDoc.exists) {
      final userStatus = userDoc['status'];
      final email = userDoc['email'];

      // Simpan informasi user di local storage
      await box.write('isLoggedIn', true);
      await box.write('email', email);
      await box.write('userStatus', userStatus);
      await box.write('uid', uid);

      // Tambahkan kondisi untuk superadmin (status 0)
      if (userStatus == 0) {
        Get.offAllNamed(Routes.DASHBOARD_SUPERADMIN);
      } else if (userStatus == 1) {
        Get.offAllNamed(Routes.DASHBOARD_ADMIN);
      } else if (userStatus == 2) {
        Get.offAllNamed(Routes.DASHBOARD_USER);
      }
    } else {
      Get.snackbar('Error', 'User tidak ditemukan di database',
          snackPosition: SnackPosition.TOP);
    }
  }

}
