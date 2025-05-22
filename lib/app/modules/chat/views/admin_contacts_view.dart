import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/chat_controller.dart';

class AdminContactsView extends GetView<ChatController> {
  const AdminContactsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.put(ChatController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kontak Admin"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[100],
        child: FutureBuilder<List<QueryDocumentSnapshot>>(
          future: controller.readActiveAdmins(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.teal));
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_outline, size: 64, color: Colors.teal),
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

                return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  color: Colors.white,
                  child: InkWell(
                    onTap: () => controller.createChatRoom(
                        adminName, adminEmail, photoUrl),
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
                                    errorBuilder:
                                        (context, error, stackTrace) => Text(
                                      adminName.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 22),
                                    ),
                                  ),
                                )
                              : Text(
                                  adminName.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 22),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                adminName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Admin",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.teal,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
