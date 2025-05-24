import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';

class ChatController extends GetxController {
  final isLoading = true.obs;
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> chatRooms = <Map<String, dynamic>>[].obs;
  final TextEditingController messageController = TextEditingController();
  final storage = GetStorage();

  // Map untuk menyimpan jumlah pesan yang belum dibaca per chat room
  final RxMap<String, int> unreadCounts = <String, int>{}.obs;

  String? currentRoomId;
  String? currentAdminName;
  String? currentPhotoUrl;

  StreamSubscription<QuerySnapshot>? _chatSubscription;
  StreamSubscription<QuerySnapshot>? _chatRoomsSubscription;
  Map<String, StreamSubscription<QuerySnapshot>?> _unreadSubscriptions = {};
  StreamSubscription? _markReadSubscription;

  @override
  void onInit() {
    super.onInit();
    initializeDateFormatting('id_ID', null);

    final userEmail = storage.read('email');
    if (userEmail != null) {
      startChatRoomsStream();
      startNotificationCheck();
    }
  }

  @override
  void onReady() {
    super.onReady();
    if (Get.arguments != null && Get.arguments['roomId'] != null) {
      currentRoomId = Get.arguments['roomId'];
      currentAdminName = Get.arguments['adminName'];
      _startChatStream();
      // Tandai pesan sebagai sudah dibaca ketika membuka chat
      markMessagesAsRead(currentRoomId!);
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    _chatSubscription?.cancel();
    _chatRoomsSubscription?.cancel();
    // Cancel semua subscription untuk unread count
    _unreadSubscriptions.values
        .forEach((subscription) => subscription?.cancel());
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

  // Fungsi untuk menandai pesan sebagai sudah dibaca
  // Fungsi untuk menandai pesan sebagai sudah dibaca, sekarang dengan stream agar otomatis
  

  Future<void> markMessagesAsRead(String roomId) async {
    try {
      String? currentUserEmail = storage.read('email');
      if (currentUserEmail == null) return;

      // Cancel stream sebelumnya jika ada
      _markReadSubscription?.cancel();

      // Stream pesan yang belum dibaca dan bukan dari user saat ini
      _markReadSubscription = FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(roomId)
          .collection("messages")
          .where("isRead", isEqualTo: false)
          .where("sender", isNotEqualTo: currentUserEmail)
          .snapshots()
          .listen((QuerySnapshot unreadMessages) async {
        if (unreadMessages.docs.isEmpty) {
          // Reset unread count untuk room ini jika tidak ada pesan yang belum dibaca
          unreadCounts[roomId] = 0;
          unreadCounts.refresh();
          return;
        }

        WriteBatch batch = FirebaseFirestore.instance.batch();

        for (var doc in unreadMessages.docs) {
          batch.update(doc.reference, {"isRead": true});
        }

        await batch.commit();

        // Reset unread count untuk room ini
        unreadCounts[roomId] = 0;
        unreadCounts.refresh(); // Memaksa refresh UI
      });
    } catch (e) {
      print("Error marking messages as read: $e");
    }
  }

  // Fungsi untuk memulai stream unread count untuk setiap chat room
  void _startUnreadCountStream(String roomId) {
    String? currentUserEmail = storage.read('email');
    if (currentUserEmail == null) return;

    // Cancel existing subscription jika ada
    _unreadSubscriptions[roomId]?.cancel();

    _unreadSubscriptions[roomId] = FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(roomId)
        .collection("messages")
        .where("isRead", isEqualTo: false)
        .where("sender", isNotEqualTo: currentUserEmail)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      unreadCounts[roomId] = snapshot.docs.length;
      unreadCounts.refresh(); // Memaksa refresh UI
    }, onError: (error) {
      print("Error dalam stream unread count untuk $roomId: $error");
    });
  }

  Future<List<QueryDocumentSnapshot>> readActiveAdmins() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("status", whereIn: [0, 1]).get();
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

