import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/dashboard_user_controller.dart';

class DashboardUserView extends GetView<DashboardUserController> {
  const DashboardUserView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
        // title: Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     Obx(() => Text(controller.currentTitle)),
        //   ],
        // ),
      // ),


      body: Obx(() => controller.tabPages[controller.currentIndex.value]),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        selectedItemColor: Colors.blueGrey,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        currentIndex: controller.currentIndex.value,
        onTap: controller.changeTab,
        items: const [
          BottomNavigationBarItem(
              label: 'Utama',
              icon: Icon(Icons.home),
              activeIcon: Icon(Icons.home, color: Colors.blueGrey),
          ),
          BottomNavigationBarItem(
              label: 'Progres Aduan',
              icon: Icon(Icons.history),
              activeIcon: Icon(Icons.history, color: Colors.blueGrey),
          ),
          BottomNavigationBarItem(
              label: 'Profil',
              icon: Icon(Icons.person),
              activeIcon: Icon(Icons.person, color: Colors.blueGrey),
          )
        ],
      )),
    );
  }
}
