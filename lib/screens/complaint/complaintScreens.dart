import 'package:flutter/material.dart';
import 'package:saksi/services/firestore_services.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({Key? key}) : super(key: key);

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final _dbService = DatabaseService();
  final _namaPelapor = TextEditingController();
  final _noTeleponPelapor = TextEditingController();
  final _jenisKelaminPelapor = TextEditingController();
  final _domisiliPelapor = TextEditingController();
  final _jenisKekerasanSeksual = TextEditingController();
  final _ceritaSingkatPeristiwa = TextEditingController();
  String? _selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulir Penerimaan Laporan'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nama Pelapor (Korban/Saksi)*',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _namaPelapor,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nomor telepon/alamat pos elektronik Pelapor',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noTeleponPelapor,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Jenis kelamin Pelapor',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(

              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Perempuan'),
                    value: 'Perempuan',
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                        _jenisKelaminPelapor.text = value ?? '';
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Laki-laki'),
                    value: 'Laki-laki',
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                        _jenisKelaminPelapor.text = value ?? '';
                      });
                    },
                  ),
                ),
              ],

            ),
            const SizedBox(height: 16),
            const Text(
              'Domisili Pelapor',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _domisiliPelapor,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Jenis Kekerasan Seksual (Silakan Dinarasikan)*',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _jenisKekerasanSeksual,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cerita singkat peristiwa (Memuat waktu, tempat, dan peristiwa)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _ceritaSingkatPeristiwa,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(

                onPressed: () async {
                  if ( _namaPelapor.text.isEmpty || _noTeleponPelapor.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('harap isi semua form'),
                      ),
                    );
                  } else {
                    await _dbService.createComplaint(
                        namaPelapor: _namaPelapor.text,
                        noTeleponPelapor: _noTeleponPelapor.text,
                        domisiliPelapor: _domisiliPelapor.text,
                        jenisKelaminPelapor: _jenisKelaminPelapor.text,
                        jenisKekerasanSeksual: _jenisKekerasanSeksual.text,
                        ceritaSingkatPeristiwa: _ceritaSingkatPeristiwa.text
                    );
                    Navigator.of(context).pop();
                    setState(() {});
                    _namaPelapor.clear();
                    _noTeleponPelapor.clear();
                    _domisiliPelapor.clear();
                    _domisiliPelapor.clear();
                    _jenisKekerasanSeksual.clear();
                    _ceritaSingkatPeristiwa.clear();
                  }
                },
                child: const Text('Kirim Laporan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}