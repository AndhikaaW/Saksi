import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../controllers/chat_controller.dart';
import 'dart:convert';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  ImageProvider? _getImageProvider(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return null;
    if (photoUrl.startsWith('http')) {
      return NetworkImage(photoUrl);
    }
    try {
      // Validasi base64: hanya decode jika string valid base64
      final base64String =
          photoUrl.replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '');
      // Cek apakah base64String hanya mengandung karakter base64 yang valid
      final isValidBase64 =
          RegExp(r'^[A-Za-z0-9+/=\s]+$').hasMatch(base64String);
      if (!isValidBase64) return null;
      return MemoryImage(base64Decode(base64String));
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade200,
        title: GestureDetector(
          onTap: () {
            // Tampilkan dialog dengan foto profil dan username
            showDialog(
              context: context,
              builder: (context) {
                final imageProvider =
                    _getImageProvider(controller.currentPhotoUrl);
                return AlertDialog(
                  backgroundColor: Colors.white,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.blueGrey.shade200,
                        backgroundImage: imageProvider,
                        child: (imageProvider == null)
                            ? Text(
                                (controller.currentAdminName != null &&
                                        controller.currentAdminName!.isNotEmpty)
                                    ? controller.currentAdminName![0]
                                        .toUpperCase()
                                    : '',
                                style: const TextStyle(
                                  fontSize: 36,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      // Tampilkan nama admin
                      Text(
                        controller.currentAdminName ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Tampilkan data diri lain dari user yang sedang login menggunakan Rx<UserProfile?>
                      Obx(() {
                        final userProfile = controller.userProfile.value;
                        if (userProfile == null) {
                          return Column(
                            children: const [
                              Icon(Icons.error_outline,
                                  color: Colors.red, size: 40),
                              SizedBox(height: 8),
                              Text(
                                'Data diri tidak ditemukan',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          );
                        }
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (userProfile.name != '')
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 90,
                                        child: const Text(
                                          'Nama',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        ': ',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Expanded(
                                        child: Text(
                                          userProfile.name,
                                          style: const TextStyle(fontSize: 16),
                                          softWrap: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (userProfile.email != '')
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        width: 90,
                                        child: const Text(
                                          'Email',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        ': ',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Expanded(
                                        child: Text(
                                          userProfile.email,
                                          style: const TextStyle(fontSize: 16),
                                          softWrap: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (userProfile.phone != '')
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        width: 90,
                                        child: Text(
                                          'No. HP',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        ': ',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Expanded(
                                        child: Text(
                                          userProfile.phone,
                                          style: const TextStyle(fontSize: 16),
                                          softWrap: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (userProfile.address != '')
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        width: 90,
                                        child: Text(
                                          'Alamat',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        ': ',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Expanded(
                                        child: Text(
                                          userProfile.address,
                                          style: const TextStyle(fontSize: 16),
                                          softWrap: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Tutup',
                          style: TextStyle(color: Colors.black)),
                    ),
                  ],
                );
              },
            );
          },
          child: Row(
            children: [
              Builder(
                builder: (context) {
                  final imageProvider =
                      _getImageProvider(controller.currentPhotoUrl);
                  return CircleAvatar(
                    radius: 25,
                    backgroundImage: imageProvider,
                    backgroundColor: (controller.currentPhotoUrl != null &&
                            controller.currentPhotoUrl!.isNotEmpty)
                        ? Colors.transparent
                        : Colors.blueGrey.shade200,
                    child: (imageProvider == null)
                        ? Text(
                            (controller.currentAdminName != null &&
                                    controller.currentAdminName!.isNotEmpty)
                                ? controller.currentAdminName![0].toUpperCase()
                                : '',
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  );
                },
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
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'delete_room') {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Hapus Room Chat'),
                    content: const Text(
                        'Apakah Anda yakin ingin menghapus room chat ini?'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          controller.deleteChatRoomPermanently(
                              controller.currentRoomId!);
                        },
                        child: const Text('Hapus Permanen'),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          controller
                              .deleteChatRoomForUser(controller.currentRoomId!);
                        },
                        child: const Text('Hapus untuk Saya'),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'delete_room',
                child: Text('Hapus Room Chat'),
              ),
            ],
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
                            Flexible(
                              child: GestureDetector(
                                onLongPress: () {
                                  Get.dialog(
                                    AlertDialog(
                                      title: const Text('Hapus Pesan'),
                                      content: const Text(
                                          'Apakah Anda yakin ingin menghapus pesan ini?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Get.back(),
                                          child: const Text('Batal'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Get.back();
                                            controller.deleteMessagePermanently(
                                                chatData['id']);
                                          },
                                          child: const Text('Hapus Permanen'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Get.back();
                                            controller.deleteMessageForUser(
                                                chatData['id']);
                                          },
                                          child: const Text('Hapus untuk Saya'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color:
                                        isMe ? Colors.blue[100] : Colors.white,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (!isMe)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 4.0),
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
                                                (chatData['time'] is Timestamp)
                                                    ? (chatData['time']
                                                            as Timestamp)
                                                        .toDate()
                                                    : (chatData['time']
                                                            is DateTime)
                                                        ? chatData['time']
                                                        : DateTime.now(),
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
                            ),
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
                          // prefixIcon: const Icon(Icons.emoji_emotions_outlined,
                          //     color: Colors.amber),
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
