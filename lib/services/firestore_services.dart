import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class DatabaseService {
  final FirebaseFirestore _fire = FirebaseFirestore.instance;

  //register
  Future<bool> createUsers({
    required String uid,
    required String name,
    required String email, 
    required String password,
    required String jenisKelamin,
    required String noTelepon,
    required int status,
  }) async {
    try {
      // Periksa apakah pengguna sudah ada
      QuerySnapshot existingUser = await _fire
          .collection("users")
          .where("email", isEqualTo: email)
          .get();

      if (existingUser.docs.isNotEmpty) {
        log("Pengguna dengan email $email sudah ada.");
        return false; // Hindari duplikasi
      }

      // Tambahkan pengguna jika belum ada
      await _fire.collection("users").doc(uid).set({
        "uid": uid,
        "name": name,
        "email": email,
        "password": password,
        "jenisKelamin": jenisKelamin,
        "noTelepon": noTelepon,
        "status": status,
        "createdAt": FieldValue.serverTimestamp(),
      });
      
      log("Pengguna berhasil dibuat: $name");
      return true;
    } catch (e) {
      log("Error membuat pengguna: $e");
      return false;
    }
  }

  //user
  // Future<void> loadUserData(Function(String) updateUserName) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? email = prefs.getString('email');
  //   if (email != null) {
  //     final userDoc = await _fire
  //         .collection('users')
  //         .where('email', isEqualTo: email)
  //         .get();
  //     if (userDoc.docs.isNotEmpty) {
  //       updateUserName(userDoc.docs.first.data()['name'] ?? 'User');
  //     }
  //   }
  // }

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

  // Future<List<QueryDocumentSnapshot>> readChat() async {
  //   try {
  //     QuerySnapshot querySnapshot = await _fire.collection("chat").get();
  //     return querySnapshot.docs;
  //   } catch (e) {
  //     log(e.toString());
  //     return [];
  //   }
  // }

  //complaint
  Future<void> createComplaint({
    // Existing fields
    required String uid,
    required String emailPelapor,
    required String namaPelapor,
    required String noTeleponPelapor,
    required String domisiliPelapor,
    required String jenisKelaminPelapor,
    required String jenisKekerasanSeksual,
    required String ceritaSingkatPeristiwa,
    required String keteranganDisabilitas,
    required String noTeleponPihakLain,
    required String statusTerlapor,
    required String jenisKelaminTerlapor,
    // New fields
    required String alasanPengaduan,
    String? alasanPengaduanLainnya,
    required String identifikasiKebutuhan,
    String? identifikasiKebutuhanLainnya,
  }) async {
    try {
      Map<String, dynamic> complaintData = {
        "uid": uid,
        "emailPelapor": emailPelapor,
        "namaPelapor": namaPelapor,
        "noTeleponPelapor": noTeleponPelapor,
        "domisiliPelapor": domisiliPelapor,
        "jenisKelaminPelapor": jenisKelaminPelapor,
        "jenisKekerasanSeksual": jenisKekerasanSeksual,
        "ceritaSingkatPeristiwa": ceritaSingkatPeristiwa,
        "keteranganDisabilitas": keteranganDisabilitas,
        "noTeleponPihakLain": noTeleponPihakLain,
        "statusTerlapor": statusTerlapor,
        "jenisKelaminTerlapor": jenisKelaminTerlapor,
        "tanggalPelaporan": FieldValue.serverTimestamp(),
        "statusPengaduan": 0
      };

      // For alasan pengaduan, combine into single field if "Lainnya" was selected
      if (alasanPengaduan == "Lainnya" && alasanPengaduanLainnya != null && alasanPengaduanLainnya.isNotEmpty) {
        complaintData["alasanPengaduan"] = "Lainnya: $alasanPengaduanLainnya";
      } else {
        complaintData["alasanPengaduan"] = alasanPengaduan;
      }

      // For identifikasi kebutuhan, combine into single field if "Lainnya" was selected
      if (identifikasiKebutuhan == "Lainnya" && identifikasiKebutuhanLainnya != null && identifikasiKebutuhanLainnya.isNotEmpty) {
        complaintData["identifikasiKebutuhan"] = "Lainnya: $identifikasiKebutuhanLainnya";
      } else {
        complaintData["identifikasiKebutuhan"] = identifikasiKebutuhan;
      }

      await _fire.collection("complaints").add(complaintData);
    } catch (e) {
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
