import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/manage_admin_controller.dart';

class ManageAdminView extends GetView<ManageAdminController> {
  const ManageAdminView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Admin',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
              onChanged: (value) => controller.searchAdmin(value),
              decoration: InputDecoration(
                hintText: 'Cari admin...',
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

                // Menggunakan admins jika filteredAdmins kosong
                final displayedAdmins = controller.filteredAdmins.isEmpty ? 
                  controller.admins : controller.filteredAdmins;

                if (displayedAdmins.isEmpty) {
                  return const Center(child: Text('Tidak ada admin'));
                }
                return ListView.builder(
                  itemCount: displayedAdmins.length,
                  itemBuilder: (context, index) {
                    final admin = displayedAdmins[index];
                    return Card(
                      color: Colors.white,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          // Tampilkan dialog detail admin
                          Get.defaultDialog(
                            title: "Detail Admin",
                            backgroundColor: Colors.white,
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.white,
                                  backgroundImage: admin['photoUrl'] != null && admin['photoUrl'].isNotEmpty
                                      ? (
                                          admin['photoUrl'].toString().startsWith('http')
                                              ? NetworkImage(admin['photoUrl'])
                                              : MemoryImage(
                                                  base64Decode(
                                                    admin['photoUrl']
                                                        .toString()
                                                        .replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '')
                                                  )
                                                ) as ImageProvider
                                        )
                                      : null,
                                  child: (admin['photoUrl'] == null || admin['photoUrl'].isEmpty)
                                      ? Text(
                                          (admin['name'] != null && admin['name'].toString().isNotEmpty)
                                              ? admin['name'].toString()[0].toUpperCase()
                                              : '',
                                          style: const TextStyle(
                                            fontSize: 32,
                                            color: Colors.blueGrey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  admin['name'] ?? '-',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  admin['email'] ?? '-',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  admin['status'] ?? '-',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ],
                            ),
                            textConfirm: "Tutup",
                            confirmTextColor: Colors.white,
                            onConfirm: () {
                              Get.back();
                            },
                          );
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white,
                            backgroundImage: admin['photoUrl'] != null && admin['photoUrl'].isNotEmpty
                                ? (
                                    admin['photoUrl'].toString().startsWith('http')
                                        // Jika link (dari Google, dsb)
                                        ? NetworkImage(admin['photoUrl'])
                                        // Jika base64
                                        : MemoryImage(
                                            base64Decode(
                                              admin['photoUrl']
                                                  .toString()
                                                  .replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '')
                                            )
                                          ) as ImageProvider
                                  )
                                : null,
                            child: (admin['photoUrl'] == null || admin['photoUrl'].isEmpty)
                                ? Text(
                                    (admin['name'] != null && admin['name'].toString().isNotEmpty)
                                        ? admin['name'].toString()[0].toUpperCase()
                                        : '',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.blueGrey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          title: Text(admin['name'] ?? '',style: TextStyle(fontWeight: FontWeight.bold),),
                          subtitle: Text(admin['status'] ?? '',style: TextStyle(fontSize: 12),),
                          trailing: PopupMenuButton(
                            color: Colors.white, // Menetapkan background popup menjadi putih
                            child: const Icon(Icons.more_vert),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: const Text('Edit Role',style: TextStyle(color: Colors.black),),
                                onTap: () {
                                  Get.defaultDialog(
                                    title: 'Edit Role Admin',
                                    backgroundColor: Colors.white,
                                    content: Column(
                                      children: [
                                        RadioListTile<int>(
                                          title: const Text('Super Admin'),
                                          value: 0,
                                          groupValue: admin['status_code'],
                                          onChanged: (int? value) {
                                            if (value != null) {
                                              controller.updateAdminRole(admin['id'], value);
                                              Get.back();
                                            }
                                          },
                                        ),
                                        RadioListTile<int>(
                                          title: const Text('Admin'),
                                          value: 1,
                                          groupValue: admin['status_code'],
                                          onChanged: (int? value) {
                                            if (value != null) {
                                              controller.updateAdminRole(admin['id'], value);
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
                                  Get.defaultDialog(
                                    title: 'Konfirmasi',
                                    backgroundColor: Colors.white,
                                    middleText: 'Apakah anda yakin ingin menghapus admin ini?',
                                    textConfirm: 'Ya',
                                    textCancel: 'Tidak', 
                                    confirmTextColor: Colors.white,
                                    onConfirm: () {
                                      controller.deleteAdmin(admin['id']);
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