  Future<void> createChatRoom(
      String adminName, String adminUid, String? photoUrl) async {
    try {
      String? email = storage.read('email');
      int? status = storage.read('userStatus');

      if (email == null || status != 2) {
        throw Exception("User not logged in or not authorized");
      }

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

      currentRoomId = roomId;
      currentAdminName = adminName;
      currentPhotoUrl = photoUrl;

      Get.toNamed('/chat', arguments: {
        'roomId': roomId,
        'adminName': adminName,
      });
      _startChatStream();
      // Tandai pesan sebagai sudah dibaca ketika membuka chat
      markMessagesAsRead(roomId);
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

  Future<void> sendMessage(String message) async {
    try {
      if (message.isEmpty || currentRoomId == null) return;

      String email = storage.read('email');
      String username = await getUsernameFromEmail(email);

      // Simpan pesan ke Firestore dengan status isRead: false
      await FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(currentRoomId)
          .collection("messages")
          .add({
        "message": message,
        "sender": email,
        "senderName": username,
        "time": FieldValue.serverTimestamp(),
        "isRead": false, // Tambahkan field untuk tracking read status
      });
      messageController.clear();

      await FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(currentRoomId)
          .update({"lastUpdated": FieldValue.serverTimestamp()});

      await _sendNotificationToOtherUser(message, username);
    } catch (e) {
      print("Error sending message: $e");
      Get.snackbar(
        'Error',
        'Gagal mengirim pesan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _sendNotificationToOtherUser(
      String message, String senderName) async {
    try {
      DocumentSnapshot chatRoomDoc = await FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(currentRoomId)
          .get();

      if (!chatRoomDoc.exists) return;

      Map<String, dynamic> chatRoomData =
          chatRoomDoc.data() as Map<String, dynamic>;
      List<dynamic> users = chatRoomData['users'];

      String currentUserEmail = storage.read('email');
      String otherUserEmail =
          users.firstWhere((email) => email != currentUserEmail);

      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: otherUserEmail)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) return;

      await FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(currentRoomId)
          .collection("notifications")
          .add({
        "message": message,
        "sender": currentUserEmail,
        "senderName": senderName,
        "recipient": otherUserEmail,
        "time": FieldValue.serverTimestamp(),
        "isRead": false,
      });
    } catch (e) {
      print('Error in _sendNotificationToOtherUser: $e');
    }
  }

  void startNotificationCheck() {
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        String? email = storage.read('email');
        if (email == null) return;

        QuerySnapshot chatRooms = await FirebaseFirestore.instance
            .collection("chatRooms")
            .where("users", arrayContains: email)
            .get();

        for (var chatRoom in chatRooms.docs) {
          QuerySnapshot unreadNotifications = await FirebaseFirestore.instance
              .collection("chatRooms")
              .doc(chatRoom.id)
              .collection("notifications")
              .where("recipient", isEqualTo: email)
              .where("isRead", isEqualTo: false)
              .orderBy("time", descending: true)
              .limit(1)
              .get();

          if (unreadNotifications.docs.isNotEmpty) {
            var notification =
                unreadNotifications.docs.first.data() as Map<String, dynamic>;

            List<dynamic> userNames =
                chatRoom.get("userNames") as List<dynamic>;
            List<dynamic> users = chatRoom.get("users") as List<dynamic>;
            int currentUserIndex = users.indexOf(email);
            String adminName = userNames[currentUserIndex == 0 ? 1 : 0];

            await AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
                channelKey: 'chat_channel',
                title: 'Pesan baru dari ${notification['senderName']}',
                body: notification['message'],
                notificationLayout: NotificationLayout.Default,
                category: NotificationCategory.Message,
                wakeUpScreen: true,
                fullScreenIntent: false,
                criticalAlert: false,
                payload: {
                  'roomId': chatRoom.id,
                  'adminName': adminName,
                },
              ),
              actionButtons: [
                NotificationActionButton(
                  key: 'REPLY',
                  label: 'Balas',
                  actionType: ActionType.SilentAction,
                ),
                NotificationActionButton(
                  key: 'OPEN',
                  label: 'Buka Chat',
                  actionType: ActionType.SilentAction,
                ),
              ],
            );

            await FirebaseFirestore.instance
                .collection("chatRooms")
                .doc(chatRoom.id)
                .collection("notifications")
                .doc(unreadNotifications.docs.first.id)
                .update({"isRead": true});
          }
        }
      } catch (e) {
        print('Error checking notifications: $e');
      }
    });
  }

  void startChatRoomsStream() {
    final userEmail = storage.read('email');
    if (userEmail == null) return;

    print("Memulai stream chat rooms untuk: $userEmail");

    _chatRoomsSubscription?.cancel();
    _chatRoomsSubscription = FirebaseFirestore.instance
        .collection("chatRooms")
        .where("users", arrayContains: userEmail)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      chatRooms.clear();
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        chatRooms.add({
          'id': doc.id,
          ...data,
        });
        // Mulai stream unread count untuk setiap chat room
        _startUnreadCountStream(doc.id);
      }

      chatRooms.sort((a, b) {
        Timestamp? timeA = a['lastUpdated'] as Timestamp?;
        Timestamp? timeB = b['lastUpdated'] as Timestamp?;

        if (timeA == null && timeB == null) return 0;
        if (timeA == null) return 1;
        if (timeB == null) return -1;

        return timeB.compareTo(timeA);
      });

      chatRooms.refresh();
    }, onError: (error) {
      print("Error dalam stream chat rooms: $error");
      Get.snackbar(
        'Error',
        'Gagal memuat daftar chat: $error',
        snackPosition: SnackPosition.BOTTOM,
      );
    });
  }

  Map<String, dynamic> getChatRoomInfo(
      Map<String, dynamic> chatRoom, String adminEmail) {
    var users = List<String>.from(chatRoom['users'] ?? []);
    var userNames = List<String>.from(chatRoom['userNames'] ?? []);

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
      print(
          "Index pengguna tidak valid: $userIndex, users length: ${users.length}, userNames length: ${userNames.length}");
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
        };
      }

      var lastMessageData =
          messageSnapshot.docs.first.data() as Map<String, dynamic>;
      return {
        'message': lastMessageData['message'] ?? "Belum ada pesan",
        'time': lastMessageData['time'],
        'sender': lastMessageData['sender'],
        'isRead': lastMessageData['isRead'] ?? true,
      };
    } catch (e) {
      print("Error mendapatkan pesan terakhir: $e");
      return {
        'message': "Error memuat pesan",
        'time': "",
      };
    }
  }

  Future<Map<String, dynamic>> getLastMessageForAdmin(
      String adminEmail, String? userEmail) async {
    try {
      QuerySnapshot roomSnapshot = await FirebaseFirestore.instance
          .collection("chatRooms")
          .where("users", arrayContains: userEmail)
          .get();

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

  void openChatRoom(String roomId, String userName, String photoUrl) {
    currentRoomId = roomId;
    currentAdminName = userName;
    currentPhotoUrl = photoUrl;
    _startChatStream();
    markMessagesAsRead(roomId);

    Get.toNamed('/chat', arguments: {
      'roomId': roomId,
      'adminName': userName,
      'photoUrl': photoUrl,
    });
    unreadCounts.refresh();
  }

  // Fungsi helper untuk mendapatkan unread count
  int getUnreadCount(String roomId) {
    return unreadCounts[roomId] ?? 0;
  }
}
