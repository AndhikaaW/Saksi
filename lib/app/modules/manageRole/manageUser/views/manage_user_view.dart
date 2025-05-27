import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/manage_user_controller.dart';

class ManageUserView extends GetView<ManageUserController> {
  const ManageUserView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pengguna',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search TextField
            TextField(
              onChanged: (value) => controller.searchUser(value),
              decoration: InputDecoration(
                hintText: 'Cari pengguna...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Menggunakan users jika filteredUsers kosong
                final displayedUsers = controller.filteredUsers.isEmpty ? 
                  controller.users : controller.filteredUsers;

                if (displayedUsers.isEmpty) {
                  return const Center(child: Text('Tidak ada pengguna'));
                }

                return ListView.builder(
                  itemCount: displayedUsers.length,
                  itemBuilder: (context, index) {
                    final user = displayedUsers[index];
                    return InkWell(
                      onTap: () {
                        // Tampilkan dialog dengan data pengguna
                        Get.defaultDialog(
                          title: 'Detail Pengguna',
                          backgroundColor: Colors.white,
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.white,
                                backgroundImage: user['photoUrl'] != null && user['photoUrl'].isNotEmpty
                                    ? (
                                        user['photoUrl'].toString().startsWith('http')
                                            ? NetworkImage(user['photoUrl'])
                                            : MemoryImage(
                                                base64Decode(
                                                  user['photoUrl']
                                                      .toString()
                                                      .replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '')
                                                )
                                              ) as ImageProvider
                                      )
                                    : null,
                                child: (user['photoUrl'] == null || user['photoUrl'].isEmpty)
                                    ? Text(
                                        (user['name'] != null && user['name'].toString().isNotEmpty)
                                            ? user['name'].toString()[0].toUpperCase()
                                            : '',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          color: Colors.blueGrey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                user['name'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                user['email'] ?? '-',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                user['status'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              // Tambahkan data lain jika ada, misal nomor telepon, dsb.
                            ],
                          ),
                          textConfirm: 'Tutup',
                          confirmTextColor: Colors.white,
                          onConfirm: () {
                            Get.back();
                          },
                        );
                      },
                      child: Card(
                        color: Colors.white,
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white,
                            backgroundImage: user['photoUrl'] != null && user['photoUrl'].isNotEmpty
                                ? (
                                    user['photoUrl'].toString().startsWith('http')
                                        // Jika link (dari Google, dsb)
                                        ? NetworkImage(user['photoUrl'])
                                        // Jika base64
                                        : MemoryImage(
                                            base64Decode(
                                              user['photoUrl']
                                                  .toString()
                                                  .replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '')
                                            )
                                          ) as ImageProvider
                                  )
                                : null,
                            child: (user['photoUrl'] == null || user['photoUrl'].isEmpty)
                                ? Text(
                                    (user['name'] != null && user['name'].toString().isNotEmpty)
                                        ? user['name'].toString()[0].toUpperCase()
                                        : '',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.blueGrey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          title: Text(user['name'] ?? '',style: TextStyle(fontWeight: FontWeight.bold),),
                          subtitle: Text(user['status'] ?? '',style: TextStyle(fontSize: 12),),
                          trailing: PopupMenuButton(
                            color: Colors.white,
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: const Text('Edit Role',style: TextStyle(color: Colors.black),),
                                onTap: () {
                                  Get.defaultDialog(
                                    title: 'Edit Role Pengguna',
                                    backgroundColor: Colors.white,
                                    content: Column(
                                      children: [
                                        RadioListTile<int>(
                                          title: const Text('User'),
                                          value: 2,
                                          groupValue: user['status_code'],
                                          onChanged: (int? value) {
                                            if (value != null) {
                                              controller.updateUserRole(user['id'], value);
                                              Get.back();
                                            }
                                          },
                                        ),
                                        RadioListTile<int>(
                                          title: const Text('Admin'),
                                          value: 1,
                                          groupValue: user['status_code'], 
                                          onChanged: (int? value) {
                                            if (value != null) {
                                              controller.updateUserRole(user['id'], value);
                                              Get.back();
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              PopupMenuItem(
                                value: 'delete', 
                                child: const Text('Hapus',style: TextStyle(color: Colors.red),),
                                onTap: () {
                                  // Show confirmation dialog before deleting
                                  Get.defaultDialog(
                                    title: 'Konfirmasi',
                                    backgroundColor: Colors.white,
                                    middleText: 'Apakah anda yakin ingin menghapus pengguna ini?',
                                    textConfirm: 'Ya',
                                    textCancel: 'Tidak',
                                    confirmTextColor: Colors.white,
                                    onConfirm: () {
                                      controller.deleteUser(user['id']);
                                      Get.back();
                                    }
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
