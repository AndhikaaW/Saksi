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
                      _buildInfoRow('Disabilitas',
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
                      _buildInfoRow('Bentuk Kekerasan Seksual',
                          complaint.bentukKekerasanSeksual ?? 'Tidak Diketahui'),
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
                                  controller.processComplaint(complaint.complaintId);
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
                if (complaint.statusPengaduan == 1 || complaint.statusPengaduan == 2)
                _buildProgressTimeline(progress),
                const SizedBox(height: 4),
                if (complaint.statusPengaduan == 1)
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<String>(
                              value: controller.statusController.text.isEmpty
                                  ? null
                                  : controller.statusController.text,
                              decoration: const InputDecoration(
                                labelText: 'Tahapan Progress',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Verifikasi Data',
                                  child: Text('Verifikasi Data'),
                                ),
                                DropdownMenuItem(
                                  value: 'Pemanggilan Korban',
                                  child: Text('Pemanggilan Korban'),
                                ),
                                DropdownMenuItem(
                                  value: 'Pemanggilan Pelaku',
                                  child: Text('Pemanggilan Pelaku'),
                                ),
                                DropdownMenuItem(
                                  value: 'Investigasi/Penyelidikan',
                                  child: Text('Investigasi/Penyelidikan'),
                                ),
                                DropdownMenuItem(
                                  value: 'Penyusunan Laporan/Hasil',
                                  child: Text('Penyusunan Laporan/Hasil'),
                                ),
                                DropdownMenuItem(
                                  value: 'Rekomendasi/Tindak Lanjut',
                                  child: Text('Rekomendasi/Tindak Lanjut'),
                                ),
                                DropdownMenuItem(
                                  value: 'Pendampingan Korban',
                                  child: Text('Pendampingan Korban'),
                                ),
                                DropdownMenuItem(
                                  value: 'Monitoring dan Evaluasi',
                                  child: Text('Monitoring dan Evaluasi'),
                                ),
                              ],
                              onChanged: (String? value) {
                                controller.statusController.text = value ?? '';
                              },
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: controller.descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Deskripsi Progress',
                                hintText: 'Masukkan detail progress pengaduan',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  if (controller
                                          .statusController.text.isNotEmpty &&
                                      controller.descriptionController.text
                                          .isNotEmpty) {
                                    // Tambahkan progress ke database
                                    final Map<String, dynamic> progressData = {
                                      'title': controller.statusController.text,
                                      'description':
                                          controller.descriptionController.text,
                                      'date': DateTime.now().toString(),
                                    };

                                    // Panggil method untuk update progress
                                    controller.addProgressToComplaint(
                                      complaint.complaintId,
                                      progressData,
                                    );

                                    // Reset dropdown value setelah berhasil menambah progress
                                    controller.statusController.clear();
                                    controller.descriptionController.clear();

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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                                    controller.completeComplaint(complaint.complaintId);
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
                  ],
                ),
              ),
              if (complaint.statusPengaduan == 0 || complaint.statusPengaduan == 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
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
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
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
