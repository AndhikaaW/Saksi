import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:saksi_app/app/modules/news/models/news_model.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<NewsModel> news = <NewsModel>[].obs;
  final RxBool isLoading = false.obs;

  // Form controller untuk tambah berita
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final imageUrlController = TextEditingController();
  final newsUrlController = TextEditingController();

  final RxBool isFormValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNews();

    // Listen perubahan pada form untuk validasi
    titleController.addListener(_validateForm);
    descriptionController.addListener(_validateForm);
    newsUrlController.addListener(_validateForm);
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    imageUrlController.dispose();
    newsUrlController.dispose();
    super.onClose();
  }

  void _validateForm() {
    isFormValid.value = titleController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        newsUrlController.text.isNotEmpty;
  }

  void resetForm() {
    titleController.clear();
    descriptionController.clear();
    imageUrlController.clear();
    newsUrlController.clear();
    isFormValid.value = false;
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
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // Buka link berita di browser
  Future<void> openNewsUrl(String url) async {
    try {
      if (url.isEmpty) {
        Get.snackbar('Error', 'URL berita tidak valid',
            snackPosition: SnackPosition.BOTTOM);
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
          mode: LaunchMode
              .inAppWebView, // Coba ubah ke inAppWebView untuk pengujian
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
      } else {
        Get.snackbar('Error', 'Tidak dapat membuka URL: $formattedUrl',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Tambah berita ke Firestore
  Future<void> addNews() async {
    if (!isFormValid.value) {
      Get.snackbar('Error', 'Harap isi semua field yang diperlukan',
          snackPosition: SnackPosition.BOTTOM);
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
        newsUrl: newsUrlController.text,
        publishedAt: DateTime.now(),
      );

      await _firestore
          .collection('news')
          .doc(newsItem.id)
          .set(newsItem.toJson());

      // Reset form setelah berhasil tambah berita
      resetForm();

      // Refresh berita
      await fetchNews();

      Get.snackbar('Sukses', 'Berita berhasil ditambahkan',
          snackPosition: SnackPosition.BOTTOM);

      // Kembali ke halaman sebelumnya
      Get.back();
    } catch (e) {
      print('Error adding news: $e');
      Get.snackbar('Error', 'Gagal menambahkan berita: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // Update berita di Firestore
  Future<void> updateNews(NewsModel newsItem) async {
    try {
      await _firestore
          .collection('news')
          .doc(newsItem.id)
          .update(newsItem.toJson());
      int index = news.indexWhere((item) => item.id == newsItem.id);
      if (index != -1) {
        news[index] = newsItem;
      }
      Get.snackbar('Sukses', 'Berita berhasil diperbarui',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      print('Error updating news: $e');
      Get.snackbar('Error', 'Gagal memperbarui berita: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Hapus berita (soft delete dengan mengubah isActive)
  Future<void> deleteNews(String id) async {
    try {
      await _firestore.collection('news').doc(id).update({'isActive': false});
      news.removeWhere((item) => item.id == id);
      Get.snackbar('Sukses', 'Berita berhasil dihapus',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      print('Error deleting news: $e');
      Get.snackbar('Error', 'Gagal menghapus berita: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Hapus berita secara permanen
  Future<void> hardDeleteNews(String id) async {
    try {
      await _firestore.collection('news').doc(id).delete();
      news.removeWhere((item) => item.id == id);
      Get.snackbar('Sukses', 'Berita berhasil dihapus permanen',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      print('Error hard deleting news: $e');
      Get.snackbar('Error', 'Gagal menghapus berita secara permanen: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
