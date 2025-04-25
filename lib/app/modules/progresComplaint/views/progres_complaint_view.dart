import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saksi_app/app/modules/progresComplaint/views/progresTab.dart';
import 'package:saksi_app/app/modules/progresComplaint/views/riwayatTab.dart';
import '../controllers/progres_complaint_controller.dart';

class ProgresComplaintView extends GetView<ProgresComplaintController> {
  const ProgresComplaintView({super.key});


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          // title: const Text('Laporan Pengaduan'),
          flexibleSpace: const TabBar(
            tabs: [
              Tab(text: 'Progress Aduan'),
              Tab(text: 'Riwayat'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ProgresTabView(),
            RiwayatTab(),
          ],
        ),
      ),
    );
  }
}
