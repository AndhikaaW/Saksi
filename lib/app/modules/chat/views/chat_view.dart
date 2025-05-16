import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: controller.currentPhotoUrl != null &&
                      controller.currentPhotoUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        controller.currentPhotoUrl!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Text(
                          controller.currentAdminName
                                  ?.substring(0, 1)
                                  .toUpperCase() ??
                              'A',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  : Text(
                      controller.currentAdminName
                              ?.substring(0, 1)
                              .toUpperCase() ??
                          'A',
                      style: const TextStyle(color: Colors.white),
                    ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.currentAdminName.toString(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                // const Text(
                //   "Online",
                //   style: TextStyle(fontSize: 12),
                // ),
              ],
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
        // backgroundColor: Colors.blueGrey,
      ),
      body: Container(
        // decoration: const BoxDecoration(
        //   image: DecorationImage(
        //     image: AssetImage('assets/logoPoltek.png'),
        //     fit: BoxFit.cover,
        //     opacity: 0.1,
        //   ),
        // ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Chat messages list
              Expanded(
                child: Obx(() {
                  // if (controller.isLoading.value) {
                  //   return const Center(child: CircularProgressIndicator());
                  // }

                  if (controller.messages.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Belum ada pesan',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    reverse: true,
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      var chatData = controller.messages[index];
                      bool isMe = chatData['sender'] ==
                          controller.storage.read('email');

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: isMe
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            // if (!isMe)
                            //   ClipOval(
                            //     child: Image.network(
                            //       controller.currentPhotoUrl!,
                            //       width: 40,
                            //       height: 40,
                            //       fit: BoxFit.cover,
                            //       errorBuilder: (context, error, stackTrace) =>
                            //           Text(
                            //         controller.currentAdminName
                            //                 ?.substring(0, 1)
                            //                 .toUpperCase() ??
                            //             'A',
                            //         style: const TextStyle(color: Colors.white),
                            //       ),
                            //     ),
                            //   ),
                            // const SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isMe ? Colors.blue[100] : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!isMe)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 4.0),
                                        child: Text(
                                          chatData['senderName'] ?? 'Unknown',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    Text(
                                      chatData['message'],
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      chatData['time'] != null
                                          ? DateFormat('dd/MM/yyyy HH:mm')
                                              .format(
                                              (chatData['time'] as Timestamp)
                                                  .toDate(),
                                            )
                                          : '',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // const SizedBox(width: 8),
                            // if (isMe)
                            //   CircleAvatar(
                            //     radius: 20,
                            //     backgroundColor: Colors.blue,
                            //     child: Text(
                            //       chatData['senderName']?.substring(0, 1).toUpperCase() ?? 'A',
                            //       style: const TextStyle(color: Colors.white),
                            //     ),
                            //   )
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
              // Message input and send button
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  // color: Colors.blueGrey,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, -2),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.messageController,
                        decoration: InputDecoration(
                          hintText: 'Ketik pesan...',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          prefixIcon: const Icon(Icons.emoji_emotions_outlined,
                              color: Colors.amber),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(24),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () async {
                          String message =
                              controller.messageController.text.trim();
                          if (message.isNotEmpty) {
                            await controller.sendMessage(message);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          child: const Icon(Icons.send, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
