// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:saksi_app/app/modules/manageComplaint/views/detail_complaint_view.dart';
import '../controllers/manage_complaint_controller.dart';

class ManageComplaintView extends GetView<ManageComplaintController> {
  const ManageComplaintView({super.key});
  @override
  Widget build(BuildContext context) {
    Get.put(ManageComplaintController());
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Manajemen Pengaduan",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueGrey,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Cari pengaduan...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: (value) => controller.searchComplaints(value),
              ),
              const SizedBox(height: 16),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Obx(() => FilterChip(
                          backgroundColor: Colors.white,
                          label: const Text('Semua'),
                          selected: controller.selectedFilter.value == -1,
                          selectedColor: Colors.blue.shade100,
                          onSelected: (bool selected) {
                            if (selected) {
                              controller.selectedFilter.value = -1;
                              controller.filterComplaintsByStatus(-1);
                            }
                          },
                        )),
                    const SizedBox(width: 8),
                    Obx(() => FilterChip(
                          backgroundColor: Colors.white,
                          label: const Text('Menunggu'),
                          selected: controller.selectedFilter.value == 0,
                          selectedColor: Colors.blue.shade100,
                          onSelected: (bool selected) {
                            if (selected) {
                              controller.selectedFilter.value = 0;
                              controller.filterComplaintsByStatus(0);
                            }
                          },
                        )),
                    const SizedBox(width: 8),
                    Obx(() => FilterChip(
                          backgroundColor: Colors.white,  
                          label: const Text('Diproses'),
                          selected: controller.selectedFilter.value == 1,
                          selectedColor: Colors.blue.shade100,
                          onSelected: (bool selected) {
                            if (selected) {
                              controller.selectedFilter.value = 1;
                              controller.filterComplaintsByStatus(1);
                            }
                          },
                        )),
                    const SizedBox(width: 8),
                    Obx(() => FilterChip(
                          backgroundColor: Colors.white,
                          label: const Text('Selesai'),
                          selected: controller.selectedFilter.value == 2,
                          selectedColor: Colors.blue.shade100,
                          onSelected: (bool selected) {
                            if (selected) {
                              controller.selectedFilter.value = 2;
                              controller.filterComplaintsByStatus(2);
                            }
                          },
                        )),
                    const SizedBox(width: 8),
                    Obx(() => FilterChip(
                          backgroundColor: Colors.white,
                          label: const Text('Ditolak'),
                          selected: controller.selectedFilter.value == 3,
                          selectedColor: Colors.blue.shade100,
                          onSelected: (bool selected) {
                            if (selected) {
                              controller.selectedFilter.value = 3;
                              controller.filterComplaintsByStatus(3);
                            }
                          },
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // List pengaduan
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.userComplaints.isEmpty) {
                    return const Center(child: Text('Tidak ada pengaduan'));
                  }

                  return ListView.builder(
                    itemCount: controller.userComplaints.length,
                    itemBuilder: (context, index) {
                      final complaint = controller.userComplaints[index];
                      String status = '';
                      IconData statusIcon;
                      Color statusColor;
                      switch (complaint.statusPengaduan) {
                        case 0:
                          statusIcon = Icons.warning;
                          statusColor = Colors.orange.shade800;
                          status = 'Menunggu Persetujuan';
                          break;
                        case 1:
                          statusIcon = Icons.pending_actions;
                          statusColor = Colors.blue.shade800;
                          status = 'Diproses';
                          break;
                        case 2:
                          statusIcon = Icons.check_circle;
                          statusColor = Colors.green.shade800;
                          status = 'Selesai';
                          break;
                        case 3:
                          statusIcon = Icons.cancel;
                          statusColor = Colors.red.shade800;
                          status = 'Ditolak';
                          break;
                        default:
                          statusIcon = Icons.help;
                          statusColor = Colors.grey;
                          status = 'Tidak Diketahui-';
                      }

                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: statusColor.withOpacity(0.1),
                            child: Icon(statusIcon, color: statusColor),
                          ),
                          title: Text('Pengaduan ${complaint.complaintId}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Pelapor: ${complaint.namaPelapor ?? 'Tidak Diketahui'}'),
                              Text('Status: $status'),
                              Text(
                                  'Email: ${complaint.emailPelapor ?? 'Tidak Diketahui'}'),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            color: Colors.white,
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'detail',
                                child: Text('Lihat Detail'),
                              ),
                              if (complaint.statusPengaduan == 0)
                                const PopupMenuItem(
                                  value: 'process',
                                  child: Text('Proses Pengaduan'),
                                ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Hapus'),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'detail') {
                                Get.toNamed('/detail-complaint',
                                    arguments: complaint.uid);
                              } else if (value == 'process') {
                                // Tampilkan dialog konfirmasi untuk memproses pengaduan
                                Get.dialog(
                                  AlertDialog(
                                    title: const Text('Proses Pengaduan'),
                                    content: const Text(
                                        'Apakah Anda yakin ingin memproses pengaduan ini?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Get.back(),
                                        child: const Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          controller
                                              .processComplaint(complaint.uid);
                                        },
                                        child: const Text('Proses'),
                                      ),
                                    ],
                                  ),
                                );
                              } else if (value == 'delete') {
                                Get.dialog(
                                  AlertDialog(
                                    title: const Text('Hapus Pengaduan'),
                                    content: const Text(
                                        'Apakah Anda yakin ingin menghapus pengaduan ini?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Get.back(),
                                        child: const Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          controller
                                              .deleteComplaint(complaint.uid);
                                        },
                                        child: const Text('Hapus'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                          isThreeLine: true,
                          onTap: () {
                            // Navigasi ke halaman detail
                            Get.toNamed('/detail-complaint',
                                arguments: complaint.complaintId);
                          },
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ));
  }
}
