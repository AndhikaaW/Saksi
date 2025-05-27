import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/backup_controller.dart';

class BackupView extends GetView<BackupController> {
  const BackupView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup Data',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status Backup',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Backup terakhir: ${controller.lastBackupTime.value}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Backup Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            
            // Backup Options
            _buildBackupCard(
              title: 'Backup Data Pengguna',
              description: 'Backup semua data pengguna aplikasi',
              icon: Icons.people,
              color: Colors.blue.shade700,
              isLoading: controller.isUserBackupLoading.value,
              onTap: () => controller.backupUsers(),
            ),
            
            const SizedBox(height: 12),
            
            _buildBackupCard(
              title: 'Backup Data Admin',
              description: 'Backup semua data admin aplikasi',
              icon: Icons.admin_panel_settings,
              color: Colors.purple.shade700,
              isLoading: controller.isAdminBackupLoading.value,
              onTap: () => controller.backupAdmins(),
            ),
            
            const SizedBox(height: 12),
            
            _buildBackupCard(
              title: 'Backup Data Pengaduan',
              description: 'Backup semua data pengaduan yang ada',
              icon: Icons.report_problem,
              color: Colors.orange.shade700,
              isLoading: controller.isComplaintBackupLoading.value,
              onTap: () => controller.backupComplaints(),
            ),
            
            const SizedBox(height: 12),
            
            _buildBackupCard(
              title: 'Backup Semua Data',
              description: 'Backup seluruh data aplikasi sekaligus',
              icon: Icons.backup,
              color: Colors.green.shade700,
              isLoading: controller.isFullBackupLoading.value,
              onTap: () => controller.backupAllData(),
            ),
            
            const SizedBox(height: 24),
          ],
        )),
      ),
    );
  }

  Widget _buildBackupCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey.shade400,
                        size: 16,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
