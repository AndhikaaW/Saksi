import 'package:cloud_firestore/cloud_firestore.dart';

class Complaint {
  final String complaintId;
  final String uid;
  final String emailPelapor;
  final String namaPelapor;
  final String noTeleponPelapor;
  final String domisiliPelapor;
  final String jenisKelaminPelapor;
  final String bentukKekerasanSeksual;
  final String noTeleponPihakLain;
  final String statusPelapor; 

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
  final String lampiranKtp;
  final String lampiranBukti;

  // Umum
  final int statusPengaduan;
  final List<ProgressItem> progress;
  final Timestamp tanggalPelaporan;

  Complaint({
    required this.complaintId,
    required this.uid,
    required this.emailPelapor,
    required this.namaPelapor,
    required this.noTeleponPelapor,
    required this.domisiliPelapor,
    required this.jenisKelaminPelapor,
    required this.bentukKekerasanSeksual,
    required this.noTeleponPihakLain,
    required this.statusPelapor, 
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
    required this.lampiranKtp,
    required this.lampiranBukti,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      complaintId: json['complaintId'] ?? '',
      uid: json['uid'] ?? '',
      emailPelapor: json['emailPelapor'] ?? '',
      namaPelapor: json['namaPelapor'] ?? '',
      noTeleponPelapor: json['noTeleponPelapor'] ?? '',
      domisiliPelapor: json['domisiliPelapor'] ?? '',
      jenisKelaminPelapor: json['jenisKelaminPelapor'] ?? '',
      bentukKekerasanSeksual: json['bentukKekerasanSeksual'] ?? '',
      noTeleponPihakLain: json['noTeleponPihakLain'] ?? '',
      statusPelapor: json['statusPelapor'] ?? '', 
      ceritaSingkatPeristiwa: json['ceritaSingkatPeristiwa'] ?? '',
      keteranganDisabilitas: json['keteranganDisabilitas'] ?? '',
      alasanPengaduan: json['alasanPengaduan'] ?? '',
      alasanPengaduanLainnya: json['alasanPengaduanLainnya'] ?? '',
      identifikasiKebutuhan: json['identifikasiKebutuhan'] ?? '',
      identifikasiKebutuhanLainnya: json['identifikasiKebutuhanLainnya'] ?? '',
      statusTerlapor: json['statusTerlapor'] ?? '',
      jenisKelaminTerlapor: json['jenisKelaminTerlapor'] ?? '',
      statusPengaduan: json['statusPengaduan'] ?? 0,
      tanggalPelaporan: json['tanggalPelaporan'] ?? '',
      lampiranKtp: json['lampiranKtp'] ?? '',
      lampiranBukti: json['lampiranBukti'] ?? '',
      progress: (json['progress'] as List<dynamic>?)
              ?.map((item) => ProgressItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'complaintId': complaintId,
      'uid': uid,
      'emailPelapor': emailPelapor,
      'namaPelapor': namaPelapor,
      'noTeleponPelapor': noTeleponPelapor,
      'domisiliPelapor': domisiliPelapor,
      'jenisKelaminPelapor': jenisKelaminPelapor,
      'bentukKekerasanSeksual': bentukKekerasanSeksual,
      'noTeleponPihakLain': noTeleponPihakLain,
      'statusPelapor': statusPelapor, 
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
      'lampiranKtp': lampiranKtp,
      'lampiranBukti': lampiranBukti,
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
