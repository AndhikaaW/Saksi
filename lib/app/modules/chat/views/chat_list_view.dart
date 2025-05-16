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
        title: const Text("Chat"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.search),
        //     onPressed: () {},
        //   ),
        //   IconButton(
        //     icon: const Icon(Icons.more_vert),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: Container(
        color: Colors.grey[100],
        child: FutureBuilder<List<QueryDocumentSnapshot>>(
          future: controller.readActiveAdmins(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.teal));
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 64, color: Colors.teal),
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
                String? photoUrl = adminData['photoUrl']?.toString();

                return FutureBuilder<Map<String, dynamic>>(
                  future: controller.getLastMessageForAdmin(adminEmail, userEmail),
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

                    return Column(
                      children: [
                        InkWell(
                          onTap: () => controller.createChatRoom(adminName, adminEmail, photoUrl),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            color: Colors.white,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.teal,
                                  child: photoUrl != null && photoUrl.isNotEmpty
                                      ? ClipOval(
                                          child: Image.network(
                                            photoUrl,
                                            width: 56,
                                            height: 56,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Text(
                                              adminName.substring(0, 1).toUpperCase(),
                                              style: const TextStyle(color: Colors.white, fontSize: 22),
                                            ),
                                          ),
                                        )
                                      : Text(
                                          adminName.substring(0, 1).toUpperCase(),
                                          style: const TextStyle(color: Colors.white, fontSize: 22),
                                        ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        adminName,
                                        style: TextStyle(
                                          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          if (messageSnapshot.data?['sender'] == userEmail)
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
                                    if (isUnread)
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
                        // if (index < snapshot.data!.length - 1)
                        //   const Divider(height: 1, indent: 72, endIndent: 0, color: Colors.grey),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   backgroundColor: Colors.teal,
      //   child: const Icon(Icons.chat, color: Colors.white),
      // ),
    );
  }
}
