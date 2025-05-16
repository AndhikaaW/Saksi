import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../controllers/chat_controller.dart';

class ChatListViewAdmin extends GetView<ChatController> {
  const ChatListViewAdmin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Pastikan controller sudah diinisialisasi
    final ChatController controller = Get.put(ChatController());
    final storage = GetStorage();
    final adminEmail = storage.read('email');

    // Mulai stream chat rooms saat view dibangun
    controller.startChatRoomsStream();

    return Scaffold(
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
              var chatInfo = controller.getChatRoomInfo(chatRoom, adminEmail!);

              return FutureBuilder<Map<String, dynamic>>(
                future: controller.getLastMessage(chatRoom['id']),
                builder: (context, messageSnapshot) {
                  String lastMessage =
                      messageSnapshot.data?['message'] ?? "Ketuk untuk memulai chat";
                  String lastMessageTime = "";

                  if (messageSnapshot.data?['time'] != null) {
                    Timestamp timestamp = messageSnapshot.data!['time'] as Timestamp;
                    DateTime messageDate = timestamp.toDate();
                    DateTime now = DateTime.now();
                    
                    if (now.difference(messageDate).inDays == 0) {
                      // Hari ini, tampilkan jam saja
                      lastMessageTime = DateFormat('HH:mm').format(messageDate);
                    } else if (now.difference(messageDate).inDays < 7) {
                      // Minggu ini, tampilkan nama hari
                      lastMessageTime = DateFormat('EEEE', 'id_ID').format(messageDate);
                    } else {
                      // Lebih dari seminggu, tampilkan tanggal
                      lastMessageTime = DateFormat('dd/MM/yy').format(messageDate);
                    }
                  }

                  bool isUnread = messageSnapshot.data?['isUnread'] ?? false;
                  String senderEmail = messageSnapshot.data?['sender'] ?? "";
                  bool isFromAdmin = senderEmail == adminEmail;

                  return Column(
                    children: [
                      InkWell(
                        onTap: () => controller.openChatRoom(
                          chatInfo['roomId'],
                          chatInfo['userName'],
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          color: Colors.white,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.teal,
                                child: Text(
                                  chatInfo['userName'].substring(0, 1).toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontSize: 22),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      chatInfo['userName'],
                                      style: TextStyle(
                                        fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        if (isFromAdmin)
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
                                              color: isUnread ? Colors.black : Colors.grey[600],
                                              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
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
                                        color: isUnread ? Colors.teal : Colors.grey[600],
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  if (isUnread && !isFromAdmin)
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Colors.teal,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Text(
                                        "1",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        }),
      ),
    );
  }
}
