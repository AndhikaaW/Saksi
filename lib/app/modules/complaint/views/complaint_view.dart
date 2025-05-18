import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/complaint_controller.dart';

class ComplaintView extends GetView<ComplaintController> {
  const ComplaintView({super.key});
  @override
  Widget build(BuildContext context) {
    final ComplaintController controller = Get.put(ComplaintController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulir Penerimaan Laporan'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Container dengan progress indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Informasi Pelaporan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Obx(() => Text(
                      'Langkah ${controller.currentStep.value + 1}/4',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    )),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mohon isi semua informasi dengan lengkap dan jelas. '
                      'Data yang dimasukkan akan dijaga kerahasiaannya.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Obx(() => LinearProgressIndicator(
                  value: (controller.currentStep.value + 1) / 4,
                  backgroundColor: Colors.blue.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                )),
                const SizedBox(height: 8),
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildProgressStep('Data Diri', 0, controller.currentStep.value),
                    _buildProgressStep('Kejadian', 1, controller.currentStep.value),
                    _buildProgressStep('Terlapor', 2, controller.currentStep.value),
                    _buildProgressStep('Konfirmasi', 3, controller.currentStep.value),
                  ],
                )),
              ],
            ),
          ),

          // Expanded untuk konten yang berubah berdasarkan step
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
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
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue.shade700 : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(15),
            border: isCurrent ? Border.all(color: Colors.blue.shade900, width: 2) : null,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.blue.shade700 : Colors.grey.shade600,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Step 1: Data Diri
  Widget _buildStepOne(ComplaintController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nama Pelapor (Korban/Saksi)*',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.namaPelapor,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Masukkan nama lengkap',
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Nomor telepon Pelapor*',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.noTeleponPelapor,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Masukkan nomor telepon',
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Jenis kelamin Pelapor*',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Perempuan'),
                value: 'Perempuan',
                groupValue: controller.selectedGender.value,
                onChanged: (value) {
                  controller.setGender(value!);
                },
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Laki-laki'),
                value: 'Laki-laki',
                groupValue: controller.selectedGender.value,
                onChanged: (value) {
                  controller.setGender(value!);
                },
              ),
            ),
          ],
        ),
        const Text(
          'Status Pelapor*',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
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
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Domisili Pelapor*',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.domisiliPelapor,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Masukkan alamat domisili',
          ),
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Disabilitas*",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Iya'),
                    value: 'Iya',
                    groupValue: controller.selectedDisabilitas.value,
                    onChanged: (value) {
                      controller.setDisabilitas(value!);
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Tidak'),
                    value: 'Tidak',
                    groupValue: controller.selectedDisabilitas.value,
                    onChanged: (value) {
                      controller.setDisabilitas(value!);
                    },
                  ),
                ),
              ],
            ),
            if (controller.selectedDisabilitas.value == 'Iya')
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextFormField(
                  controller: controller.keteranganDisabilitas,
                  decoration: const InputDecoration(
                    hintText: 'Keterangan',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 8),
        const Text(
          'Nomor telepon Pihak Lain yang dapat dihubungi*',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.noTeleponPihakLain,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Masukkan nomor telepon Pihak Lain',
          ),
        ),

        _buildNavigationButtons(controller),
      ],
    );
  }

  // Step 2: Detail Kejadian
  Widget _buildStepTwo(ComplaintController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bentuk Kekerasan Seksual (Silakan Dinarasikan)*',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.bentukKekerasan,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Deskripsikan jenis kekerasan yang terjadi',
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Cerita singkat peristiwa (Memuat waktu, tempat, dan peristiwa)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.ceritaSingkatPeristiwa,
          maxLines: 5,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Ceritakan kronologi kejadian secara detail',
          ),
        ),
        const SizedBox(height: 16),
        // Alasan Pengaduan Dropdown
        // Alasan Pengaduan Dropdown
        const Text(
          'Alasan Pengaduan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
          value: controller.alasanPengaduan.text.isNotEmpty ? controller.alasanPengaduan.text : null,
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

        const SizedBox(height: 16),

        // Identifikasi Kebutuhan Korban Dropdown
        const Text(
          'Identifikasi kebutuhan korban',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
          value: controller.identifikasiKebutuhan.text.isNotEmpty ? controller.identifikasiKebutuhan.text : null,
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
        _buildNavigationButtons(controller),
      ],
    );
  }

  // Step 3: Bukti Pendukung
  Widget _buildStepThree(ComplaintController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status Terlapor',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          value: controller.statusTerlapor.text.isNotEmpty ? controller.statusTerlapor.text : null,
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
        const SizedBox(height: 8),
        const Text(
          'Jenis Kelamin Terlapor',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Perempuan'),
                value: 'Perempuan',
                groupValue: controller.selectedGenderTerlapor.value,
                onChanged: (value) {
                  controller.setGenderTerlapor(value!);
                },
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Laki-laki'),
                value: 'Laki-laki',
                groupValue: controller.selectedGenderTerlapor.value,
                onChanged: (value) {
                  controller.setGenderTerlapor(value!);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Upload KTP',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Obx(() => controller.ktpImage.value != null
          ? Image.file(
              controller.ktpImage.value!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          : Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('Belum ada foto KTP'),
              ),
            ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => controller.pickKtpImage(),
          icon: const Icon(Icons.upload),
          label: const Text('Upload KTP'),
        ),
        const SizedBox(height: 16),
        const Text(
          'Upload Bukti Pendukung',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Obx(() => controller.buktiImage.value != null
          ? Image.file(
              controller.buktiImage.value!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          : Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('Belum ada bukti pendukung'),
              ),
            ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => controller.pickBuktiImage(),
          icon: const Icon(Icons.upload),
          label: const Text('Upload Bukti'),
        ),
        const SizedBox(height: 16),
        _buildNavigationButtons(controller),
      ],
    );
  }

  // Step 4: Konfirmasi
  Widget _buildStepFour(ComplaintController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Konfirmasi Data',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Data Pelapor',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                _buildInfoRow('Nama', controller.namaPelapor.text),
                _buildInfoRow('No Telepon', controller.noTeleponPelapor.text),
                _buildInfoRow('Jenis Kelamin', controller.genderPelapor.text),
                _buildInfoRow('Domisili', controller.domisiliPelapor.text),
                _buildInfoRow('Status Pelapor', controller.statusPelapor.text),
                _buildInfoRow('Disabilitas', controller.keteranganDisabilitas.text),
                _buildInfoRow('Nomor Telepon Pihak Lain', controller.noTeleponPihakLain.text),

                const SizedBox(height: 16),
                const Text(
                  'Detail Kejadian',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                _buildInfoRow('Bentuk Kekerasan', controller.bentukKekerasan.text),
                _buildInfoRow('Deskripsi Kejadian', controller.ceritaSingkatPeristiwa.text),
                _buildInfo('Alasan Pengaduan', controller.alasanPengaduan.text,
                    customValue: controller.alasanPengaduanLainnya.text),
                _buildInfo('Kebutuhan Korban', controller.identifikasiKebutuhan.text,
                    customValue: controller.identifikasiKebutuhanLainnya.text),
                const SizedBox(height: 16),
                const Text(
                  'Terlapor',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                _buildInfoRow('Status Terlapor', controller.statusTerlapor.text),
                _buildInfoRow('Jenis Kelamin Terlapor', controller.genderTerlapor.text),
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
                            context: Get.context!, // Pastikan context tersedia di sini
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
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(controller.ktpImage.value!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Container(
                              height: 200,
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
                Obx(() => GestureDetector(
                      onTap: () {
                        if (controller.buktiImage.value != null) {
                          showDialog(
                            context: Get.context!, // Pastikan context tersedia di sini
                            builder: (BuildContext dialogContext) {
                              return Dialog(
                                child: Image.file(
                                  controller.buktiImage.value!,
                                  fit: BoxFit.contain,
                                ),
                              );
                            },
                          );
                        }
                      },
                      child: controller.buktiImage.value != null
                          ? Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(controller.buktiImage.value!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text('Belum ada bukti pendukung'),
                              ),
                            ),
                    )),

                const SizedBox(height: 16),
                const Divider(),
                Row(
                  children: [
                    Checkbox(
                      value: controller.agreementChecked.value,
                      onChanged: (bool? value) {
                        controller.agreementChecked.value = value ?? false;
                      },
                    ),
                    Expanded(
                      child: const Text(
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
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value.isEmpty ? '-' : value),
          ),
        ],
      ),
    );
  }

  Widget _buildAlasanPengaduanRow() {
    String displayText = controller.alasanPengaduan.text;

    // If "Lainnya" is selected and there's custom text, append it
    if (displayText == 'Lainnya' && controller.alasanPengaduanLainnya.text.isNotEmpty) {
      displayText = 'Lainnya: ${controller.alasanPengaduanLainnya.text}';
    }

    return _buildInfo('Alasan Pengaduan', displayText);
  }

// For displaying Kebutuhan Korban with the "Lainnya" option
  Widget _buildKebutuhanKorbanRow() {
    String displayText = controller.identifikasiKebutuhan.text;

    // If "Lainnya" is selected and there's custom text, append it
    if (displayText == 'Lainnya' && controller.identifikasiKebutuhanLainnya.text.isNotEmpty) {
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
            width: 120, // Adjust width as needed
            child: Text(
              '$label:',
            ),
          ),
          Expanded(
            child: Text(displayText),
          ),
        ],
      ),
    );
  }

  // Tombol navigasi
  Widget _buildNavigationButtons(ComplaintController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 16),
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
              return Text(
                controller.isLoading.value ? "Loading..." : "Kirim Laporan"
              );
            }),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
          )),
        ],
      ),
    );
  }
}