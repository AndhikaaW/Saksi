import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:excel/excel.dart';
// import 'package:share_plus/share_plus.dart';

class BackupController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Status backup
  final RxString lastBackupTime = 'Belum ada backup'.obs;

  // Loading states
  final RxBool isUserBackupLoading = false.obs;
  final RxBool isAdminBackupLoading = false.obs;
  final RxBool isComplaintBackupLoading = false.obs;
  final RxBool isFullBackupLoading = false.obs;
  final RxBool isRestoreLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLastBackup();
    _requestPermissions();
  }

  // Meminta izin penyimpanan
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
      
      // Untuk Android 11 ke atas
      if (await Permission.manageExternalStorage.isGranted) {
        await Permission.manageExternalStorage.request();
      }
    }
  }

  // Mendapatkan direktori backup
  Future<Directory?> _getBackupDirectory() async {
    Directory? backupDir;
    
    if (Platform.isAndroid) {
      // Gunakan direktori Download untuk Android
      final downloadsDir = Directory('/storage/emulated/0/Download/SaksiAppBackups');
      backupDir = downloadsDir;
      
      // Jika tidak bisa mengakses direktori Download, gunakan fallback
      // if (!await downloadsDir.exists() && !(await downloadsDir.create(recursive: true)).exists()) {
      //   // Fallback ke direktori eksternal
      //   final externalDir = await getExternalStorageDirectory();
      //   if (externalDir != null) {
      //     backupDir = Directory('${externalDir.path}/SaksiAppBackups');
      //   } else {
      //     // Fallback ke direktori aplikasi jika eksternal tidak tersedia
      //     final appDir = await getApplicationDocumentsDirectory();
      //     backupDir = Directory('${appDir.path}/backups');
      //   }
      // }
    } else {
      // Untuk iOS dan platform lain
      final appDir = await getApplicationDocumentsDirectory();
      backupDir = Directory('${appDir.path}/backups');
    }
    
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    
    return backupDir;
  }

  // Memeriksa waktu backup terakhir
  void checkLastBackup() async {
    try {
      final backupDir = await _getBackupDirectory();
      if (backupDir != null && await backupDir.exists()) {
        final files = backupDir.listSync();
        if (files.isNotEmpty) {
          // Urutkan file berdasarkan waktu modifikasi terbaru
          files.sort((a, b) => File(b.path)
              .lastModifiedSync()
              .compareTo(File(a.path).lastModifiedSync()));

          final lastBackup = File(files.first.path).lastModifiedSync();
          final formatter = DateFormat('dd MMM yyyy, HH:mm');
          lastBackupTime.value = formatter.format(lastBackup);
        }
      }
    } catch (e) {
      print('Error checking last backup: $e');
    }
  }

  // Backup data pengguna
  Future<void> backupUsers() async {
    isUserBackupLoading.value = true;
    try {
      final snapshot = await _firestore.collection('users').get();
      final data = snapshot.docs.map((doc) => doc.data()).toList();

      final filePath = await _saveBackupFileExcel('users_backup', data);

      Get.snackbar('Berhasil', 'Backup data pengguna berhasil disimpan di $filePath',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);

      checkLastBackup();
      
      // Bagikan file
      // await Share.shareFiles([filePath], text: 'Backup data pengguna');
    } catch (e) {
      Get.snackbar('Gagal', 'Backup data pengguna gagal: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUserBackupLoading.value = false;
    }
  }

  // Backup data admin
  Future<void> backupAdmins() async {
    isAdminBackupLoading.value = true;
    try {
      final snapshot = await _firestore.collection('users').where('status', isEqualTo: 1).get();
      final data = snapshot.docs.map((doc) => doc.data()).toList();

      final filePath = await _saveBackupFileExcel('admins_backup', data);

      Get.snackbar('Berhasil', 'Backup data admin berhasil disimpan di $filePath',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);

      checkLastBackup();
      
      // Bagikan file
      // await Share.shareFiles([filePath], text: 'Backup data admin');
    } catch (e) {
      Get.snackbar('Gagal', 'Backup data admin gagal: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isAdminBackupLoading.value = false;
    }
  }

  // Backup data pengaduan
  Future<void> backupComplaints() async {
    isComplaintBackupLoading.value = true;
    try {
      final snapshot = await _firestore.collection('complaints').get();
      final data = snapshot.docs.map((doc) => doc.data()).toList();

      final filePath = await _saveBackupFileExcel('complaints_backup', data);

      Get.snackbar('Berhasil', 'Backup data pengaduan berhasil disimpan di $filePath',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);

      checkLastBackup();
      
      // Bagikan file
      // await Share.shareFiles([filePath], text: 'Backup data pengaduan');
    } catch (e) {
      Get.snackbar('Gagal', 'Backup data pengaduan gagal: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isComplaintBackupLoading.value = false;
    }
  }

  // Backup semua data
  Future<void> backupAllData() async {
    isFullBackupLoading.value = true;
    try {
      // Backup users
      final usersSnapshot = await _firestore.collection('users').get();
      final usersData = usersSnapshot.docs.map((doc) => doc.data()).toList();

      // Backup admins
      final adminsSnapshot = await _firestore.collection('users').where('status', isEqualTo: 1).get();
      final adminsData = adminsSnapshot.docs.map((doc) => doc.data()).toList();

      // Backup complaints
      final complaintsSnapshot =
          await _firestore.collection('complaints').get();
      final complaintsData =
          complaintsSnapshot.docs.map((doc) => doc.data()).toList();

      // Buat file excel dengan multiple sheet
      final filePath = await _saveFullBackupExcel({
        'users': usersData,
        'admins': adminsData,
        'complaints': complaintsData,
      });

      Get.snackbar('Berhasil', 'Backup semua data berhasil disimpan di $filePath',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);

      checkLastBackup();
      
      // Bagikan file
      // await Share.shareFiles([filePath], text: 'Backup semua data aplikasi');
    } catch (e) {
      Get.snackbar('Gagal', 'Backup semua data gagal: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isFullBackupLoading.value = false;
    }
  }

  // Menyimpan file backup dalam format Excel
  Future<String> _saveBackupFileExcel(String fileName, List<dynamic> data) async {
    try {
      final backupDir = await _getBackupDirectory();
      if (backupDir == null) {
        throw Exception('Tidak dapat mengakses penyimpanan');
      }

      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${backupDir.path}/${fileName}_$timestamp.xlsx';

      // Buat objek Excel
      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      // Jika data tidak kosong, tambahkan header berdasarkan kunci dari data pertama
      if (data.isNotEmpty) {
        final headers = data.first.keys.toList();

        // Tambahkan header
        for (var i = 0; i < headers.length; i++) {
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
              .value = headers[i];
        }

        // Tambahkan data
        for (var rowIndex = 0; rowIndex < data.length; rowIndex++) {
          final rowData = data[rowIndex];
          for (var colIndex = 0; colIndex < headers.length; colIndex++) {
            final key = headers[colIndex];
            var value = rowData[key];

            // Konversi tipe data khusus
            if (value is Timestamp) {
              value = DateFormat('yyyy-MM-dd HH:mm:ss').format(value.toDate());
            } else if (value is DateTime) {
              value = DateFormat('yyyy-MM-dd HH:mm:ss').format(value);
            } else if (value is Map || value is List) {
              value = jsonEncode(value);
            }

            sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: colIndex, rowIndex: rowIndex + 1))
                .value = value?.toString() ?? '';
          }
        }
      }

      // Simpan file Excel
      final fileBytes = excel.save();
      if (fileBytes != null) {
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);
        
        print('File backup disimpan di: $filePath');
        return filePath;
      } else {
        throw Exception('Gagal menghasilkan file Excel');
      }
    } catch (e) {
      throw Exception('Gagal menyimpan file backup Excel: $e');
    }
  }

  // Menyimpan full backup dalam format Excel dengan multiple sheet
  Future<String> _saveFullBackupExcel(
      Map<String, List<dynamic>> collections) async {
    try {
      final backupDir = await _getBackupDirectory();
      if (backupDir == null) {
        throw Exception('Tidak dapat mengakses penyimpanan');
      }
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${backupDir.path}/full_backup_$timestamp.xlsx';
      final excel = Excel.createExcel();
      excel.delete('Sheet1');
      collections.forEach((collectionName, data) {
        final sheet = excel[collectionName];
        if (data.isNotEmpty) {
          final headers = data.first.keys.toList();
          for (var i = 0; i < headers.length; i++) {
            sheet
                .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
                .value = headers[i];
          }
          for (var rowIndex = 0; rowIndex < data.length; rowIndex++) {
            final rowData = data[rowIndex];
            for (var colIndex = 0; colIndex < headers.length; colIndex++) {
              final key = headers[colIndex];
              var value = rowData[key];

              // Konversi tipe data khusus
              if (value is Timestamp) {
                value =
                    DateFormat('yyyy-MM-dd HH:mm:ss').format(value.toDate());
              } else if (value is DateTime) {
                value = DateFormat('yyyy-MM-dd HH:mm:ss').format(value);
              } else if (value is Map || value is List) {
                value = jsonEncode(value);
              }
              sheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: colIndex, rowIndex: rowIndex + 1))
                  .value = value?.toString() ?? '';
            }
          }
        }
      });
      final infoSheet = excel['Info'];
      infoSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = 'Backup Date';
      infoSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      // Simpan file Excel
      final fileBytes = excel.save();
      if (fileBytes != null) {
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);
        print('File backup lengkap disimpan di: $filePath');
        return filePath;
      } else {
        throw Exception('Gagal menghasilkan file Excel');
      }
    } catch (e) {
      throw Exception('Gagal menyimpan file backup Excel: $e');
    }
  }
}
