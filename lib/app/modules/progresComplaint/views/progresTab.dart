import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:saksi_app/app/modules/progresComplaint/controllers/progres_complaint_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class ProgresTabView extends GetView<ProgresComplaintController> {
  const ProgresTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProgresComplaintController());
    controller.refreshComplaints(); // Memanggil refresh data saat build

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (controller.userComplaints.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Belum ada pengaduan yang diajukan',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      }

      // Filter complaints berdasarkan uid user yang login
      final userComplaints = controller.userComplaints
          .where((complaint) => complaint.uid == controller.uid.value)
          .toList();

      final progressComplaints = controller.userComplaints
          .where((complaint) =>
              complaint.statusPengaduan == 0 || complaint.statusPengaduan == 1)
          .toList();

      if (progressComplaints.isEmpty) {
        return const Center(
          child: Text('Tidak ada pengaduan yang diajukan'),
        );
      }

      return ListView.builder(
        
          padding: EdgeInsets.zero,
          itemCount: userComplaints.length,
          itemBuilder: (context, index) {
            final complaint = userComplaints[index];
            final complaintId = complaint.complaintId ?? 'Tidak Diketahui';
            final status =
                complaint.statusPengaduan.toString() ?? 'Tidak Diketahui';
            final dateTime = (complaint.tanggalPelaporan as Timestamp).toDate();
            final complaintDate =
                DateFormat('dd MMM yyyy').format(dateTime) ?? 'Tidak Diketahui';
            final progress = complaint.progress ?? [];

            // Siapkan variabel untuk menyimpan gambar KTP dan bukti
            String ktpImageData = complaint.lampiranKtp;
            String buktiImageData = complaint.lampiranBukti;

            if (status != '0' && status != '1') {
              return const SizedBox.shrink();
            }

            return Column(
              children: [
                _buildHeader(complaintId, complaintDate, status),
                // const Divider(),
                _buildReporterInfo(complaint),
                const Divider(),
                _buildIncidentInfo(complaint),
                const Divider(),
                _buildReportedPersonInfo(complaint),
                const Divider(),
                _buildBuktiSection(ktpImageData, buktiImageData),
                const Divider(),
                _buildProgressTimeline(progress),
                const Divider(),
                _buildContactPIC(),
                const SizedBox(height: 20),
              ],
            );
          });
    });
  }

  // 1. Header Info
  Widget _buildHeader(String complaintId, String complaintDate, String status) {
    Color statusColor;
    IconData statusIcon;
    String statusText;
    switch (status) {
      case '0':
        statusText = 'Menunggu Verifikasi';
        statusColor = Colors.blue;
        statusIcon = Icons.watch_later;
        break;
      case '1':
        statusText = 'Diproses';
        statusColor = Colors.orange;
        statusIcon = Icons.pending_actions;
        break;
      case '2':
        statusText = 'Selesai';
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case '3':
        statusText = 'Ditolak';
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusText = 'Tidak Diketahui';
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.blueGrey.withOpacity(0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ID Pengaduan: #$complaintId',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tanggal Pelaporan: $complaintDate',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(statusIcon, size: 18, color: statusColor),
              const SizedBox(width: 6),
              Text(
                'Status: $statusText',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2.  Informasi Pelapor
  Widget _buildReporterInfo(dynamic complaint) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Informasi Pelapor'),
          const SizedBox(height: 12),
          _infoRow('Nama', complaint.namaPelapor ?? '-'),
          _infoRow('Email', complaint.emailPelapor ?? '-'),
          _infoRow('No. Telepon', complaint.noTeleponPelapor ?? '-'),
          _infoRow('Domisili', complaint.domisiliPelapor ?? '-'),
          _infoRow('Jenis Kelamin', complaint.jenisKelaminPelapor ?? '-'),
          _infoRow('Status', complaint.statusPelapor ?? '-'),
          _infoRow('Keterangan Disabilitas', complaint.keteranganDisabilitas ?? '-'),
          _infoRow('No Telepon Pihak Lain', complaint.noTeleponPihakLain ?? '-'),
        ],
      ),
    );
  }

  // 3. Informasi Kejadian
  Widget _buildIncidentInfo(dynamic complaint) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Detail Peristiwa'),
          const SizedBox(height: 12),
          _infoRow('Bentuk Kekerasan Seksual',
              complaint.bentukKekerasanSeksual ?? '-'),
          const SizedBox(height: 8),
          const Text(
            'Cerita Singkat Peristiwa:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              complaint.ceritaSingkatPeristiwa ?? '-',
              style: TextStyle(color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Informasi Terlapor
  Widget _buildReportedPersonInfo(dynamic complaint) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Informasi Terlapor'),
          const SizedBox(height: 12),
          _infoRow('Status Terlapor', complaint.statusTerlapor ?? '-'),
          _infoRow('Jenis Kelamin', complaint.jenisKelaminTerlapor ?? '-'),
          const SizedBox(height: 12),
          _sectionTitle('Alasan & Kebutuhan'),
          const SizedBox(height: 8),
          _infoRow('Alasan Pengaduan', complaint.alasanPengaduan ?? '-'),
          _infoRow(
              'Identifikasi Kebutuhan', complaint.identifikasiKebutuhan ?? '-'),
        ],
      ),
    );
  }

  // 5. Timeline Progress
  Widget _buildProgressTimeline(List<dynamic> progressList) {
    if (progressList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progres Pengaduan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Icon(Icons.pending_actions,
                      size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(
                    'Belum ada progress',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progres Pengaduan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < progressList.length; i++)
            _buildTimelineItem(
              title: progressList[i].title,
              date: DateFormat('dd MMM yyyy')
                  .format(DateTime.parse(progressList[i].date)),
              description: progressList[i].description,
              isCompleted: true,
              imageUrl: progressList[i].image,
              isLast: i == progressList.length - 1,
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // 6. Timeline Item
  Widget _buildTimelineItem({
    required String title,
    required String date,
    required String description,
    required bool isCompleted,
    String? imageUrl,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Circle and line
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Colors.green : Colors.grey.shade400,
                border: Border.all(
                  color: isCompleted
                      ? Colors.green.shade700
                      : Colors.grey.shade600,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: imageUrl != null && imageUrl.isNotEmpty ? 160 : 60, // Adjust height if image exists
                color: isCompleted ? Colors.green : Colors.grey.shade300,
              ),
          ],
        ),

        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                          isCompleted ? Colors.black : Colors.grey.shade600,
                        ),
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        color: isCompleted
                            ? Colors.green.shade700
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isCompleted ? Colors.black87 : Colors.grey.shade600,
                  ),
                ),
                if (imageUrl != null && imageUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: Get.context!,
                          builder: (BuildContext dialogContext) {
                            final imageBytes = base64Decode(imageUrl.replaceAll(RegExp(r'\s+'), ''));
                            return Dialog(
                              child: InteractiveViewer(
                                child: Image.memory(
                                  imageBytes,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.error, color: Colors.red, size: 40),
                                          const SizedBox(height: 8),
                                          Text('Gagal memuat gambar', style: TextStyle(color: Colors.red.shade800)),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        height: 120, // Increased height for image
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                          image: DecorationImage(
                            image: MemoryImage(base64Decode(imageUrl.replaceAll(RegExp(r'\s+'), ''))),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) => const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        // child: ClipRRect(
                        //   borderRadius: BorderRadius.circular(12),
                        // ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 7. Bukti Section
  Widget _buildBuktiSection(String ktpImageData, String buktiImageData) {
    // final controller = Get.find<ProgresComplaintController>(); // Controller is not used in this function

    // Helper function to build a tappable image widget
    Widget _buildTappableImage(String base64String, String imageType) {
      if (base64String.isEmpty) {
        return _buildNoImagePlaceholder(imageType);
      }

      // Decode the image bytes
      final cleanedBase64 = base64String.replaceAll(RegExp(r'\s+'), '');
      try {
        final imageBytes = base64Decode(cleanedBase64);

        return GestureDetector(
          onTap: () {
            // Show full-screen preview dialog
            showDialog(
              context: Get.context!, // Use Get.context for dialog
              builder: (BuildContext dialogContext) {
                return Dialog(
                  // Wrap with InteractiveViewer for zoom/pan
                  child: InteractiveViewer(
                    child: Image.memory(
                      imageBytes,
                      fit: BoxFit.contain, // Use contain for full view
                      errorBuilder: (context, error, stackTrace) {
                        print(
                            'Error loading $imageType image in dialog: $error');
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error,
                                  color: Colors.red.shade300, size: 40),
                              const SizedBox(height: 8),
                              Text(
                                'Gagal memuat gambar $imageType',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
          // Display the image thumbnail
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              imageBytes,
              fit: BoxFit.cover, // Use cover for thumbnail
              errorBuilder: (context, error, stackTrace) {
                print('Error loading $imageType image thumbnail: $error');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red.shade300, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        'Gagal memuat gambar $imageType',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      } catch (e) {
        print('$imageType Base64 decode error: $e');
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, color: Colors.orange.shade700, size: 40),
              const SizedBox(height: 8),
              Text(
                'Format gambar $imageType tidak valid',
                style: const TextStyle(color: Colors.orange),
              ),
            ],
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Bukti Pendukung'),
          const SizedBox(height: 16),

          // KTP Image
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Foto KTP / KTM:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildTappableImage(
                    ktpImageData, 'KTP / KTM'), // Use the new helper
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Bukti Image
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     const Text(
          //       'Bukti Pendukung:',
          //       style: TextStyle(
          //         fontWeight: FontWeight.bold,
          //         fontSize: 14,
          //       ),
          //     ),
          //     const SizedBox(height: 8),
          //     Container(
          //       width: double.infinity,
          //       height: 200,
          //       decoration: BoxDecoration(
          //         border: Border.all(color: Colors.grey.shade300),
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //       // Removed Obx as buktiImageData is a simple string, not an Rx variable
          //       child: _buildTappableImage(
          //           buktiImageData, 'bukti'), // Use the new helper
          //     ),
          //   ],
          // ),
        // INSERT_YOUR_CODE
        // Tampilkan fileId Google Drive jika ada
        if (buktiImageData != null && buktiImageData.isNotEmpty) ...[
          const Text(
            'Bukti Pendukung:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              // Membuka link Google Drive di browser
              await launchUrl(Uri.parse(buktiImageData));
            },
            child: Text(
              buktiImageData,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                fontSize: 13,
              ),
            ),
          ),
        ],
        ],
      ),
    );
  }

  Widget _buildNoImagePlaceholder(String imageType) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported,
              color: Colors.grey.shade400, size: 40),
          const SizedBox(height: 8),
          Text(
            'Tidak ada gambar $imageType',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // 8. Kontak PIC
  Widget _buildContactPIC() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueGrey.shade50, Colors.blueGrey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.support_agent, color: Colors.blueGrey.shade700, size: 28),
              const SizedBox(width: 10),
              const Text(
                'Butuh Bantuan?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Jika Anda memiliki pertanyaan atau kendala terkait pengaduan, jangan ragu untuk menghubungi kami melalui fitur chat di bawah ini.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.blueGrey.shade800,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                Get.toNamed('/chat-list');
              },
              icon: Icon(Icons.chat_bubble_outline, color: Colors.white),
              label: const Text('Buka Fitur Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey.shade700,
                foregroundColor: Colors.white,
                elevation: 2,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                shadowColor: Colors.blueGrey.shade100,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Respon cepat & ramah!',
              style: TextStyle(
                color: Colors.blueGrey.shade400,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for section titles
  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Helper widget for information rows
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
