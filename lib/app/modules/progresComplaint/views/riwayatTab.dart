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
          .where((complaint) => complaint.statusPengaduan == 2)
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
                backgroundColor: Colors.green.shade100,
                child: const Icon(Icons.check_circle, color: Colors.green),
              ),
              title: Text('Pengaduan ${complaint.complaintId}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(complaint.ceritaSingkatPeristiwa ??
                      'Tidak ada deskripsi'),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
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
