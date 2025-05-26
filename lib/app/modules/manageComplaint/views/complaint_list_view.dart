import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/manage_complaint_controller.dart';

class ComplaintListView extends GetView<ManageComplaintController> {
  final int statusFilter;
  final String title;

  const ComplaintListView(
      {super.key, required this.statusFilter, required this.title});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ManageComplaintController());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        elevation: 0,
        title: Text(title,style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
        centerTitle: true,
         iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari pengaduan...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) => controller.searchComplaints(value),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredComplaints = controller.userComplaints
                    .where((complaint) =>
                        complaint.statusPengaduan == statusFilter)
                    .toList();

                if (filteredComplaints.isEmpty) {
                  String message = '';
                  switch (statusFilter) {
                    case 0:
                      message = 'Tidak ada pengaduan yang belum disetujui';
                      break;
                    case 1:
                      message = 'Tidak ada pengaduan yang sedang diproses';
                      break;
                    case 2:
                      message = 'Tidak ada pengaduan yang telah selesai';
                      break;
                    case 3:
                      message = 'Tidak ada pengaduan yang ditolak';
                      break;
                    default:
                      message = 'Tidak ada pengaduan';
                  }
                  return Center(child: Text(message));
                }

                return ListView.builder(
                  itemCount: filteredComplaints.length,
                  itemBuilder: (context, index) {
                    final complaint = filteredComplaints[index];

                    IconData statusIcon;
                    Color statusColor;
                    String statusText;

                    switch (statusFilter) {
                      case 0:
                        statusIcon = Icons.warning;
                        statusColor = Colors.orange.shade800;
                        statusText = 'Menunggu Persetujuan';
                        break;
                      case 1:
                        statusIcon = Icons.pending_actions;
                        statusColor = Colors.blue.shade800;
                        statusText = 'Diproses';
                        break;
                      case 2:
                        statusIcon = Icons.check_circle;
                        statusColor = Colors.green.shade800;
                        statusText = 'Selesai';
                        break;
                      case 3:
                        statusIcon = Icons.cancel;
                        statusColor = Colors.red.shade800;
                        statusText = 'Ditolak';
                        break;
                      default:
                        statusIcon = Icons.help;
                        statusColor = Colors.grey;
                        statusText = 'Tidak Diketahui';
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
                            Text('Status: $statusText'),
                            Text(
                                'Email: ${complaint.emailPelapor ?? 'Tidak Diketahui'}'),
                          ],
                        ),
                        onTap: () {
                              Get.toNamed('/detail-complaint',
                                  arguments: complaint.complaintId);
                        },
                        trailing: PopupMenuButton(
                          color: Colors.white,
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'detail',
                              child: Text('Lihat Detail'),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'detail') {
                              Get.toNamed('/detail-complaint',
                                  arguments: complaint.complaintId);
                            }
                          },
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
