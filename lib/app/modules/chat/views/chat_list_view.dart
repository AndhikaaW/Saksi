import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../controllers/chat_controller.dart';
import 'dart:convert';

class ChatListView extends GetView<ChatController> {
  const ChatListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.put(ChatController());
    final storage = GetStorage();
    final userEmail = storage.read('email');

    return Scaffold(
       appBar: AppBar(
        title: const Text(
          "Chat",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.grey[100],
        child: Obx(() {
          if (controller.chatRooms.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.teal),
                  SizedBox(height: 16),
                  Text('Belum ada chat',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: controller.chatRooms.length,
            itemBuilder: (context, index) {
              var chatRoom = controller.chatRooms[index];
              var chatInfo = controller.getChatRoomInfo(chatRoom, userEmail!);

              return FutureBuilder<Map<String, dynamic>>(
                future: controller.getLastMessage(chatRoom['id']),
                builder: (context, messageSnapshot) {
                  String lastMessage = messageSnapshot.data?['message'] ??
                      "Ketuk untuk memulai chat";
                  String lastMessageTime = "";

                  if (messageSnapshot.data?['time'] != null) {
                    Timestamp timestamp =
                        messageSnapshot.data!['time'] as Timestamp;
                    DateTime messageDate = timestamp.toDate();
                    DateTime now = DateTime.now();

                    if (now.difference(messageDate).inDays == 0) {
                      lastMessageTime = DateFormat('HH:mm').format(messageDate);
                    } else if (now.difference(messageDate).inDays < 7) {
                      lastMessageTime =
                          DateFormat('EEEE', 'id_ID').format(messageDate);
                    } else {
                      lastMessageTime =
                          DateFormat('dd/MM/yy').format(messageDate);
                    }
                  }

                  // Ambil sender dari pesan terakhir
                  String? lastMessageSender = messageSnapshot.data?['sender'];
                  bool isFromCurrentUser = lastMessageSender == userEmail;
                  
                  // Gunakan unread count dari controller
                  int unreadCount = controller.getUnreadCount(chatRoom['id']);
                  bool hasUnreadMessages = unreadCount > 0;

                  return Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          // Dapatkan foto profil admin
                          QuerySnapshot adminSnapshot = await FirebaseFirestore
                              .instance
                              .collection('users')
                              .where('email', isEqualTo: chatInfo['userEmail'])
                              .limit(1)
                              .get();

                          String photoUrl = '';
                          if (adminSnapshot.docs.isNotEmpty) {
                            photoUrl = adminSnapshot.docs.first
                                    .get('photoUrl')
                                    ?.toString() ??
                                '';
                          }

                          controller.openChatRoom(
                            chatInfo['roomId'],
                            chatInfo['userName'],
                            photoUrl,
                            chatInfo['userEmail'],
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          color: Colors.white,
                          child: Row(
                            children: [
                              FutureBuilder<QuerySnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .where('email',
                                        isEqualTo: chatInfo['userEmail'])
                                    .limit(1)
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Colors.teal,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    );
                                  }

                                  String? photoUrl;
                                  if (snapshot.hasData &&
                                      snapshot.data!.docs.isNotEmpty) {
                                    photoUrl = snapshot.data!.docs.first
                                        .get('photoUrl')
                                        ?.toString();
                                  }

                                  // Inisialisasi imageProvider sesuai dengan file_context_0
                                  ImageProvider? imageProvider;
                                  if (photoUrl != null && photoUrl.isNotEmpty) {
                                    if (photoUrl.startsWith('http')) {
                                      imageProvider = NetworkImage(photoUrl);
                                    } else {
                                      try {
                                        final base64Str = photoUrl.replaceFirst(
                                            RegExp(r'data:image/[^;]+;base64,'), '');
                                        imageProvider = MemoryImage(base64Decode(base64Str));
                                      } catch (e) {
                                        imageProvider = null;
                                      }
                                    }
                                  }

                                  return CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.teal,
                                    backgroundImage: imageProvider,
                                    child: (imageProvider == null)
                                        ? Text(
                                            (chatInfo['userName'] ?? '-').toString().isNotEmpty
                                                ? (chatInfo['userName'] ?? '-')[0].toUpperCase()
                                                : '-',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                            ),
                                          )
                                        : null,
                                  );
                                },
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      chatInfo['userName'],
                                      style: TextStyle(
                                        fontWeight: hasUnreadMessages
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        // Tampilkan ikon centang jika pesan dari user saat ini
                                        if (isFromCurrentUser)
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.check,
                                                size: 16,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                            ],
                                          ),
                                        Expanded(
                                          child: Text(
                                            lastMessage,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: hasUnreadMessages
                                                  ? Colors.black
                                                  : Colors.grey[600],
                                              fontWeight: hasUnreadMessages
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (lastMessageTime.isNotEmpty)
                                    Text(
                                      lastMessageTime,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: hasUnreadMessages
                                            ? Colors.teal
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  // Badge untuk pesan yang belum dibaca
                                  // Jika ingin inisiasi unreadCount menggunakan stream agar otomatis fetch,
                                  // pastikan unreadCount diambil dari RxMap unreadCounts di controller yang sudah di-stream.
                                  // Contoh: unreadCounts[roomId] akan otomatis update jika ada perubahan di Firestore.
                                  Obx(() {
                                    final unread = controller.unreadCounts[chatRoom['id']] ?? 0;
                                    if (unread > 0)
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.teal,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 20,
                                          minHeight: 20,
                                        ),
                                        child: Text(
                                          unread > 99 ? '99+' : unread.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      );
                                    return const SizedBox.shrink();
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Divider antar item chat
                      Divider(
                        height: 1,
                        color: Colors.grey[300],
                        indent: 72,
                      ),
                    ],
                  );
                },
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/admin-contacts');
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}