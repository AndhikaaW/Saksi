import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:saksi_app/app/routes/app_pages.dart';
import '../controllers/progres_complaint_controller.dart';

class RiwayatTab extends GetView<ProgresComplaintController> {
  const RiwayatTab({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ProgresComplaintController());
    return Obx(() {
     if (controller.userComplaints.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Belum ada pengaduan yang selesai',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      }
      // Filter hanya pengaduan dengan status 2 (selesai)
      final completedComplaints = controller.userComplaints
          .where((complaint) => complaint.statusPengaduan == 2 || complaint.statusPengaduan == 3)
          .toList();

      if (completedComplaints.isEmpty) {
        return const Center(
          child: Text('Belum ada riwayat pengaduan yang selesai'),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: completedComplaints.length + 1, // +1 untuk header
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Riwayat Pengaduan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
              ],
            );
          }

          final complaint = completedComplaints[index - 1];
          final dateTime = (complaint.tanggalPelaporan as Timestamp).toDate();
          final formattedDate = DateFormat('dd MMMM yyyy').format(dateTime);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: complaint.statusPengaduan == 2 
                    ? Colors.green.shade100 
                    : Colors.red.shade100,
                child: complaint.statusPengaduan == 2
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.cancel, color: Colors.red),
              ),
              title: Text('Pengaduan ${complaint.complaintId}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(complaint.bentukKekerasanSeksual ??
                      'Tidak ada deskripsi'),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: complaint.statusPengaduan == 2 ? Colors.green.shade100 : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          complaint.statusPengaduan == 2 ? 'Selesai' : 'Ditolak',
                          style: TextStyle(
                            fontSize: 10, 
                            color: complaint.statusPengaduan == 2 ? Colors.green.shade800 : Colors.red.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              isThreeLine: true,
              onTap: () {
                Get.toNamed('/detail-riwayat', arguments: complaint.complaintId);
              },
            ),
          );
        },
      );
    });
  }
}
