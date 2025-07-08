import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saksi_app/app/data/models/News.dart';
import 'package:saksi_app/app/modules/news/views/news_view.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<NewsModel> news = <NewsModel>[].obs;
  final RxBool isLoading = false.obs;

  // Form controller untuk tambah berita dari link
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final imageUrlController = TextEditingController();
  final newsUrlController = TextEditingController();

  // Form controller untuk tambah berita manual
  final manualTitleController = TextEditingController();
  final manualDescriptionController = TextEditingController();

  final RxBool isFormValid = false.obs;
  final RxBool isManualFormValid = false.obs;

  // Image picker
  final ImagePicker _picker = ImagePicker();
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString selectedImageBase64 = ''.obs;

  // Mode selection
  final RxInt selectedMode = 0.obs; // 0 = Link, 1 = Manual

  @override
  void onInit() {
    super.onInit();
    fetchNews();

    // Listen perubahan pada form untuk validasi
    titleController.addListener(_validateForm);
    descriptionController.addListener(_validateForm);
    newsUrlController.addListener(_validateForm);

    // Listen perubahan pada manual form untuk validasi
    manualTitleController.addListener(_validateManualForm);
    manualDescriptionController.addListener(_validateManualForm);
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    imageUrlController.dispose();
    newsUrlController.dispose();
    manualTitleController.dispose();
    manualDescriptionController.dispose();
    super.onClose();
  }

  void _validateForm() {
    isFormValid.value = titleController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        newsUrlController.text.isNotEmpty;
  }

  void _validateManualForm() {
    isManualFormValid.value = manualTitleController.text.isNotEmpty &&
        manualDescriptionController.text.isNotEmpty;
  }

  void resetForm() {
    titleController.clear();
    descriptionController.clear();
    imageUrlController.clear();
    newsUrlController.clear();
    isFormValid.value = false;
  }

  void resetManualForm() {
    manualTitleController.clear();
    manualDescriptionController.clear();
    selectedImage.value = null;
    selectedImageBase64.value = '';
    isManualFormValid.value = false;
  }

  void resetAllForms() {
    resetForm();
    resetManualForm();
  }

  // Generate ID unik sederhana
  String _generateId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final randomStr =
        List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
    return '$timestamp-$randomStr';
  }

  // Image picker methods
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        await _convertImageToBase64(image);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil gambar dari galeri: $e',
          snackPosition: SnackPosition.TOP);
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        await _convertImageToBase64(image);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil gambar dari kamera: $e',
          snackPosition: SnackPosition.TOP);
    }
  }

  Future<void> _convertImageToBase64(XFile image) async {
    try {
      Uint8List imageBytes = await image.readAsBytes();
      String base64String = base64Encode(imageBytes);
      selectedImageBase64.value = base64String;
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengkonversi gambar: $e',
          snackPosition: SnackPosition.TOP);
    }
  }

  void removeSelectedImage() {
    selectedImage.value = null;
    selectedImageBase64.value = '';
  }

  void showImageSourceDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Pilih Sumber Gambar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Get.back();
                pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Get.back();
                pickImageFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Mengambil berita dari Firestore
  Future<void> fetchNews() async {
    try {
      isLoading.value = true;
      QuerySnapshot snapshot = await _firestore
          .collection('news')
          .where('isActive', isEqualTo: true)
          .orderBy('publishedAt', descending: true)
          .get();

      news.value = snapshot.docs
          .map((doc) => NewsModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching news: $e');
      Get.snackbar('Error', 'Gagal mengambil data berita: $e',
          snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
  }

  // Buka link berita di browser
  Future<void> openNewsUrl(String url) async {
    try {
      if (url.isEmpty) {
        Get.snackbar('Error', 'URL berita tidak valid',
            snackPosition: SnackPosition.TOP);
        return;
      }

      // Pastikan URL memiliki protokol http atau https
      String formattedUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        formattedUrl = 'https://$url';
      }

      final Uri uri = Uri.parse(formattedUrl);
      
      // Coba gunakan mode in-app browser untuk debugging
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.inAppWebView,  // Coba ubah ke inAppWebView untuk pengujian
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
      } else {
        Get.snackbar('Error', 'Tidak dapat membuka URL: $formattedUrl',
            snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e',
          snackPosition: SnackPosition.TOP);
    }
  }

  // Tambah berita dari link ke Firestore
  Future<void> addNews() async {
    if (!isFormValid.value) {
      Get.snackbar('Error', 'Harap isi semua field yang diperlukan',
          snackPosition: SnackPosition.TOP);
      return;
    }
    try {
      isLoading.value = true;
      final String id = _generateId();
      final NewsModel newsItem = NewsModel(
        id: id,
        title: titleController.text,
        description: descriptionController.text,
        imageUrl: imageUrlController.text,
        imageNews: selectedImageBase64.value.isNotEmpty
            ? selectedImageBase64.value
            : '', // Gunakan base64 image jika ada
        isActive: true,
        newsUrl: newsUrlController.text,
        publishedAt: DateTime.now(),
      );
      await _firestore
          .collection('news')
          .doc(newsItem.id)
          .set(newsItem.toJson());
      // Reset form setelah berhasil tambah berita
      resetForm();
      await fetchNews();
      // Refresh berita
      Get.snackbar('Sukses', 'Berita berhasil ditambahkan',
          snackPosition: SnackPosition.TOP);
      // Kembali ke halaman sebelumnya
      Get.to(() => const NewsView());
    } catch (e) {
      print('Error adding news: $e');
      Get.snackbar('Error', 'Gagal menambahkan berita: $e',snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
  }

  // Tambah berita manual ke Firestore
  Future<void> addManualNews() async {
    if (!isManualFormValid.value) {
      Get.snackbar('Error', 'Harap isi judul dan deskripsi',
          snackPosition: SnackPosition.TOP);
      return;
    }

    try {
      isLoading.value = true;

      final String id = _generateId();
      
      // Buat data berita manual
      Map<String, dynamic> newsData = {
        'id': id,
        'title': manualTitleController.text,
        'description': manualDescriptionController.text,
        'publishedAt': Timestamp.fromDate(DateTime.now()),
        'isActive': true,
        'isManual': true, // Flag untuk membedakan berita manual
      };

      // Tambahkan base64 image jika ada
      if (selectedImageBase64.value.isNotEmpty) {
        newsData['imageNews'] = selectedImageBase64.value;
      }

      await _firestore.collection('news').doc(id).set(newsData);

      // Reset form setelah berhasil tambah berita
      resetManualForm();

      // Refresh berita
      await fetchNews();

      Get.snackbar('Sukses', 'Berita manual berhasil ditambahkan',
          snackPosition: SnackPosition.TOP);

      // Kembali ke halaman sebelumnya
      Get.to(() => const NewsView());
    } catch (e) {
      print('Error adding manual news: $e');
      Get.snackbar('Error', 'Gagal menambahkan berita manual: $e',
          snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
  }

  // Hapus berita secara permanen
  Future<void> hardDeleteNews(String id) async {
    try {
      await _firestore.collection('news').doc(id).delete();
      news.removeWhere((item) => item.id == id);
      Get.snackbar('Sukses', 'Berita berhasil dihapus permanen',
          snackPosition: SnackPosition.TOP);
    } catch (e) {
      print('Error hard deleting news: $e');
      Get.snackbar('Error', 'Gagal menghapus berita secara permanen: $e',
          snackPosition: SnackPosition.TOP);
    }
  }
}