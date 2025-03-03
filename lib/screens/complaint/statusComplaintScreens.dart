import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saksi/services/firestore_services.dart';

class statusComplaintScreens extends StatefulWidget {
  const statusComplaintScreens({super.key});

  @override
  State<statusComplaintScreens> createState() => _statusComplaintScreensState();
}

class _statusComplaintScreensState extends State<statusComplaintScreens> {
  final DatabaseService _databaseService = DatabaseService();
  List<Map<String, String>> complaints = [];

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    List<QueryDocumentSnapshot> docs = await _databaseService.readComplaint();
    List<Map<String, String>> fetchedComplaints = docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return {
        'namaPelapor': data['namaPelapor']?.toString() ?? '',
        'noTeleponPelapor': data['noTeleponPelapor']?.toString() ?? '',
        'domisiliPelapor': data['domisiliPelapor']?.toString() ?? '',
        'jenisKelaminPelapor': data['jenisKelaminPelapor']?.toString() ?? '',
        'jenisKekerasanSeksual': data['jenisKekerasanSeksual']?.toString() ?? '',
        'ceritaSingkatPeristiwa': data['ceritaSingkatPeristiwa']?.toString() ?? '',
      };
    }).toList();

    setState(() {
      complaints = fetchedComplaints;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Pengaduan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pengaduan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (complaints.isEmpty)
              const Center(child: Text('Tidak ada pengaduan saat ini.'))
            else
              ...complaints.map((complaint) {
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(
                      'Pelapor: ${complaint['namaPelapor']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Telepon: ${complaint['noTeleponPelapor']}'),
                        Text('Domisili: ${complaint['domisiliPelapor']}'),
                        Text(
                            'Jenis Kekerasan: ${complaint['jenisKekerasanSeksual']}'),
                        Text(
                            'Cerita Singkat: ${complaint['ceritaSingkatPeristiwa']}'),
                      ],
                    ),
                    trailing: const Icon(Icons.report, color: Colors.red),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
