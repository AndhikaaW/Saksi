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
      appBar: AppBar(
        title: const Text('Daftar Chat'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.chatRooms.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
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
                    messageSnapshot.data?['message'] ?? "";
                String lastMessageTime = "";

                if (messageSnapshot.data?['time'] != null) {
                  lastMessageTime = DateFormat('dd/MM/yyyy HH:mm').format(
                      (messageSnapshot.data!['time'] as Timestamp).toDate());
                }

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        chatInfo['userName'].substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      chatInfo['userName'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (lastMessageTime.isNotEmpty)
                          Text(
                            lastMessageTime,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                    onTap: () => controller.openChatRoom(
                      chatInfo['roomId'],
                      chatInfo['userName'],
                    ),
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }
}
