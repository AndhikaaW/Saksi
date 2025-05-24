import 'package:get/get.dart';

class GuideController extends GetxController {
  final List<Map<String, dynamic>> guideItems = [
    {
      'title': 'Panduan Pengaduan',
      // 'icon': 'assets/icons/complaint.png',
      'steps': [
        'Klik tombol "Buat Pengaduan" di halaman utama',
        'Isi formulir pengaduan dengan lengkap dan jelas',
        'Lampirkan bukti pendukung jika ada',
        'Klik "Kirim" untuk mengirimkan pengaduan',
        'Anda dapat memantau status pengaduan di halaman "Riwayat Pengaduan"'
      ]
    },
    {
      'title': 'Panduan Chat',
      // 'icon': 'assets/icons/chat.png',
      'steps': [
        'Buka menu "Chat" di halaman utama',
        'Pilih admin yang ingin Anda ajak berkomunikasi',
        'Ketik pesan Anda di kolom chat',
        'Kirim pesan dengan menekan tombol kirim',
        'Anda akan menerima notifikasi ketika ada pesan baru'
      ]
    },
    {
      'title': 'Memantau Progress',
      // 'icon': 'assets/icons/progress.png',
      'steps': [
        'Buka halaman "Riwayat Pengaduan"',
        'Pilih pengaduan yang ingin Anda pantau',
        'Lihat status pengaduan di bagian atas',
        'Scroll ke bawah untuk melihat detail progress',
        'Anda akan menerima notifikasi setiap ada update status'
      ]
    },
    {
      'title': 'Berita dan Informasi',
      // 'icon': 'assets/icons/news.png',
      'steps': [
        'Buka menu "Berita" di halaman utama',
        'Scroll untuk melihat daftar berita terbaru',
        'Klik berita untuk membaca detail lengkap',
        'Gunakan fitur pencarian untuk mencari berita spesifik',
        'Aktifkan notifikasi untuk mendapatkan update berita terbaru'
      ]
    },
  ].obs;

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

}
