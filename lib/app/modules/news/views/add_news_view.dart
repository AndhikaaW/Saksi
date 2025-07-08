import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saksi_app/app/modules/news/controllers/news_controller.dart';

class AddNewsView extends GetView<NewsController> {
  const AddNewsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Berita',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.blueGrey,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 1,
      ),
      body: Column(
        children: [
          // Tab selector
          Container(
            color: Colors.grey[100],
            child: Row(
                children: [
                Expanded(
                  child: Obx(() => GestureDetector(
                    onTap: () => controller.selectedMode.value = 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                      color: controller.selectedMode.value == 0
                        ? Colors.blueGrey[100]
                        : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                        color: controller.selectedMode.value == 0
                          ? Colors.blueGrey[600]!
                          : Colors.transparent,
                        width: 3,
                        ),
                      ),
                      ),
                      child: Center(
                      child: Text(
                        'Dari Link',
                        style: TextStyle(
                        color: controller.selectedMode.value == 0
                          ? Colors.blueGrey[800]
                          : Colors.blueGrey[400],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        ),
                      ),
                      ),
                    ),
                    )),
                ),
                Expanded(
                  child: Obx(() => GestureDetector(
                    onTap: () => controller.selectedMode.value = 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                      color: controller.selectedMode.value == 1
                        ? Colors.blueGrey[100]
                        : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                        color: controller.selectedMode.value == 1
                          ? Colors.blueGrey[600]!
                          : Colors.transparent,
                        width: 3,
                        ),
                      ),
                      ),
                      child: Center(
                      child: Text(
                        'Manual',
                        style: TextStyle(
                        color: controller.selectedMode.value == 1
                          ? Colors.blueGrey[800]
                          : Colors.blueGrey[400],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        ),
                      ),
                      ),
                    ),
                    )),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Obx(() => controller.selectedMode.value == 0
                ? _buildLinkForm()
                : _buildManualForm()),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tambahkan Berita dari Link',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: controller.titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Berita',
                hintText: 'Masukkan judul berita',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                hintText: 'Masukkan deskripsi berita',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.imageUrlController,
              decoration: const InputDecoration(
                labelText: 'URL Gambar (Opsional)',
                hintText: 'Masukkan URL gambar untuk berita',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.newsUrlController,
              decoration: const InputDecoration(
                labelText: 'URL Berita',
                hintText: 'Masukkan URL berita yang akan dibuka',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 24),
            Obx(() => ElevatedButton(
                  onPressed: controller.isFormValid.value
                      ? () => controller.addNews()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Simpan Berita', 
                          style: TextStyle(color: Colors.white)),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildManualForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tambahkan Berita Manual',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: controller.manualTitleController,
              decoration: const InputDecoration(
                labelText: 'Judul Berita',
                hintText: 'Masukkan judul berita',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.manualDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                hintText: 'Masukkan deskripsi berita',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            // Image picker section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gambar Berita (Opsional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() => controller.selectedImage.value != null
                      ? Column(
                          children: [
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  controller.selectedImage.value!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton.icon(
                                  onPressed: controller.showImageSourceDialog,
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Ganti Gambar'),
                                ),
                                TextButton.icon(
                                  onPressed: controller.removeSelectedImage,
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  label: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Belum ada gambar dipilih',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: controller.showImageSourceDialog,
                              icon: const Icon(Icons.add_a_photo),
                              label: const Text('Pilih Gambar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey[100],
                                foregroundColor: Colors.blueGrey[700],
                                minimumSize: const Size(double.infinity, 45),
                              ),
                            ),
                          ],
                        )),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Obx(() => ElevatedButton(
                  onPressed: controller.isManualFormValid.value
                      ? () => controller.addManualNews()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Simpan Berita', 
                          style: TextStyle(color: Colors.white)),
                )),
          ],
        ),
      ),
    );
  }
}