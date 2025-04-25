import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/manage_admin_controller.dart';

class ManageAdminView extends GetView<ManageAdminController> {
  const ManageAdminView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Admin'),
        centerTitle: true,
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
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: admin['photoUrl'] != null && admin['photoUrl'].isNotEmpty
                              ? NetworkImage(admin['photoUrl'])
                              : null,
                          child: admin['photoUrl'] == null || admin['photoUrl'].isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(admin['name'] ?? ''),
                        subtitle: Text(admin['status'] ?? ''),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: const Text('Edit Role'),
                              onTap: () {
                                Get.defaultDialog(
                                  title: 'Edit Role Admin',
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
                              child: const Text('Hapus'),
                              onTap: () {
                                Get.defaultDialog(
                                  title: 'Konfirmasi',
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
