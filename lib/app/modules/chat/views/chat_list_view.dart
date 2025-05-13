import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../controllers/chat_controller.dart';

class ChatListView extends GetView<ChatController> {
  const ChatListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Pastikan controller sudah diinisialisasi
    final ChatController controller = Get.put(ChatController());
    final storage = GetStorage();
    final userEmail = storage.read('email');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Admin"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: controller.readActiveAdmins(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Tidak ada admin tersedia',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var adminData =
                  snapshot.data![index].data() as Map<String, dynamic>;
              String adminName = adminData['name'];
              String adminEmail = adminData['email'];

              return FutureBuilder<Map<String, dynamic>>(
                future: controller.getLastMessageForAdmin(adminEmail, userEmail),
                builder: (context, messageSnapshot) {
                  String lastMessage =
                      messageSnapshot.data?['message'] ?? "Belum ada pesan";
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
                          adminName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        adminName,
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
                      onTap: () => controller.createChatRoom(adminName, adminEmail),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
