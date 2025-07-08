import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/complaint_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class ComplaintView extends GetView<ComplaintController> {
  const ComplaintView({super.key});
  @override
  Widget build(BuildContext context) {
    final ComplaintController controller = Get.put(ComplaintController());

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueGrey.shade700,
        title: const Text(
          'Formulir Penerimaan Laporan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            // letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Container dengan progress indicator
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueGrey.shade100.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: Colors.blueGrey, size: 22),
                        const SizedBox(width: 8),
                        const Text(
                          'Informasi Pelaporan',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                    Obx(() => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Langkah ${controller.currentStep.value + 1}/4',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey.shade700,
                            ),
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.lock_outline,
                        color: Colors.blueGrey, size: 22),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Mohon isi semua informasi dengan lengkap dan jelas. Data yang dimasukkan akan dijaga kerahasiaannya.',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Obx(() => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (controller.currentStep.value + 1) / 4,
                        backgroundColor: Colors.blueGrey.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blueGrey.shade700),
                        minHeight: 10,
                      ),
                    )),
                const SizedBox(height: 12),
                Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildProgressStep(
                            'Data Diri', 0, controller.currentStep.value),
                        _buildProgressStep(
                            'Kejadian', 1, controller.currentStep.value),
                        _buildProgressStep(
                            'Terlapor', 2, controller.currentStep.value),
                        _buildProgressStep(
                            'Konfirmasi', 3, controller.currentStep.value),
                      ],
                    )),
              ],
            ),
          ),

          // Expanded untuk konten yang berubah berdasarkan step
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Obx(() {
                // Menampilkan konten berdasarkan current step
                switch (controller.currentStep.value) {
                  case 0:
                    return _buildStepOne(controller);
                  case 1:
                    return _buildStepTwo(controller);
                  case 2:
                    return _buildStepThree(controller);
                  case 3:
                  default:
                    return _buildStepFour(controller);
                }
              }),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan step progress
  Widget _buildProgressStep(String label, int step, int currentStep) {
    bool isActive = step <= currentStep;
    bool isCurrent = step == currentStep;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isCurrent ? 38 : 32,
          height: isCurrent ? 38 : 32,
          decoration: BoxDecoration(
            color: isActive
                ? (isCurrent
                    ? Colors.blueGrey.shade700
                    : Colors.blueGrey.shade400)
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20),
            border: isCurrent
                ? Border.all(color: Colors.blueGrey.shade900, width: 2.5)
                : null,
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: Colors.blueGrey.shade200,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.bold,
                fontSize: isCurrent ? 18 : 15,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isActive ? Colors.blueGrey.shade700 : Colors.grey.shade600,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  // Step 1: Data Diri
  Widget _buildStepOne(ComplaintController controller) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Data Pelapor'),
            const SizedBox(height: 10),
            _buildLabeledField(
              label: 'Nama Pelapor (Korban/Saksi)*',
              child: TextFormField(
                controller: controller.namaPelapor,
                decoration: _inputDecoration('Masukkan nama lengkap'),
              ),
            ),
            const SizedBox(height: 16),
            _buildLabeledField(
              label: 'Nomor telepon Pelapor*',
              child: TextFormField(
                controller: controller.noTeleponPelapor,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Masukkan nomor telepon'),
              ),
            ),
            const SizedBox(height: 16),
            _buildLabeledField(
              label: 'Jenis kelamin Pelapor*',
              child: Row(
                children: [
                  Flexible(
                    flex: 6,
                    child: RadioListTile<String>(
                      title: const Text('Perempuan',
                          overflow: TextOverflow.ellipsis),
                      value: 'Perempuan',
                      groupValue: controller.selectedGender.value,
                      onChanged: (value) {
                        controller.setGender(value!);
                      },
                      activeColor: Colors.blueGrey.shade700,
                      contentPadding: EdgeInsets.only(right: 8),
                    ),
                  ),
                  SizedBox(width: 16), // beri jarak agar tidak terlalu rapat
                  Flexible(
                    flex: 6,
                    child: RadioListTile<String>(
                      title: const Text('Laki-laki',
                          overflow: TextOverflow.ellipsis),
                      value: 'Laki-laki',
                      groupValue: controller.selectedGender.value,
                      onChanged: (value) {
                        controller.setGender(value!);
                      },
                      activeColor: Colors.blueGrey.shade700,
                      contentPadding: EdgeInsets.only(left: 8),
                    ),
                  ),
                ],
              ),
            ),
            _buildLabeledField(
              label: 'Status Pelapor*',
              child: DropdownButtonFormField<String>(
                value: controller.statusPelapor.text.isNotEmpty
                    ? controller.statusPelapor.text
                    : null,
                hint: const Text('Pilih status pengguna'),
                items: <String>[
                  'Mahasiswa',
                  'Pendidik/Dosen',
                  'Tenaga Kependidikan',
                  'Warga Kampus',
                  'Masyarakat Umum'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  controller.setStatusPelapor(newValue!);
                },
                decoration: _inputDecoration('').copyWith(
                  filled: true,
                  fillColor: Colors.white,
                ),
                dropdownColor: Colors.white,
              ),
            ),
            _buildLabeledField(
              label: 'Domisili Pelapor*',
              child: TextFormField(
                controller: controller.domisiliPelapor,
                decoration: _inputDecoration('Masukkan alamat domisili'),
              ),
            ),
            _buildLabeledField(
              label: 'Disabilitas*',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        flex: 6,
                        child: RadioListTile<String>(
                          title: const Text('Iya',
                              overflow: TextOverflow.ellipsis),
                          value: 'Iya',
                          groupValue: controller.selectedDisabilitas.value,
                          onChanged: (value) {
                            controller.setDisabilitas(value!);
                          },
                          activeColor: Colors.blueGrey.shade700,
                          contentPadding: EdgeInsets.only(right: 8),
                        ),
                      ),
                      SizedBox(
                          width: 16), // beri jarak agar tidak terlalu rapat
                      Flexible(
                        flex: 6,
                        child: RadioListTile<String>(
                          title: const Text('Tidak',
                              overflow: TextOverflow.ellipsis),
                          value: 'Tidak',
                          groupValue: controller.selectedDisabilitas.value,
                          onChanged: (value) {
                            controller.setDisabilitas(value!);
                          },
                          activeColor: Colors.blueGrey.shade700,
                          contentPadding: EdgeInsets.only(left: 8),
                        ),
                      ),
                    ],
                  ),
                  if (controller.selectedDisabilitas.value == 'Iya')
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextFormField(
                        controller: controller.keteranganDisabilitas,
                        decoration: _inputDecoration('Keterangan'),
                      ),
                    ),
                ],
              ),
            ),
            _buildLabeledField(
              label: 'Nomor telepon Pihak Lain yang dapat dihubungi*',
              child: TextFormField(
                controller: controller.noTeleponPihakLain,
                keyboardType: TextInputType.number,
                decoration:
                    _inputDecoration('Masukkan nomor telepon Pihak Lain'),
              ),
            ),
            const SizedBox(height: 8),
            _buildNavigationButtons(controller),
          ],
        ),
      ),
    );
  }

  // Step 2: Detail Kejadian
  Widget _buildStepTwo(ComplaintController controller) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Detail Kejadian'),
            const SizedBox(height: 10),
            _buildLabeledField(
              label: 'Bentuk Kekerasan Seksual (Silakan Dinarasikan)*',
              child: TextFormField(
                controller: controller.bentukKekerasan,
                maxLines: 3,
                decoration: _inputDecoration(
                    'Deskripsikan jenis kekerasan yang terjadi'),
              ),
            ),
            _buildLabeledField(
              label:
                  'Cerita singkat peristiwa (Memuat waktu, tempat, dan peristiwa)*',
              child: TextFormField(
                controller: controller.ceritaSingkatPeristiwa,
                maxLines: 5,
                decoration: _inputDecoration(
                    'Ceritakan kronologi kejadian secara detail'),
              ),
            ),
            _buildLabeledField(
              label: 'Alasan Pengaduan*',
              child: DropdownButtonFormField<String>(
                decoration: _inputDecoration('').copyWith(
                  filled: true,
                  fillColor: Colors.white,
                ),
                dropdownColor: Colors.white,
                value: controller.alasanPengaduan.text.isNotEmpty
                    ? controller.alasanPengaduan.text
                    : null,
                hint: const Text("Pilih Alasan Pengaduan"),
                isExpanded: true,
                menuMaxHeight: 300,
                items: [
                  'Saya seorang saksi yang khawatir dengan keadaan korban',
                  'Saya seorang korban yang memerlukan bantuan pemulihan',
                  'Saya ingin pimpinan kampus menindak tegas terlapor',
                  'Saya ingin Satgas PPKS mendokumentasikan kejadiannya, meningkatkan keamanan kampus dari kekerasan seksual, dan memberi perlindungan bagi saya',
                  'Lainnya',
                ].map((alasan) {
                  return DropdownMenuItem<String>(
                    value: alasan,
                    child: Text(alasan),
                  );
                }).toList(),
                onChanged: (value) {
                  controller.alasanPengaduan.text = value!;
                  if (value == 'Lainnya') {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Alasan Lainnya'),
                        content: TextField(
                          controller: controller.alasanPengaduanLainnya,
                          decoration: const InputDecoration(
                            hintText: 'Sebutkan alasan lainnya...',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Simpan'),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
            _buildLabeledField(
              label: 'Identifikasi kebutuhan korban*',
              child: DropdownButtonFormField<String>(
                decoration: _inputDecoration('').copyWith(
                  filled: true,
                  fillColor: Colors.white,
                ),
                dropdownColor: Colors.white,
                value: controller.identifikasiKebutuhan.text.isNotEmpty
                    ? controller.identifikasiKebutuhan.text
                    : null,
                hint: const Text("Pilih Kebutuhan Korban"),
                items: [
                  'Konseling psikologis',
                  'Konseling rohani/spiritual',
                  'Bantuan hukum',
                  'Bantuan Medis',
                  'Lainnya',
                  'Tidak membutuhkan pendampingan',
                ].map((kebutuhan) {
                  return DropdownMenuItem<String>(
                    value: kebutuhan,
                    child: Text(kebutuhan),
                  );
                }).toList(),
                onChanged: (value) {
                  controller.identifikasiKebutuhan.text = value!;
                  if (value == 'Lainnya') {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Kebutuhan Lainnya'),
                        content: TextField(
                          controller: controller.identifikasiKebutuhanLainnya,
                          decoration: const InputDecoration(
                            hintText: 'Sebutkan kebutuhan lainnya...',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Simpan'),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
            _buildNavigationButtons(controller),
          ],
        ),
      ),
    );
  }

  // Step 3: Bukti Pendukung
  Widget _buildStepThree(ComplaintController controller) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Terlapor & Bukti'),
            const SizedBox(height: 10),
            _buildLabeledField(
              label: 'Status Terlapor',
              child: DropdownButtonFormField<String>(
                decoration: _inputDecoration('').copyWith(
                  filled: true,
                  fillColor: Colors.white,
                ),
                dropdownColor: Colors.white,
                value: controller.statusTerlapor.text.isNotEmpty
                    ? controller.statusTerlapor.text
                    : null,
                hint: const Text("Pilih Status Terlapor"),
                items: [
                  'Mahasiswa',
                  'Pendidik / Dosen',
                  'Tenaga Kependidikan',
                  'Warga Kampus',
                  'Masyarakat Umum',
                ].map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  controller.statusTerlapor.text = value!;
                },
              ),
            ),
            _buildLabeledField(
              label: 'Jenis Kelamin Terlapor',
              child: Row(
                children: [
                  Flexible(
                    flex: 6,
                    child: RadioListTile<String>(
                      title: const Text('Perempuan',
                          overflow: TextOverflow.ellipsis),
                      value: 'Perempuan',
                      groupValue: controller.selectedGenderTerlapor.value,
                      onChanged: (value) {
                        controller.setGenderTerlapor(value!);
                      },
                      activeColor: Colors.blueGrey.shade700,
                      contentPadding: EdgeInsets.only(right: 8),
                    ),
                  ),
                  SizedBox(width: 16), // beri jarak agar tidak terlalu rapat
                  Flexible(
                    flex: 6,
                    child: RadioListTile<String>(
                      title: const Text('Laki-laki',
                          overflow: TextOverflow.ellipsis),
                      value: 'Laki-laki',
                      groupValue: controller.selectedGenderTerlapor.value,
                      onChanged: (value) {
                        controller.setGenderTerlapor(value!);
                      },
                      activeColor: Colors.blueGrey.shade700,
                      contentPadding: EdgeInsets.only(left: 8),
                    ),
                  ),
                ],
              ),
            ),
            _buildLabeledField(
              label: 'Upload KTP / KTM',
              child: Obx(() => controller.ktpImage.value != null
                  ? GestureDetector(
                      onTap: () {
                        // Tampilkan preview gambar KTP jika diklik
                        Get.dialog(
                          Dialog(
                            backgroundColor: Colors.transparent,
                            child: InteractiveViewer(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(
                                  controller.ktpImage.value!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          controller.ktpImage.value!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.shade100,
                      ),
                      child: const Center(
                        child: Text('Belum ada foto KTP'),
                      ),
                    )),
            ),
            const SizedBox(height: 8),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => controller.pickKtpImage(),
                icon: const Icon(Icons.upload),
                label: const Text('Upload KTP'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // ElevatedButton(
            //   onPressed: () => controller.uploadFileToGoogleDrive(),
            //   child: Text('Upload File'),
            // ),
            _buildLabeledField(
              label: 'Link Bukti Pendukung (Google Drive)',
              child: Obx(() {
                final fileId = controller.buktiImageUrl.value;
                if (fileId.isNotEmpty) {
                  final url = controller.buktiImageUrl.value;
                  return GestureDetector(
                    onTap: () async {
                      await launchUrl(Uri.parse(url));
                    },
                    child: Text(
                      url,
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        fontSize: 14,
                      ),
                    ),
                  );
                } else {
                  return const Text(
                    'Belum ada file bukti yang diupload ke Google Drive',
                    style: TextStyle(color: Colors.grey),
                  );
                }
              }),
            ),
            // _buildLabeledField(
            //   label: 'Upload Bukti Pendukung',
            //   child: Obx(() => controller.buktiImage.value != null
            //       ? GestureDetector(
            //           onTap: () {
            //             // Tampilkan preview gambar KTP jika diklik
            //             Get.dialog(
            //               Dialog(
            //                 backgroundColor: Colors.transparent,
            //                 child: InteractiveViewer(
            //                   child: ClipRRect(
            //                     borderRadius: BorderRadius.circular(16),
            //                     child: Image.file(
            //                       controller.buktiImage.value!,
            //                       fit: BoxFit.contain,
            //                     ),
            //                   ),
            //                 ),
            //               ),
            //             );
            //           },
            //           child: ClipRRect(
            //             borderRadius: BorderRadius.circular(10),
            //             child: Image.file(
            //               controller.buktiImage.value!,
            //               height: 180,
            //               width: double.infinity,
            //               fit: BoxFit.cover,
            //             ),
            //           ),
            //         )
            //       : Container(
            //           height: 180,
            //           width: double.infinity,
            //           decoration: BoxDecoration(
            //             border: Border.all(color: Colors.grey),
            //             borderRadius: BorderRadius.circular(10),
            //             color: Colors.grey.shade100,
            //           ),
            //           child: const Center(
            //             child: Text('Belum ada bukti pendukung'),
            //           ),
            //         )),
            // ),
            const SizedBox(height: 8),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => controller.uploadFileToGoogleDrive(),
                icon: const Icon(Icons.upload),
                label: const Text('Upload Bukti'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildNavigationButtons(controller),
          ],
        ),
      ),
    );
  }

  // Step 4: Konfirmasi
  Widget _buildStepFour(ComplaintController controller) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Konfirmasi Data'),
            const SizedBox(height: 16),
            Card(
              elevation: 1,
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Data Pelapor',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    const Divider(),
                    _buildInfoRow('Nama', controller.namaPelapor.text),
                    _buildInfoRow(
                        'No Telepon', controller.noTeleponPelapor.text),
                    _buildInfoRow(
                        'Jenis Kelamin', controller.genderPelapor.text),
                    _buildInfoRow('Domisili', controller.domisiliPelapor.text),
                    _buildInfoRow(
                        'Status Pelapor', controller.statusPelapor.text),
                    _buildInfoRow(
                        'Disabilitas', controller.keteranganDisabilitas.text),
                    _buildInfoRow('Nomor Telepon Pihak Lain',
                        controller.noTeleponPihakLain.text),

                    const SizedBox(height: 16),
                    const Text(
                      'Detail Kejadian',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    const Divider(),
                    _buildInfoRow(
                        'Bentuk Kekerasan', controller.bentukKekerasan.text),
                    _buildInfoRow('Deskripsi Kejadian',
                        controller.ceritaSingkatPeristiwa.text),
                    _buildInfo(
                        'Alasan Pengaduan', controller.alasanPengaduan.text,
                        customValue: controller.alasanPengaduanLainnya.text),
                    _buildInfo('Kebutuhan Korban',
                        controller.identifikasiKebutuhan.text,
                        customValue:
                            controller.identifikasiKebutuhanLainnya.text),
                    const SizedBox(height: 16),
                    const Text(
                      'Terlapor',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    const Divider(),
                    _buildInfoRow(
                        'Status Terlapor', controller.statusTerlapor.text),
                    _buildInfoRow('Jenis Kelamin Terlapor',
                        controller.genderTerlapor.text),
                    // Preview lampiran KTP
                    const SizedBox(height: 8),
                    const Text(
                      'Lampiran KTP',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => GestureDetector(
                          onTap: () {
                            if (controller.ktpImage.value != null) {
                              showDialog(
                                context: Get.context!,
                                builder: (BuildContext dialogContext) {
                                  return Dialog(
                                    child: Image.file(
                                      controller.ktpImage.value!,
                                      fit: BoxFit.contain,
                                    ),
                                  );
                                },
                              );
                            }
                          },
                          child: controller.ktpImage.value != null
                              ? Container(
                                  height: 120,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image:
                                          FileImage(controller.ktpImage.value!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 120,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Text('Belum ada foto KTP'),
                                  ),
                                ),
                        )),
                    const SizedBox(height: 16),
                    const Text(
                      'Lampiran Bukti Pendukung',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // Obx(() => GestureDetector(
                    //       onTap: () {
                    //         if (controller.buktiImage.value != null) {
                    //           showDialog(
                    //             context: Get.context!,
                    //             builder: (BuildContext dialogContext) {
                    //               return Dialog(
                    //                 child: Image.file(
                    //                   controller.buktiImage.value!,
                    //                   fit: BoxFit.contain,
                    //                 ),
                    //               );
                    //             },
                    //           );
                    //         }
                    //       },
                    //       child: controller.buktiImage.value != null
                    //           ? Container(
                    //               height: 120,
                    //               width: double.infinity,
                    //               decoration: BoxDecoration(
                    //                 borderRadius: BorderRadius.circular(8),
                    //                 image: DecorationImage(
                    //                   image: FileImage(
                    //                       controller.buktiImage.value!),
                    //                   fit: BoxFit.cover,
                    //                 ),
                    //               ),
                    //             )
                    //           : Container(
                    //               height: 120,
                    //               width: double.infinity,
                    //               decoration: BoxDecoration(
                    //                 border: Border.all(color: Colors.grey),
                    //                 borderRadius: BorderRadius.circular(8),
                    //               ),
                    //               child: const Center(
                    //                 child: Text('Belum ada bukti pendukung'),
                    //               ),
                    //             ),
                    //     )),

                    // const SizedBox(height: 16),
                    // const Divider(),
                    // Tampilkan fileId Google Drive jika ada
                    Obx(() {
                      if (controller.buktiImageUrl.value.isNotEmpty) {
                        String url = controller.buktiImageUrl.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bukti Pendukung:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () async {
                                await launchUrl(Uri.parse(url));
                              },
                              child: Text(
                                url,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return const Text('Belum ada bukti pendukung');
                      }
                    }),
                    
                    const SizedBox(height: 16),
                    const Divider(),
                    Row(
                      children: [
                        Checkbox(
                          value: controller.agreementChecked.value,
                          onChanged: (bool? value) {
                            controller.agreementChecked.value = value ?? false;
                          },
                          activeColor: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        const Expanded(
                          child: Text(
                            'Saya menyatakan bahwa informasi yang diberikan adalah benar dan dapat dipertanggungjawabkan',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _buildNavigationButtons(controller),
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan row informasi
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.black87),
            ),
          ),
          Expanded(
            child: Text(value.isEmpty ? '-' : value,
                style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildAlasanPengaduanRow() {
    String displayText = controller.alasanPengaduan.text;

    // If "Lainnya" is selected and there's custom text, append it
    if (displayText == 'Lainnya' &&
        controller.alasanPengaduanLainnya.text.isNotEmpty) {
      displayText = 'Lainnya: ${controller.alasanPengaduanLainnya.text}';
    }

    return _buildInfo('Alasan Pengaduan', displayText);
  }

  // For displaying Kebutuhan Korban with the "Lainnya" option
  Widget _buildKebutuhanKorbanRow() {
    String displayText = controller.identifikasiKebutuhan.text;

    // If "Lainnya" is selected and there's custom text, append it
    if (displayText == 'Lainnya' &&
        controller.identifikasiKebutuhanLainnya.text.isNotEmpty) {
      displayText = 'Lainnya: ${controller.identifikasiKebutuhanLainnya.text}';
    }

    return _buildInfo('Kebutuhan Korban', displayText);
  }

  Widget _buildInfo(String label, String value, {String? customValue}) {
    String displayText = value;

    // If value is "Lainnya" and customValue exists, append it
    if (value == 'Lainnya' && customValue != null && customValue.isNotEmpty) {
      displayText = 'Lainnya: $customValue';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(color: Colors.black87),
            ),
          ),
          Expanded(
            child: Text(displayText,
                style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  // Tombol navigasi
  Widget _buildNavigationButtons(ComplaintController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Visibility(
            visible: controller.currentStep.value > 0,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: ElevatedButton.icon(
              onPressed: controller.currentStep.value > 0
                  ? () {
                      controller.currentStep.value--;
                    }
                  : null,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Sebelumnya'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
          controller.currentStep.value < 3
              ? ElevatedButton.icon(
                  onPressed: () {
                    // Validasi setiap langkah sebelum melanjutkan
                    if (controller.validateCurrentStep()) {
                      controller.currentStep.value++;
                    }
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Berikutnya'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )
              : Obx(() => ElevatedButton.icon(
                    onPressed: controller.agreementChecked.value
                        ? () {
                            controller.submitForm();
                          }
                        : null,
                    icon: Obx(() {
                      return controller.isLoading.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send);
                    }),
                    label: Obx(() {
                      return Text(controller.isLoading.value
                          ? "Loading..."
                          : "Kirim Laporan");
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )),
        ],
      ),
    );
  }

  // Helper for section title
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 22,
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade700,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: Colors.blueGrey.shade700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // Helper for labeled field
  Widget _buildLabeledField({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.5,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 7),
          child,
        ],
      ),
    );
  }

  // Helper for input decoration
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blueGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.blueGrey.shade100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.blueGrey.shade700, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}
