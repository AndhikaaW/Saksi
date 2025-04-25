import 'package:cloud_firestore/cloud_firestore.dart';

class Complaint {
  final String uid;
  final String emailPelapor;
  final String namaPelapor;
  final String noTeleponPelapor;
  final String domisiliPelapor;
  final String jenisKelaminPelapor;
  final String jenisKekerasanSeksual;
  final String noTeleponPihakLain;

  // Kejadian
  final String ceritaSingkatPeristiwa;
  final String keteranganDisabilitas;
  final String alasanPengaduan;
  final String alasanPengaduanLainnya;
  final String identifikasiKebutuhan;
  final String identifikasiKebutuhanLainnya;

  // Terlapor
  final String statusTerlapor;
  final String jenisKelaminTerlapor;

  // Umum
  final int statusPengaduan;
  final List<ProgressItem> progress;
  final Timestamp tanggalPelaporan;

  Complaint({
    required this.uid,
    required this.emailPelapor,
    required this.namaPelapor,
    required this.noTeleponPelapor,
    required this.domisiliPelapor,
    required this.jenisKelaminPelapor,
    required this.jenisKekerasanSeksual,
    required this.noTeleponPihakLain,
    required this.ceritaSingkatPeristiwa,
    required this.keteranganDisabilitas,
    required this.alasanPengaduan,
    required this.alasanPengaduanLainnya,
    required this.identifikasiKebutuhan,
    required this.identifikasiKebutuhanLainnya,
    required this.statusTerlapor,
    required this.jenisKelaminTerlapor,
    required this.statusPengaduan,
    required this.progress,
    required this.tanggalPelaporan,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      uid: json['uid'] ?? '',
      emailPelapor: json['emailPelapor'] ?? '',
      namaPelapor: json['namaPelapor'] ?? '',
      noTeleponPelapor: json['noTeleponPelapor'] ?? '',
      domisiliPelapor: json['domisiliPelapor'] ?? '',
      jenisKelaminPelapor: json['jenisKelaminPelapor'] ?? '',
      jenisKekerasanSeksual: json['jenisKekerasanSeksual'] ?? '',
      noTeleponPihakLain: json['noTeleponPihakLain'] ?? '',
      ceritaSingkatPeristiwa: json['ceritaSingkatPeristiwa'] ?? '',
      keteranganDisabilitas: json['keteranganDisabilitas'] ?? '',
      alasanPengaduan: json['alasanPengaduan'] ?? '',
      alasanPengaduanLainnya: json['alasanPengaduanLainnya'] ?? '',
      identifikasiKebutuhan: json['identifikasiKebutuhan'] ?? '',
      identifikasiKebutuhanLainnya: json['identifikasiKebutuhanLainnya'] ?? '',
      statusTerlapor: json['statusTerlapor'] ?? '',
      jenisKelaminTerlapor: json['jenisKelaminTerlapor'] ?? '',
      statusPengaduan: json['statusPengaduan'] ?? '',
      tanggalPelaporan: json['tanggalPelaporan']?? '',
      progress: (json['progress'] as List<dynamic>?)
          ?.map((item) => ProgressItem.fromJson(item))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'emailPelapor': emailPelapor,
      'namaPelapor': namaPelapor,
      'noTeleponPelapor': noTeleponPelapor,
      'domisiliPelapor': domisiliPelapor,
      'jenisKelaminPelapor': jenisKelaminPelapor,
      'jenisKekerasanSeksual': jenisKekerasanSeksual,
      'noTeleponPihakLain': noTeleponPihakLain,
      'ceritaSingkatPeristiwa': ceritaSingkatPeristiwa,
      'keteranganDisabilitas': keteranganDisabilitas,
      'alasanPengaduan': alasanPengaduan,
      'alasanPengaduanLainnya': alasanPengaduanLainnya,
      'identifikasiKebutuhan': identifikasiKebutuhan,
      'identifikasiKebutuhanLainnya': identifikasiKebutuhanLainnya,
      'statusTerlapor': statusTerlapor,
      'jenisKelaminTerlapor': jenisKelaminTerlapor,
      'statusPengaduan': statusPengaduan,
      'tanggalPelaporan': tanggalPelaporan,
      'progress': progress.map((e) => e.toJson()).toList(),
    };
  }
}

class ProgressItem {
  final String title;
  final String description;
  final String date;

  ProgressItem({
    required this.title, 
    required this.description,
    required this.date,
  });

  factory ProgressItem.fromJson(Map<String, dynamic> json) {
    // Handle jika field date/timestamp berbeda
    String dateValue = '';
    if (json['date'] != null) {
      dateValue = json['date'];
    } else if (json['timestamp'] != null) {
      dateValue = json['timestamp']; 
    }

    return ProgressItem(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: dateValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'date': date,
    };
  }
}
