import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:saksi_app/app/data/models/Complaint.dart';
import '../controllers/progres_complaint_controller.dart';

class DetailRiwayatTab extends GetView<ProgresComplaintController> {
  const DetailRiwayatTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ProgresComplaintController controller = Get.put(ProgresComplaintController());
    final String complaintId = Get.arguments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Riwayat Pengaduan'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        final complaint = controller.userComplaints.firstWhere((c) => c.complaintId == complaintId);
        final progress = complaint.progress ?? [];
        String ktpImageData = complaint.lampiranKtp;
        String buktiImageData = complaint.lampiranBukti;
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

        final DateTime tanggalPelaporan = complaint.tanggalPelaporan.toDate();
        final String formattedTanggal = DateFormat('dd MMMM yyyy HH:mm').format(tanggalPelaporan);

        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)
                  )
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.description, size: 40, color: Colors.blue.shade700),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pengaduan ${complaint.complaintId}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 4
                          )
                        ]
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: complaint.statusPengaduan == 2 ? Colors.green : Colors.blue,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formattedTanggal,
                      style: TextStyle(color: Colors.grey.shade700),
                    )
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Informasi Pelapor'),
                    _buildInfoCard([
                      _buildInfoItem('Nama', complaint.namaPelapor ?? '-'),
                      _buildInfoItem('Email', complaint.emailPelapor ?? '-'), 
                      _buildInfoItem('No. Telepon', complaint.noTeleponPelapor ?? '-'),
                      _buildInfoItem('Alamat', complaint.domisiliPelapor ?? '-'),
                      _buildInfoItem('Jenis Kelamin', complaint.jenisKelaminPelapor ?? '-'),
                    ]),

                    const SizedBox(height: 24),
                    _buildSectionTitle('Detail Pengaduan'),
                    _buildInfoCard([
                      _buildInfoItem('Bentuk Kekerasan', complaint.bentukKekerasanSeksual ?? '-'),
                      _buildInfoItem('Status Terlapor', complaint.statusTerlapor ?? '-'),
                      _buildInfoItem('Jenis Kelamin Terlapor', complaint.jenisKelaminTerlapor ?? '-'),
                      const Divider(height: 24),
                      _buildDescriptionItem('Cerita Singkat Peristiwa', complaint.ceritaSingkatPeristiwa ?? '-'),
                    ]),

                    const SizedBox(height: 24),
                    _buildSectionTitle('Bukti Pendukung'),
                    _buildInfoCard([
                      if (complaint.lampiranKtp.isNotEmpty) ...[
                        const Text(
                          'Foto KTP',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            base64Decode(ktpImageData),
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                width: double.infinity,
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: Text('Tidak dapat menampilkan gambar KTP'),
                                ),
                              );
                            },
                          ),
                        ),
                      ] else ...[
                        const Text(
                          'Foto KTP',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text('Tidak ada foto KTP yang diunggah'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (complaint.lampiranBukti.isNotEmpty) ...[
                        const Text(
                          'Bukti Pendukung',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            base64Decode(buktiImageData),
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                width: double.infinity,
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: Text('Tidak dapat menampilkan bukti pendukung'),
                                ),
                              );
                            },
                          ),
                        ),
                      ] else ...[
                        const Text(
                          'Bukti Pendukung',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text('Tidak ada bukti pendukung yang diunggah'),
                          ),
                        ),
                      ],
                    ]),

                    if (progress.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildSectionTitle('Riwayat Progress'),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: progress.length,
                        itemBuilder: (context, index) {
                          final item = progress[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.green.shade700),
                                      const SizedBox(width: 8),
                                      Text(
                                        item.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    DateFormat('dd MMMM yyyy').format(DateTime.parse(item.date)),
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(item.description),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
