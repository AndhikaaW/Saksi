import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saksi_app/app/modules/progresComplaint/views/progresTab.dart';
import 'package:saksi_app/app/modules/progresComplaint/views/riwayatTab.dart';
import '../controllers/progres_complaint_controller.dart';

class ProgresComplaintView extends GetView<ProgresComplaintController> {
  const ProgresComplaintView({super.key});
  @override
  Widget build(BuildContext context) {
    // Menambahkan jarak (padding) dari app bar ke atas dengan PreferredSize dan SafeArea
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50), // tinggi appbar + tabbar
          child: SafeArea(
            child: AppBar(
              automaticallyImplyLeading: true,
              elevation: 0,
              backgroundColor: Colors.grey[200],
              titleSpacing: 0,
              title: const SizedBox.shrink(),
              flexibleSpace: const Padding(
                padding: EdgeInsets.only(top: 0), // jarak dari atas
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: TabBar(
                    labelColor: Colors.blueGrey,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.blueGrey,
                    tabs: [
                      Tab(
                        child: Text(
                          'Progress Aduan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                      Tab(
                        child: Text(
                          'Riwayat',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: const TabBarView(
          physics: AlwaysScrollableScrollPhysics(),
          children: [
            ProgresTabView(),
            RiwayatTab(),
          ],
        ),
        backgroundColor: Colors.grey[200],
      ),
    );
  }
}
