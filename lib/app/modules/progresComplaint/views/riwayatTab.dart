import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../controllers/progres_complaint_controller.dart';

class RiwayatTab extends GetView<ProgresComplaintController> {
  const RiwayatTab({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ProgresComplaintController());
    return Obx(() {
      // Cek jika data pengaduan user masih kosong
      if (controller.userComplaints.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 80, color: Colors.blueGrey.shade200),
              const SizedBox(height: 18),
              Text(
                'Belum ada pengaduan yang selesai',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blueGrey.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ayo laporkan jika mengalami kekerasan!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blueGrey.shade300,
                ),
              ),
            ],
          ),
        );
      }

      // Filter hanya pengaduan dengan status 2 (selesai) atau 3 (ditolak)
      final completedComplaints = controller.userComplaints
          .where((complaint) => complaint.statusPengaduan == 2 || complaint.statusPengaduan == 3)
          .toList();

      if (completedComplaints.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_rounded, size: 80, color: Colors.blueGrey.shade100),
              const SizedBox(height: 18),
              Text(
                'Belum ada riwayat pengaduan yang selesai',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blueGrey.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: completedComplaints.length + 1, // +1 untuk header
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Riwayat Pengaduan',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[100],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 18),
              ],
            );
          }

          final complaint = completedComplaints[index - 1];
          final dateTime = (complaint.tanggalPelaporan as Timestamp).toDate();

          // Penanganan LocaleDataException: jika locale belum diinisialisasi, fallback ke format default
          String formattedDate;
          try {
            formattedDate = DateFormat('dd MMMM yyyy', 'id_ID').format(dateTime);
          } catch (e) {
            formattedDate = DateFormat('dd MMMM yyyy').format(dateTime);
          }

          // Warna dan ikon status
          final bool isSelesai = complaint.statusPengaduan == 2;
          final Color statusColor = isSelesai ? Colors.green : Colors.red;
          final Color statusBg = isSelesai ? Colors.green.shade50 : Colors.red.shade50;
          final IconData statusIcon = isSelesai ? Icons.check_circle_rounded : Icons.cancel_rounded;
          final String statusText = isSelesai ? 'Selesai' : 'Ditolak';

          return Card(
            color: Colors.white,
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            shadowColor: statusColor.withOpacity(0.15),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Get.toNamed('/detail-riwayat', arguments: complaint.complaintId);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Icon
                    Container(
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.2)),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        statusIcon,
                        color: statusColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Info utama
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Pengaduan ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.blueGrey.shade700,
                                ),
                              ),
                              Text(
                                complaint.complaintId ?? '-',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: statusColor,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      statusIcon,
                                      color: statusColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      statusText,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            complaint.bentukKekerasanSeksual ?? 'Tidak ada deskripsi',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 16, color: Colors.blueGrey.shade300),
                              const SizedBox(width: 6),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blueGrey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
