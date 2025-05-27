import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/progres_complaint_controller.dart';

class DetailRiwayatTab extends GetView<ProgresComplaintController> {
  const DetailRiwayatTab({super.key});

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(int status) {
    switch (status) {
      case 0:
        return Icons.hourglass_empty_rounded;
      case 1:
        return Icons.sync_rounded;
      case 2:
        return Icons.check_circle_rounded;
      case 3:
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProgresComplaintController controller =
        Get.put(ProgresComplaintController());
    final String complaintId = Get.arguments;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Detail Riwayat Pengaduan'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        final complaint = controller.userComplaints
            .firstWhere((c) => c.complaintId == complaintId);
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
        final String formattedTanggal =
            DateFormat('dd MMMM yyyy HH:mm').format(tanggalPelaporan);

        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade100.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.description_rounded,
                          size: 48, color: Colors.blue.shade700),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Pengaduan #${complaint.complaintId}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: _getStatusColor(complaint.statusPengaduan)
                                .withOpacity(0.15),
                            spreadRadius: 2,
                            blurRadius: 8,
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(complaint.statusPengaduan),
                            color: _getStatusColor(complaint.statusPengaduan),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            status,
                            style: TextStyle(
                              color: _getStatusColor(complaint.statusPengaduan),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            color: Colors.white70, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          formattedTanggal,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
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
                      _buildInfoItem(
                          'No. Telepon', complaint.noTeleponPelapor ?? '-'),
                      _buildInfoItem(
                          'Alamat', complaint.domisiliPelapor ?? '-'),
                      _buildInfoItem('Jenis Kelamin',
                          complaint.jenisKelaminPelapor ?? '-'),
                      _buildInfoItem(
                          'Status Pelapor', complaint.statusPelapor ?? '-'),
                      _buildInfoItem('Keterangan Disabilitas',
                          complaint.keteranganDisabilitas ?? '-'),
                      _buildInfoItem('No Telepon Pihak Lain ',
                          complaint.noTeleponPihakLain ?? '-'),
                    ]),
                    const SizedBox(height: 28),
                    _buildSectionTitle('Detail Pengaduan'),
                    _buildInfoCard([
                      _buildInfoItem('Bentuk Kekerasan',
                          complaint.bentukKekerasanSeksual ?? '-'),
                      _buildInfoItem(
                          'Status Terlapor', complaint.statusTerlapor ?? '-'),
                      _buildInfoItem('Jenis Kelamin Terlapor',
                          complaint.jenisKelaminTerlapor ?? '-'),
                      _buildInfoItem(
                          'Alasan Pengaduan', complaint.alasanPengaduan ?? '-'),
                      _buildInfoItem('Identifikasi Kebutuhan',
                          complaint.identifikasiKebutuhan ?? '-'),
                      const Divider(height: 28, color: Colors.blueGrey),
                      _buildDescriptionItem('Cerita Singkat Peristiwa',
                          complaint.ceritaSingkatPeristiwa ?? '-'),
                    ]),
                    const SizedBox(height: 28),
                    _buildSectionTitle('Bukti Pendukung'),
                    _buildInfoCard([
                      // FOTO KTP
                      Row(
                        children: const [
                          Icon(Icons.credit_card_rounded, color: Colors.blueGrey, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Foto KTP / KTM',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (complaint.lampiranKtp.isNotEmpty)
                        Builder(
                          builder: (context) {
                            try {
                              final cleanedBase64 =
                                  ktpImageData.replaceAll(RegExp(r'\s+'), '');
                              final imageBytes = base64Decode(cleanedBase64);
                              return GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext dialogContext) {
                                      return Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: InteractiveViewer(
                                            child: Image.memory(
                                              imageBytes,
                                              fit: BoxFit.contain,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.error,
                                                          color:
                                                              Colors.red.shade300,
                                                          size: 40),
                                                      const SizedBox(height: 8),
                                                      const Text(
                                                        'Gagal memuat gambar KTP / KTM',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Hero(
                                  tag: 'ktp_${complaint.complaintId}',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.memory(
                                      imageBytes,
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 180,
                                          width: double.infinity,
                                          color: Colors.grey.shade200,
                                          child: const Center(
                                            child: Text(
                                                'Tidak dapat menampilkan gambar KTP / KTM'),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            } catch (e) {
                              return Container(
                                height: 180,
                                width: double.infinity,
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: Text(
                                      'Format gambar KTP / KTM tidak valid'),
                                ),
                              );
                            }
                          },
                        )
                      else
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child:
                                Text('Tidak ada foto KTP / KTM yang diunggah'),
                          ),
                        ),
                      const SizedBox(height: 18),

                      // BUKTI PENDUKUNG
                      Row(
                        children: const [
                          Icon(Icons.attachment_rounded, color: Colors.blueGrey, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Bukti Pendukung',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // if (complaint.lampiranBukti.isNotEmpty)
                      //   Builder(
                      //     builder: (context) {
                      //       try {
                      //         final cleanedBase64 =
                      //             buktiImageData.replaceAll(RegExp(r'\s+'), '');
                      //         final imageBytes = base64Decode(cleanedBase64);
                      //         return GestureDetector(
                      //           onTap: () {
                      //             showDialog(
                      //               context: context,
                      //               builder: (BuildContext dialogContext) {
                      //                 return Dialog(
                      //                   backgroundColor: Colors.transparent,
                      //                   child: ClipRRect(
                      //                     borderRadius: BorderRadius.circular(16),
                      //                     child: InteractiveViewer(
                      //                       child: Image.memory(
                      //                         imageBytes,
                      //                         fit: BoxFit.contain,
                      //                         errorBuilder:
                      //                             (context, error, stackTrace) {
                      //                           return Center(
                      //                             child: Column(
                      //                               mainAxisAlignment:
                      //                                   MainAxisAlignment.center,
                      //                               children: [
                      //                                 Icon(Icons.error,
                      //                                     color:
                      //                                         Colors.red.shade300,
                      //                                     size: 40),
                      //                                 const SizedBox(height: 8),
                      //                                 const Text(
                      //                                   'Gagal memuat gambar bukti',
                      //                                   style: TextStyle(
                      //                                       color: Colors.red),
                      //                                 ),
                      //                               ],
                      //                             ),
                      //                           );
                      //                         },
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 );
                      //               },
                      //             );
                      //           },
                      //           child: Hero(
                      //             tag: 'bukti_${complaint.complaintId}',
                      //             child: ClipRRect(
                      //               borderRadius: BorderRadius.circular(12),
                      //               child: Image.memory(
                      //                 imageBytes,
                      //                 height: 180,
                      //                 width: double.infinity,
                      //                 fit: BoxFit.cover,
                      //                 errorBuilder: (context, error, stackTrace) {
                      //                   return Container(
                      //                     height: 180,
                      //                     width: double.infinity,
                      //                     color: Colors.grey.shade200,
                      //                     child: const Center(
                      //                       child: Text(
                      //                           'Tidak dapat menampilkan bukti pendukung'),
                      //                     ),
                      //                   );
                      //                 },
                      //               ),
                      //             ),
                      //           ),
                      //         );
                      //       } catch (e) {
                      //         return Container(
                      //           height: 180,
                      //           width: double.infinity,
                      //           color: Colors.grey.shade200,
                      //           child: const Center(
                      //             child:
                      //                 Text('Format gambar bukti tidak valid'),
                      //           ),
                      //         );
                      //       }
                      //     },
                      //   )
                      // else
                      //   Container(
                      //     height: 180,
                      //     width: double.infinity,
                      //     decoration: BoxDecoration(
                      //       color: Colors.grey.shade200,
                      //       borderRadius: BorderRadius.circular(12),
                      //     ),
                      //     child: const Center(
                      //       child:
                      //           Text('Tidak ada bukti pendukung yang diunggah'),
                      //     ),
                      //   ),
                    // INSERT_YOUR_CODE
                    if ((complaint.lampiranBukti ?? '').isNotEmpty) ...[
                      const Text(
                        'Bukti Pendukung:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          await launchUrl(Uri.parse(complaint.lampiranBukti!));
                        },
                        child: Text(
                          complaint.lampiranBukti!,
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                    ]),
                    if (progress.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      _buildSectionTitle('Riwayat Progress'),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: progress.length,
                        itemBuilder: (context, index) {
                          final item = progress[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 2,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.check_circle_rounded,
                                          color: Colors.green.shade700, size: 22),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueGrey),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time_rounded,
                                          color: Colors.grey.shade400, size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        DateFormat('dd MMMM yyyy')
                                            .format(DateTime.parse(item.date)),
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    item.description,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
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
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            child: Text(
              ': $value',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionItem(String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blueGrey.withOpacity(0.07),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
