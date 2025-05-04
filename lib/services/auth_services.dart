import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Login pengguna berdasarkan email dan password.
  /// Mengembalikan Map dengan kunci 'isSuccess' dan 'status'.
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      // Cari pengguna berdasarkan email dan password
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Ambil dokumen pengguna
        final userDoc = querySnapshot.docs.first;
        final userData = userDoc.data();

        // Periksa apakah data pengguna memiliki field 'status'
        if (userData.containsKey('status')) {
          log("Login successful for $email with status ${userData['status']}");

          // Kembalikan hasil login dengan informasi status
          return {
            'isSuccess': true,
            'status': userData['status'], // 1: admin, 2: user, dll.
            'uid': userData['uid']
          };
        } else {
          log("User data missing 'status' field");
          return {
            'isSuccess': false,
            'message': "User status not found",
          };
        }
      } else {
        log("email atau password salah");
        return {
          'isSuccess': false,
          'message': "Invalid email or password",
        };
      }
    } catch (e) {
      log("Error during login: $e");
      return {
        'isSuccess': false,
        'message': "An error occurred during login",
      };
    }
  }
}
