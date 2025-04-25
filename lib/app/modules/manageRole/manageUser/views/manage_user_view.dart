import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/manage_user_controller.dart';

class ManageUserView extends GetView<ManageUserController> {
  const ManageUserView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pengguna'),
        centerTitle: true,
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
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user['photoUrl'] != null && user['photoUrl'].isNotEmpty
                              ? NetworkImage(user['photoUrl'])
                              : null,
                          child: user['photoUrl'] == null || user['photoUrl'].isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(user['name'] ?? ''),
                        subtitle: Text(user['status'] ?? ''),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: const Text('Edit Role'),
                              onTap: () {
                                Get.defaultDialog(
                                  title: 'Edit Role Pengguna',
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
                              child: const Text('Hapus'),
                              onTap: () {
                                // Show confirmation dialog before deleting
                                Get.defaultDialog(
                                  title: 'Konfirmasi',
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
