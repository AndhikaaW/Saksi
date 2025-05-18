import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// import 'package:saksi_app/app/data/models/Complaint.dart';
import '../controllers/manage_complaint_controller.dart';

class DetailComplaintView extends GetView<ManageComplaintController> {
  const DetailComplaintView({super.key});
  @override
  Widget build(BuildContext context) {
    final ManageComplaintController controller =
        Get.put(ManageComplaintController());
    final dynamic arguments = Get.arguments;
    final String? complaintId = arguments is Map<String, dynamic>
        ? arguments['complaintId']
        : arguments;

    // controller.fetchComplaintById(complaintId ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengaduan'),
        centerTitle: true,
        actions: [
          Obx(() {
            if (controller.userComplaints.isEmpty) {
              return const SizedBox.shrink();
            }

            final complaint = controller.userComplaints.firstWhere(
                (c) => c.complaintId == complaintId,
                orElse: () => controller.userComplaints.first);

            return PopupMenuButton(
              itemBuilder: (context) => [
                if (complaint.statusPengaduan == 0)
                  const PopupMenuItem(
                    value: 'proses',
                    child: Text('Proses Pengaduan'),
                  ),
                if (complaint.statusPengaduan == 0)
                  const PopupMenuItem(
                    value: 'tolak',
                    child: Text('Tolak Pengaduan'),
                  ),
                if (complaint.statusPengaduan == 1)
                  const PopupMenuItem(
                    value: 'selesai',
                    child: Text('Selesaikan Pengaduan'),
                  ),
                const PopupMenuItem(
                  value: 'hapus',
                  child: Text('Hapus Pengaduan'),
                ),
              ],
              onSelected: (value) {
                if (value == 'hapus') {
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
                            controller.deleteComplaint(complaint.complaintId);
                            Get.back();
                            Get.back();
                          },
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                  );
                } else if (value == 'selesai') {
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Selesaikan Pengaduan'),
                      content: const Text(
                          'Apakah Anda yakin ingin menyelesaikan pengaduan ini?'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            controller.completeComplaint(complaint.complaintId);
                            Get.back();
                          },
                          child: const Text('Selesaikan'),
                        ),
                      ],
                    ),
                  );
                } else if (value == 'proses') {
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
                            controller.processComplaint(complaint.complaintId);
                            Get.back();
                          },
                          child: const Text('Proses'),
                        ),
                      ],
                    ),
                  );
                } else if (value == 'tolak') {
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Tolak Pengaduan'),
                      content: const Text(
                          'Apakah Anda yakin ingin menolak pengaduan ini?'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            controller.rejectComplaint(complaint.complaintId);
                            Get.back();
                          },
                          child: const Text('Tolak'),
                        ),
                      ],
                    ),
                  );
                }
              },
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.userComplaints.isEmpty) {
          return const Center(child: Text('Tidak ada data pengaduan'));
        }

        final complaint = controller.userComplaints.firstWhere(
            (c) => c.complaintId == complaintId,
            orElse: () => controller.userComplaints.first);
        final progress = complaint.progress;
        String status = '';

        switch (complaint.statusPengaduan) {
          case 0:
            status = 'Menunggu Persetujuan';
            break;
          case 1:
            status = 'Diproses';
            break;
          case 2:
            status = 'Selesai';
            break;
          case 3:
            status = 'Ditolak';
            break;
          default:
            status = 'Tidak Diketahui';
        }
        final DateTime tanggalPelaporan =
            complaint.tanggalPelaporan.toDate() ?? DateTime.now();
        final String formattedTanggal =
            "${tanggalPelaporan.day.toString().padLeft(2, '0')}/${tanggalPelaporan.month.toString().padLeft(2, '0')}/${tanggalPelaporan.year} ${tanggalPelaporan.hour.toString().padLeft(2, '0')}:${tanggalPelaporan.minute.toString().padLeft(2, '0')}";

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: const Icon(Icons.report_problem,
                                color: Colors.blue),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pengaduan ${complaint.complaintId}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: complaint.statusPengaduan == 0
                                        ? Colors.orange.shade100
                                        : complaint.statusPengaduan == 1
                                            ? Colors.blue.shade100
                                            : complaint.statusPengaduan == 2
                                                ? Colors.green.shade100
                                                : Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: complaint.statusPengaduan == 0
                                          ? Colors.orange.shade800
                                          : complaint.statusPengaduan == 1
                                              ? Colors.blue.shade800
                                              : complaint.statusPengaduan == 2
                                                  ? Colors.green.shade800
                                                  : Colors.red.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (complaint.statusPengaduan == 3 && (complaint.alasanTolak != null && complaint.alasanTolak.toString().trim().isNotEmpty)) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Alasan Penolakan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  complaint.alasanTolak.toString(),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const Text(
                'Informasi Pelapor',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                          'Nama', complaint.namaPelapor ?? 'Tidak Diketahui'),
                      const Divider(),
                      _buildInfoRow(
                          'Email', complaint.emailPelapor ?? 'Tidak Diketahui'),
                      const Divider(),
                      _buildInfoRow('No. Telepon',
                          complaint.noTeleponPelapor ?? 'Tidak Diketahui'),
                      const Divider(),
                      _buildInfoRow('Status Pelapor',
                          complaint.statusPelapor ?? 'Tidak Diketahui'),
                      const Divider(),
                      _buildInfoRow('Alamat',
                          complaint.domisiliPelapor ?? 'Tidak Diketahui'),
                      const Divider(),
                      _buildInfoRow('Jenis Kelamin',
                          complaint.jenisKelaminPelapor ?? 'Tidak Diketahui'),
                      const Divider(),
                      _buildInfoRow('Keterangan Disabilitas',
                          complaint.keteranganDisabilitas ?? 'Tidak Diketahui'),
                      const Divider(),
                      _buildInfoRow('No Telepon Pihak Lain',
                          complaint.noTeleponPihakLain ?? 'Tidak Diketahui'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Detail Pengaduan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                          'Bentuk Kekerasan Seksual',
                          complaint.bentukKekerasanSeksual ??
                              'Tidak Diketahui'),
                      const Divider(),
                      _buildInfoRow(
                          'Tanggal', formattedTanggal ?? 'Tidak Diketahui'),
                      const Divider(),
                      _buildInfoRow(
                          'Alasan Pengaduan', complaint.alasanPengaduan ?? '-'),
                      const Divider(),
                      _buildInfoRow('Identifikasi Kebutuhan',
                          complaint.identifikasiKebutuhan ?? '-'),
                      const Divider(),
                      _buildInfoRow('Status Terlapor',
                          complaint.statusTerlapor ?? 'Tidak Diketahui'),
                      const Divider(),
                      _buildInfoRow('Jenis Kelamin Terlapor',
                          complaint.jenisKelaminTerlapor ?? 'Tidak Diketahui'),
                      const Divider(),
                      const Text(
                        'Cerita Singkat Peristiwa:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(complaint.ceritaSingkatPeristiwa ??
                          'Tidak Ada Deskripsi'),

                      // Tampilkan bukti pendukung (KTP & Bukti) seperti pada progresTab
                      const SizedBox(height: 16),
                      // KTP
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
                              complaint.lampiranKtp,
                              'KTP / KTM',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Bukti Pendukung
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bukti Pendukung:',
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
                              complaint.lampiranBukti,
                              'Bukti',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (complaint.statusPengaduan == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
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
                                      .processComplaint(complaint.complaintId);
                                  Get.back();
                                },
                                child: const Text('Proses'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Proses Pengaduan'),
                    ),
                  ),
                ),
              if (complaint.statusPengaduan == 1 ||
                  complaint.statusPengaduan == 2)
                _buildProgressTimeline(progress),
              const SizedBox(height: 4),
              if (complaint.statusPengaduan == 1)
                Builder(
                  builder: (context) {
                    final List<String> allProgressOptions = [
                      'Verifikasi Data',
                      'Pemanggilan Korban',
                      'Pemanggilan Pelaku',
                      'Investigasi/Penyelidikan',
                      'Penyusunan Laporan/Hasil',
                      'Rekomendasi/Tindak Lanjut',
                      'Pendampingan Korban',
                      'Monitoring dan Evaluasi',
                    ];

                    final List<String> existingProgressTitles = progress
                        .map<String>((item) {
                          if (item != null && item.title != null) {
                            return item.title.toString();
                          }
                          return '';
                        })
                        .where((title) => title.isNotEmpty)
                        .toList();

                    final List<String> availableOptions = allProgressOptions
                        .where((option) =>
                            !existingProgressTitles.contains(option))
                        .toList();

                    // Jika semua progress sudah terlaksana (dropdown habis), maka sembunyikan form tambah progress
                    if (availableOptions.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.green.shade400),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Semua tahapan progress telah terlaksana.',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Jika masih ada progress yang bisa ditambahkan, tampilkan form tambah progress
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tambah Progress',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Dropdown progress
                                      ValueListenableBuilder(
                                        valueListenable:
                                            controller.statusController,
                                        builder: (context,
                                            TextEditingValue value, _) {
                                          return DropdownButtonFormField<
                                              String>(
                                            value: controller.statusController
                                                    .text.isEmpty
                                                ? null
                                                : controller
                                                    .statusController.text,
                                            decoration: InputDecoration(
                                              labelText: controller
                                                      .statusController
                                                      .text
                                                      .isEmpty
                                                  ? 'Tahapan Progress'
                                                  : null,
                                              border:
                                                  const OutlineInputBorder(),
                                            ),
                                            items: availableOptions
                                                .map((option) =>
                                                    DropdownMenuItem(
                                                      value: option,
                                                      child: Text(option),
                                                    ))
                                                .toList(),
                                            onChanged: (String? value) {
                                              controller.statusController.text =
                                                  value ?? '';
                                            },
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      TextField(
                                        controller:
                                            controller.descriptionController,
                                        decoration: const InputDecoration(
                                          labelText: 'Deskripsi Progress',
                                          hintText:
                                              'Masukkan detail progress pengaduan',
                                          border: OutlineInputBorder(),
                                        ),
                                        maxLines: 3,
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            if (controller.statusController.text
                                                    .isNotEmpty &&
                                                controller.descriptionController
                                                    .text.isNotEmpty) {
                                              final Map<String, dynamic>
                                                  progressData = {
                                                'title': controller
                                                    .statusController.text,
                                                'description': controller
                                                    .descriptionController.text,
                                                'date':
                                                    DateTime.now().toString(),
                                              };

                                              controller.addProgressToComplaint(
                                                complaint.complaintId,
                                                progressData,
                                              );

                                              // Reset dropdown dan textfield setelah progress ditambahkan
                                              controller.statusController.text =
                                                  '';
                                              controller.descriptionController
                                                  .clear();

                                              Get.snackbar(
                                                'Sukses',
                                                'Progress berhasil ditambahkan',
                                                backgroundColor: Colors.green,
                                                colorText: Colors.white,
                                              );
                                            } else {
                                              Get.snackbar(
                                                'Error',
                                                'Tahapan dan deskripsi progress harus diisi',
                                                backgroundColor: Colors.red,
                                                colorText: Colors.white,
                                              );
                                            }
                                          },
                                          icon: const Icon(Icons.add_task),
                                          label: const Text('Tambah Progress'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              // const SizedBox(height: 16),
              if (complaint.statusPengaduan == 1)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.dialog(
                        AlertDialog(
                          title: const Text('Selesaikan Pengaduan'),
                          content: const Text(
                              'Apakah Anda yakin ingin menyelesaikan pengaduan ini?'),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () {
                                controller
                                    .completeComplaint(complaint.complaintId);
                                Get.back();
                              },
                              child: const Text('Selesaikan'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Selesaikan Pengaduan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                
                ),
                SizedBox(height: 12,),
              if (complaint.statusPengaduan == 0 ||
                  complaint.statusPengaduan == 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // final TextEditingController alasanTolakController = TextEditingController();
                        Get.dialog(
                          AlertDialog(
                            title: const Text('Tolak Pengaduan'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Silakan masukkan alasan penolakan pengaduan ini:'),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: controller.alasanTolak,
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Masukkan alasan penolakan',
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (controller.alasanTolak.text.isEmpty) {
                                    Get.snackbar(
                                      'Validasi',
                                      'Alasan penolakan harus diisi.',
                                      backgroundColor: Colors.red.shade100,
                                      colorText: Colors.red.shade900,
                                    );
                                    return;
                                  }
                                  controller.rejectComplaint(complaint.complaintId);
                                  Get.back();
                                },
                                child: const Text('Tolak'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Tolak Pengaduan'),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(': '+value),
          ),
        ],
      ),
    );
  }

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
              isLast: i == progressList.length - 1,
            ),
        ],
      ),
    );
  }

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
                      print('Error loading $imageType image in dialog: $error');
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

  Widget _buildTimelineItem({
    required String title,
    required String date,
    required String description,
    required bool isCompleted,
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
                height: 60,
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}
