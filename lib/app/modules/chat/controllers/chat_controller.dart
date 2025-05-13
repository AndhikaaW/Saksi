import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class ChatController extends GetxController {
  final isLoading = true.obs;
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> chatRooms = <Map<String, dynamic>>[].obs;
  final TextEditingController messageController = TextEditingController();
  final storage = GetStorage();

  String? currentRoomId;
  String? currentAdminName;
  StreamSubscription<QuerySnapshot>? _chatSubscription;
  StreamSubscription<QuerySnapshot>? _chatRoomsSubscription;

  @override
  void onInit() {
    super.onInit();
    // Mulai mendengarkan chat rooms saat controller diinisialisasi
    final userEmail = storage.read('email');
    if (userEmail != null) {
      startChatRoomsStream();
    }
  }

  @override
  void onReady() {
    super.onReady();
    // Periksa apakah ada argumen roomId saat navigasi
    if (Get.arguments != null && Get.arguments['roomId'] != null) {
      currentRoomId = Get.arguments['roomId'];
      currentAdminName = Get.arguments['adminName'];
      _startChatStream();
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    _chatSubscription?.cancel();
    _chatRoomsSubscription?.cancel();
    super.onClose();
  }

  void _startChatStream() {
    if (currentRoomId == null) return;

    isLoading.value = true;
    _chatSubscription?.cancel();

    _chatSubscription = FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(currentRoomId)
        .collection("messages")
        .orderBy("time", descending: true)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      messages.clear();
      for (var doc in snapshot.docs) {
        messages.add({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }
      isLoading.value = false;
      // Memastikan UI diperbarui
      messages.refresh();
      
     
    }, onError: (error) {
      print("Error dalam stream chat: $error");
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Gagal memuat pesan: $error',
        snackPosition: SnackPosition.BOTTOM,
      );
    });
  }

  Future<List<QueryDocumentSnapshot>> readActiveAdmins() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("status", isEqualTo: 1)
          .get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  String generateChatRoomId(String user1, String user2) {
    if (user1.compareTo(user2) > 0) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  Future<void> createChatRoom(String adminName, String adminUid) async {
    try {
      String? email = storage.read('email');
      int? status = storage.read('userStatus');

      if (email == null || status != 2) {
        throw Exception("User not logged in or not authorized");
      }

      // Dapatkan nama pengguna dari Firestore berdasarkan email
      String username = await getUsernameFromEmail(email);

      String roomId = generateChatRoomId(email, adminUid);

      DocumentReference chatRoomRef =
          FirebaseFirestore.instance.collection("chatRooms").doc(roomId);

      DocumentSnapshot chatRoomSnapshot = await chatRoomRef.get();

      if (!chatRoomSnapshot.exists) {
        await chatRoomRef.set({
          "roomId": roomId,
          "users": [email, adminUid],
          "userNames": [username, adminName],
          "createdAt": FieldValue.serverTimestamp(),
          "lastUpdated": FieldValue.serverTimestamp(),
        });
      }

      // Simpan data terlebih dahulu ke variabel lokal
      currentRoomId = roomId;
      currentAdminName = adminName;

      // Kemudian navigasi dengan arguments
      Get.toNamed('/chat', arguments: {
        'roomId': roomId,
        'adminName': adminName,
      });
      _startChatStream();
    } catch (e) {
      print("Error creating chat room: $e");
      Get.snackbar(
        'Error',
        'Gagal membuat ruang chat: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<String> getUsernameFromEmail(String email) async {
    try {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: email)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        return userSnapshot.docs.first.get("name") as String;
      } else {
        return "User";
      }
    } catch (e) {
      print("Error getting username: $e");
      return "User";
    }
  }

  // Future<List<QueryDocumentSnapshot>> loadChatHistory() async {
  //   try {
  //     if (currentRoomId == null) return [];

  //     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //         .collection("chatRooms")
  //         .doc(currentRoomId)
  //         .collection("messages")
  //         .orderBy("time", descending: true)
  //         .get();
  //     return querySnapshot.docs;
  //   } catch (e) {
  //     print("Error fetching messages: $e");
  //     return [];
  //   }
  // }

  Future<void> sendMessage(String message) async {
    try {
      if (message.isEmpty || currentRoomId == null) return;

      String email = storage.read('email');
      String username = await getUsernameFromEmail(email);

      await FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(currentRoomId)
          .collection("messages")
          .add({
        "message": message,
        "sender": email,
        "senderName": username,
        "time": FieldValue.serverTimestamp(),
      });

      // Update lastUpdated pada chatRoom
      await FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(currentRoomId)
          .update({"lastUpdated": FieldValue.serverTimestamp()});

      messageController.clear();
      // Tidak perlu memanggil _startChatStream() karena stream akan otomatis memperbarui data
    } catch (e) {
      print("Error sending message: $e");
      Get.snackbar(
        'Error',
        'Gagal mengirim pesan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Fungsi untuk memulai stream chat rooms untuk admin
  void startChatRoomsStream() {
    final adminEmail = storage.read('email');
    if (adminEmail == null) return;

    print("Memulai stream chat rooms untuk: $adminEmail");

    _chatRoomsSubscription?.cancel();
    _chatRoomsSubscription = FirebaseFirestore.instance
        .collection("chatRooms")
        .where("users", arrayContains: adminEmail)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      chatRooms.clear();
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        chatRooms.add({
          'id': doc.id,
          ...data,
        });
        print("Chat room ditemukan: ${doc.id}");
      }
      
      // Urutkan berdasarkan lastUpdated jika tersedia
      chatRooms.sort((a, b) {
        Timestamp? timeA = a['lastUpdated'] as Timestamp?;
        Timestamp? timeB = b['lastUpdated'] as Timestamp?;
        
        if (timeA == null && timeB == null) return 0;
        if (timeA == null) return 1;
        if (timeB == null) return -1;
        
        return timeB.compareTo(timeA); // Descending order
      });
      
      chatRooms.refresh();
      print("Total chat rooms: ${chatRooms.length}");
    }, onError: (error) {
      print("Error dalam stream chat rooms: $error");
      Get.snackbar(
        'Error',
        'Gagal memuat daftar chat: $error',
        snackPosition: SnackPosition.BOTTOM,
      );
    });
  }

  // Fungsi untuk mendapatkan informasi chat room
  Map<String, dynamic> getChatRoomInfo(
      Map<String, dynamic> chatRoom, String adminEmail) {
    var users = List<String>.from(chatRoom['users'] ?? []);
    var userNames = List<String>.from(chatRoom['userNames'] ?? []);

    // Cari user yang bukan admin
    int adminIndex = users.indexOf(adminEmail);
    if (adminIndex == -1) {
      print("Admin email tidak ditemukan dalam daftar users: $adminEmail");
      return {
        'userName': 'Unknown User',
        'userEmail': 'unknown@email.com',
        'roomId': chatRoom['id'],
      };
    }
    
    int userIndex = adminIndex == 0 ? 1 : 0;
    if (userIndex >= users.length || userIndex >= userNames.length) {
      print("Index pengguna tidak valid: $userIndex, users length: ${users.length}, userNames length: ${userNames.length}");
      return {
        'userName': 'Unknown User',
        'userEmail': 'unknown@email.com',
        'roomId': chatRoom['id'],
      };
    }
    
    String userName = userNames[userIndex];
    String userEmail = users[userIndex];

    return {
      'userName': userName,
      'userEmail': userEmail,
      'roomId': chatRoom['id'],
    };
  }

  // Fungsi untuk mendapatkan pesan terakhir dari chat room
  Future<Map<String, dynamic>> getLastMessage(String roomId) async {
    try {
      QuerySnapshot messageSnapshot = await FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(roomId)
          .collection("messages")
          .orderBy("time", descending: true)
          .limit(1)
          .get();

      if (messageSnapshot.docs.isEmpty) {
        return {
          'message': "Belum ada pesan",
          'time': "",
        };
      }

      var lastMessageData =
          messageSnapshot.docs.first.data() as Map<String, dynamic>;
      return {
        'message': lastMessageData['message'] ?? "Belum ada pesan",
        'time': lastMessageData['time'],
      };
    } catch (e) {
      print("Error mendapatkan pesan terakhir: $e");
      return {
        'message': "Error memuat pesan",
        'time': "",
      };
    }
  }
  
  // Fungsi untuk mendapatkan pesan terakhir untuk admin tertentu dari sisi user
  Future<Map<String, dynamic>> getLastMessageForAdmin(String adminEmail, String? userEmail) async {
    try {
      // Cari chat room antara user dan admin
      QuerySnapshot roomSnapshot = await FirebaseFirestore.instance
          .collection("chatRooms")
          .where("users", arrayContains: userEmail)
          .get();
      
      // Filter untuk mendapatkan room yang berisi admin yang dipilih
      String? roomId;
      for (var doc in roomSnapshot.docs) {
        List<dynamic> users = doc['users'];
        if (users.contains(adminEmail)) {
          roomId = doc.id;
          break;
        }
      }
      
      if (roomId == null) {
        return {
          'message': "Belum ada pesan",
          'time': null,
        };
      }
      
      // Dapatkan pesan terakhir dari room tersebut
      QuerySnapshot messageSnapshot = await FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(roomId)
          .collection("messages")
          .orderBy("time", descending: true)
          .limit(1)
          .get();

      if (messageSnapshot.docs.isEmpty) {
        return {
          'message': "Belum ada pesan",
          'time': null,
        };
      }

      var lastMessageData =
          messageSnapshot.docs.first.data() as Map<String, dynamic>;
      return {
        'message': lastMessageData['message'] ?? "Belum ada pesan",
        'time': lastMessageData['time'],
      };
    } catch (e) {
      print("Error mendapatkan pesan terakhir untuk admin: $e");
      return {
        'message': "Error memuat pesan",
        'time': null,
      };
    }
  }

  // Fungsi untuk membuka chat room
  void openChatRoom(String roomId, String userName) {
    currentRoomId = roomId;
    currentAdminName = userName;
    _startChatStream();
    
    Get.toNamed('/chat', arguments: {
      'roomId': roomId,
      'adminName': userName,
    });
  }
}
