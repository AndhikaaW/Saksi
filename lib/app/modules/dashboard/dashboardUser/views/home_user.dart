import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saksi_app/app/modules/dashboard/dashboardUser/controllers/dashboard_user_controller.dart';

class HomeTabViewUser extends GetView<DashboardUserController> {
  const HomeTabViewUser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(
            color: Colors.blueGrey,
          ));
        }

        final user = controller.userProfile.value;
        final userData = controller.email.value;

        if (user == null && userData.isEmpty) {
          return const Center(child: Text('User not found.', style: TextStyle(color: Colors.blueGrey)));
        }

        final String userName = user?.name ?? userData;
        final String? userPhoto = user?.photoUrl;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: userPhoto != null
                        ? NetworkImage(userPhoto)
                        : const AssetImage('assets/logoPoltek.png') as ImageProvider,
                  ),
                  const SizedBox(width: 8),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hallo, $userName',
                        style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
                      ),
                      const Text(
                        'Lorem Ipsum Lorem Ipsum',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.notifications, size: 30, color: Colors.blueGrey),
                ],
              ),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildMenuItem(
                    context: context,
                    icon: Icons.receipt_long,
                    label: 'Pengaduan',
                    color: Colors.blueGrey,
                    onTap: () async {
                      if (_isProfileIncomplete() == true) {
                        _showProfileIncompleteDialog(context);
                      } else {
                        // Cek apakah ada pengaduan aktif
                        bool hasActiveComplaint = await Get.find<DashboardUserController>().checkActiveComplaints();
                        if (hasActiveComplaint) {
                          _showActiveComplaintDialog(context);
                        } else {
                          Get.toNamed('/complaint');
                        }
                      }
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.chat,
                    label: 'Chat',
                    color: Colors.blueGrey,
                    onTap: () {
                      Get.toNamed('/chat');
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.settings,
                    label: 'Pengaturan',
                    color: Colors.blueGrey,
                    onTap: () {
                      Get.toNamed('/settings');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Berita Terkini',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildNewsCard(),
                    const SizedBox(width: 12),
                    _buildNewsCard(),
                    const SizedBox(width: 12),
                    _buildNewsCard(),
                    const SizedBox(width: 12),
                    _buildNewsCard(),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: Colors.grey[100],
        child: SizedBox(
          width: 100,
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: Colors.grey[100],
      child: SizedBox(
        width: 180,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 100, child: Placeholder()),
              SizedBox(height: 8),
              Text(
                'Lorem Ipsum Lorem Ipsum',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
              SizedBox(height: 4),
              Text(
                'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
                style: TextStyle(fontSize: 12, color: Colors.blueGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isProfileIncomplete() {
    final user = controller.userProfile.value;
    final userData = controller.email.value;

    if ((user != null && user.name.isNotEmpty && user.gender.isNotEmpty ) ) {
      return false;
    }
    return true;
  }

  void _showProfileIncompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Lengkapi Data Diri", style: TextStyle(color: Colors.blueGrey)),
        content: const Text("Silakan lengkapi data diri Anda sebelum mengakses fitur pengaduan.", style: TextStyle(color: Colors.blueGrey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.blueGrey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.find<DashboardUserController>().changeTab(2);
            },
            child: const Text("Isi Sekarang", style: TextStyle(color: Colors.blueGrey)),
          ),
        ],
      ),
    );
  }

  void _showActiveComplaintDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Pengaduan Aktif", style: TextStyle(color: Colors.blueGrey)),
        content: const Text("Anda masih memiliki pengaduan yang sedang diproses. Silakan tunggu hingga pengaduan selesai sebelum membuat pengaduan baru.", style: TextStyle(color: Colors.blueGrey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.blueGrey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.find<DashboardUserController>().changeTab(1);
            },
            child: const Text("Lihat Progres", style: TextStyle(color: Colors.blueGrey)),
          ),
        ],
      ),
    );
  }
}
