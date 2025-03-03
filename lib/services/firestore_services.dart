import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService {
  final FirebaseFirestore _fire = FirebaseFirestore.instance;

  //register
  Future<void> createUsers({
    required String name,
    required String email,
    required String password,
    required int status,
  }) async {
    try {
      // Check if the user already exists
      QuerySnapshot existingUser = await _fire
          .collection("users")
          .where("email", isEqualTo: email)
          .get();

      if (existingUser.docs.isNotEmpty) {
        log("User with email $email already exists.");
        return; // Avoid creating a duplicate
      }

      // Add the user if not already existing
      await _fire.collection("users").add({
        "name": name,
        "email": email,
        "password": password,
        "status": status,
      });
      log("User created successfully: $name");
    } catch (e) {
      log("Error creating user: $e");
    }
  }

  //user
  Future<void> loadUserData(Function(String) updateUserName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    if (email != null) {
      final userDoc = await _fire
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      if (userDoc.docs.isNotEmpty) {
        updateUserName(userDoc.docs.first.data()['name'] ?? 'User');
      }
    }
  }

  // Future<List<QueryDocumentSnapshot>> readActiveUsers() async {
  //   try {
  //     QuerySnapshot querySnapshot =
  //         await _fire.collection("users").where("status", isEqualTo: 1).get();
  //     return querySnapshot.docs;
  //   } catch (e) {
  //     log(e.toString());
  //     return [];
  //   }
  // }
  //
  // //chat
  // Future<void> createChat({required String message}) async {
  //   try {
  //     await _fire
  //         .collection("chat")
  //         .add({"message": message, "time": FieldValue.serverTimestamp()});
  //   } catch (e) {
  //     log(e.toString());
  //   }
  // }

  Future<List<QueryDocumentSnapshot>> readChat() async {
    try {
      QuerySnapshot querySnapshot = await _fire.collection("chat").get();
      return querySnapshot.docs;
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  //complaint
  Future<void> createComplaint({
    required String namaPelapor,
    required String noTeleponPelapor,
    required String domisiliPelapor,
    required String jenisKelaminPelapor,
    required String jenisKekerasanSeksual,
    required String ceritaSingkatPeristiwa
  }) async {
   try{
     await _fire.collection("complaints").add({
       "namaPelapor": namaPelapor,
       "noTeleponPelapor": noTeleponPelapor,
       "domisiliPelapor": domisiliPelapor,
       "jenisKelaminPelapor": jenisKelaminPelapor,
       "jenisKekerasanSeksual": jenisKekerasanSeksual,
       "ceritaSingkatPeristiwa": ceritaSingkatPeristiwa,

     });
   }catch (e) {
     log(e.toString());
   }
  }

  Future<List<QueryDocumentSnapshot>> readComplaint() async {
    try {
      QuerySnapshot querySnapshot = await _fire.collection("complaints").get();
      return querySnapshot.docs;
    } catch (e) {
      log(e.toString());
      return [];
    }
  }
}
