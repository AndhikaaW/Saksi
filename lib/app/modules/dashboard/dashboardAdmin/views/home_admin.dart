import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saksi_app/app/modules/dashboard/dashboardAdmin/controllers/dashboard_admin_controller.dart';
import 'package:saksi_app/app/modules/manageComplaint/views/complaint_list_view.dart';

class HomeTabViewAdmin extends GetView<DashboardAdminController> {
  const HomeTabViewAdmin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.username.toString(),
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // Stats Overview
          _buildStatCards(),
          const SizedBox(height: 24),

          // User Management Menu
          _buildMenuSection(
            title: 'Manajemen Pengguna',
            menus: [
              MenuItemData(
                title: 'Kelola User',
                icon: Icons.people,
                color: Colors.teal.shade700,
                onTap: () => Get.toNamed('/manage-user'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Complaint Management Menu
          _buildMenuSection(
            title: 'Manajemen Pengaduan',
            menus: [
              MenuItemData(
                title: 'Semua Pengaduan',
                icon: Icons.article,
                color: Colors.orange.shade700,
                onTap: () => Get.toNamed('/manage-complaint'),
              ),
              MenuItemData(
                title: 'Menunggu Persetujuan',
                icon: Icons.report_problem_outlined,
                color: Colors.amber.shade700,
                onTap: () => Get.toNamed('/complaint-list',
                    arguments: ComplaintListView(
                        statusFilter: 0, title: 'Menunggu Persetujuan')),
              ),
              MenuItemData(
                title: 'Pengaduan Aktif',
                icon: Icons.pending_actions,
                color: Colors.blue.shade700,
                onTap: () => Get.toNamed('/complaint-list',
                    arguments: ComplaintListView(
                        statusFilter: 1, title: 'Pengaduan Aktif')),
              ),
              MenuItemData(
                title: 'Pengaduan Selesai',
                icon: Icons.check_circle,
                color: Colors.green.shade700,
                onTap: () => Get.toNamed('/complaint-list',
                    arguments: ComplaintListView(
                        statusFilter: 2, title: 'Pengaduan Selesai')),
              ),
              MenuItemData(
                title: 'Pengaduan Ditolak',
                icon: Icons.close,
                color: Colors.red.shade700,
                onTap: () => Get.toNamed('/complaint-list',
                    arguments: ComplaintListView(
                        statusFilter: 3, title: 'Pengaduan Ditolak')),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // System Menu
          _buildMenuSection(
            title: 'Sistem',
            menus: [
              MenuItemData(
                title: 'berita',
                icon: Icons.history,
                color: Colors.indigo.shade700,
                onTap: () => Get.toNamed('/news'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          title: 'Pengaduan Menunggu',
          value: '${controller.pendingComplaints}',
          icon: Icons.pending_actions,
          color: Colors.orange,
        ),
        _buildStatCard(
          title: 'Pengaduan Diproses',
          value: '${controller.processedComplaints}',
          icon: Icons.sync,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'Pengaduan Ditolak',
          value: '${controller.completedComplaints}',
          icon: Icons.cancel,
          color: Colors.red,
        ),
        _buildStatCard(
          title: 'Pengaduan Selesai',
          value: '${controller.completedComplaints}',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<MenuItemData> menus,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: menus.map((menu) {
              return _buildMenuItem(menu);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(MenuItemData menu) {
    return InkWell(
      onTap: menu.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: menu.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                menu.icon,
                color: menu.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                menu.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItemData {
  final String title;
  final IconData icon;
  final Color color;
  final Function() onTap;

  MenuItemData({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
