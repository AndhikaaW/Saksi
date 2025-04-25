import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/dashboard_superadmin_controller.dart';

class DashboardSuperadminView extends GetView<DashboardSuperadminController> {
  const DashboardSuperadminView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Text(controller.currentTitle)),
          ],
        ),
      ),

      body: Obx(() => controller.tabPages[controller.currentIndex.value]),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.currentIndex.value,
        onTap: controller.changeTab,
        items: const [
          BottomNavigationBarItem(
              label: 'Utama',
              icon: Icon(Icons.home)
          ),
          BottomNavigationBarItem(
              label: 'Chat',
              icon: Icon(Icons.chat)
          ),
          BottomNavigationBarItem(
              label: 'Profile',
              icon: Icon(Icons.person)
          )
        ],
      )),
    );
  }
}
