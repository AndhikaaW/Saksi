import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saksi_app/app/data/models/Complaint.dart';
import '../controllers/manage_complaint_controller.dart';

class DetailComplaintView extends GetView<ManageComplaintController> {
  const DetailComplaintView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ManageComplaintController());
    final Complaint complaint = Get.arguments;
    String status = '';
    final TextEditingController statusController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengaduan'),
        centerTitle: true,
        actions: [
          if (complaint.statusPengaduan == 0)
            IconButton(
              icon: const Icon(Icons.play_arrow),
              tooltip: 'Proses Pengaduan',
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
                          controller.processComplaint(complaint.uid);
                          Get.back();
                        },
                        child: const Text('Proses'),
                      ),
                    ],
                  ),
                );
              },
            ),
          PopupMenuButton(
            itemBuilder: (context) => [
              if (complaint.statusPengaduan == 1)
                const PopupMenuItem(
                  value: 'complete',
                  child: Text('Selesaikan Pengaduan'),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Hapus Pengaduan'),
              ),
            ],
            onSelected: (value) {
              if (value == 'delete') {
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
                          controller.deleteComplaint(complaint.uid);
                          Get.back();
                          Get.back();
                        },
                        child: const Text('Hapus'),
                      ),
                    ],
                  ),
                );
              } else if (value == 'complete') {
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
                          controller.completeComplaint(complaint.uid);
                          Get.back();
                        },
                        child: const Text('Selesaikan'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                                'Pengaduan \n #${complaint.uid}',
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
                    _buildInfoRow('Jenis Kekerasan Seksual',
                        complaint.jenisKekerasanSeksual ?? 'Tidak Diketahui'),
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
                child: Column(
                  children: [
                    SizedBox(
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
                                    controller.processComplaint(complaint.uid);
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
                    const SizedBox(height: 8),
                    SizedBox(
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
                                    controller.rejectComplaint(complaint.uid);
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
                  ],
                ),
              ),
            if (complaint.statusPengaduan == 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Progress Pengaduan',
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
                            TextField(
                              controller: statusController,
                              decoration: const InputDecoration(
                                labelText: 'Tahapan Progress',
                                hintText: 'Contoh: Verifikasi Data',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: descriptionController,
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
                                  if (statusController.text.isNotEmpty && 
                                      descriptionController.text.isNotEmpty) {
                                    // Tambahkan progress ke database
                                    final Map<String, dynamic> progressData = {
                                      'title': statusController.text,
                                      'description': descriptionController.text,
                                      'date': DateTime.now().toString(),
                                    };
                                    
                                    // Panggil method untuk update progress
                                    controller.addProgressToComplaint(
                                      complaint.uid,
                                      progressData,
                                    );
                                    
                                    statusController.clear();
                                    descriptionController.clear();
                                    
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
                                  padding: const EdgeInsets.symmetric(vertical: 12),
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
                                    controller.completeComplaint(complaint.uid);
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
          ],
        ),
      ),
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
}
