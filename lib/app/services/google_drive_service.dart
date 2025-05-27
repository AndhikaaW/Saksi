import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';

class GoogleDriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/drive.file',
      'https://www.googleapis.com/auth/drive.appdata',
      'https://www.googleapis.com/auth/drive',
    ],
  );

  GoogleSignInAccount? _currentUser;
  String? _appFolderId;

  Future<GoogleSignInAccount?> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      if (_currentUser != null) {
        await _createOrGetAppFolder();
      }
      return _currentUser;
    } catch (error) {
      print('Error signing in: $error');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _appFolderId = null;
  }

  Future<void> _createOrGetAppFolder() async {
    try {
      final authHeaders = await _currentUser!.authHeaders;
      final client = GoogleHttpClient(authHeaders);
      final drive = ga.DriveApi(client);

      // Cari folder aplikasi yang sudah ada
      final result = await drive.files.list(
        q: "name='SaksiApp' and mimeType='application/vnd.google-apps.folder' and trashed=false",
        spaces: 'drive',
      );

      if (result.files != null && result.files!.isNotEmpty) {
        _appFolderId = result.files!.first.id;
      } else {
        // Buat folder baru jika belum ada
        final folder = ga.File()
          ..name = 'SaksiApp'
          ..mimeType = 'application/vnd.google-apps.folder';

        final createdFolder = await drive.files.create(folder);

        _appFolderId = createdFolder.id;

        // Set akses folder ke "anyone with the link"
        if (_appFolderId != null) {
          final permission = ga.Permission()
            ..type = 'anyone'
            ..role = 'reader'
            ..allowFileDiscovery = false;
          await drive.permissions.create(
            permission,
            _appFolderId!,
            supportsAllDrives: true,
          );
        }
      }
    } catch (error) {
      print('Error creating/getting app folder: $error');
      rethrow;
    }
  }

  /// Upload banyak file ke folder aplikasi
  /// Return: List id file yang berhasil diupload
  Future<List<String>?> uploadFiles() async {
    try {
      if (_currentUser == null) {
        _currentUser = await signIn();
        if (_currentUser == null) return null;
      }

      // Pilih banyak file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) return null;

      // Buat client untuk Google Drive API
      final authHeaders = await _currentUser!.authHeaders;
      final client = GoogleHttpClient(authHeaders);
      final drive = ga.DriveApi(client);

      List<String> uploadedFileIds = [];

      for (var pickedFile in result.files) {
        if (pickedFile.path == null) continue;
        final file = File(pickedFile.path!);
        final fileStream = file.openRead();
        final fileLength = await file.length();

        // Buat metadata file
        final fileMetadata = ga.File()
          ..name = path.basename(file.path)
          ..parents = [_appFolderId ?? 'root'];

        // Upload file
        final response = await drive.files.create(
          fileMetadata,
          uploadMedia: ga.Media(fileStream, fileLength),
        );

        if (response.id != null) {
          uploadedFileIds.add(response.id!);
        }
      }

      return uploadedFileIds;
    } catch (error) {
      print('Error uploading files: $error');
      return null;
    }
  }

  /// Mendapatkan link share Google Drive folder berdasarkan folderId
  /// Jika folderId null, akan pakai _appFolderId
  Future<String?> getFolderShareLink({String? folderId}) async {
    try {
      if (_currentUser == null) {
        _currentUser = await signIn();
        if (_currentUser == null) return null;
      }
      final id = folderId ?? _appFolderId;
      if (id == null) return null;

      // Pastikan permission sudah di-set ke anyone with the link
      final authHeaders = await _currentUser!.authHeaders;
      final client = GoogleHttpClient(authHeaders);
      final drive = ga.DriveApi(client);

      // Cek permission, jika belum ada, set permission
      final permissions = await drive.permissions.list(id, supportsAllDrives: true);
      final anyonePermission = permissions.permissions?.firstWhere(
        (perm) => perm.type == 'anyone',
        orElse: () => ga.Permission(),
      );
      if (anyonePermission == null || anyonePermission.type != 'anyone') {
        final permission = ga.Permission()
          ..type = 'anyone'
          ..role = 'reader'
          ..allowFileDiscovery = false;
        await drive.permissions.create(
          permission,
          id,
          supportsAllDrives: true,
        );
      }

      // Generate link folder
      return "https://drive.google.com/drive/folders/$id";
    } catch (e) {
      print('Gagal mendapatkan link folder Google Drive: $e');
      return null;
    }
  }
}

class GoogleHttpClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleHttpClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}
