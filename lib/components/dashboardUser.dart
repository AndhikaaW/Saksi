import 'package:flutter/material.dart';
import 'package:saksi/screens/chatScreens.dart';
import 'package:saksi/screens/complaint/complaintScreens.dart';
import 'package:saksi/services/firestore_services.dart';

class DashboardUser extends StatefulWidget {
  const DashboardUser({super.key});

  @override
  State<DashboardUser> createState() => _DashboardUserState();
}

class _DashboardUserState extends State<DashboardUser> {
  String? userName;

  @override
  void initState() {
    super.initState();
    DatabaseService().loadUserData((name) {
      setState(() {
        userName = name;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xFFF1F1F1),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  // backgroundImage: AssetImage('assets/avatar.png'),
                ),
                const SizedBox(width: 8),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hallo, ${userName?? 'Loading...'}',
                        style: TextStyle(fontSize: 16)),
                    Text(
                      'Lorem Ipsum Lorem Ipsum',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ],
                ),
                Spacer(),
                Icon(Icons.notifications, size: 30),
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
                  color: Colors.grey,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ComplaintScreen())),
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.build,
                  label: 'Chat',
                  color: Colors.grey,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Chatscreens())),
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.settings,
                  label: 'Pengaturan',
                  color: Colors.grey,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Chatscreens())),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Berita Terkini',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
      ),
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
        color: Color(0xFFF1F1F1),
        child: Container(
          width: 100,
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: color),
              SizedBox(height: 8),
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
      child: SizedBox(
        width: 180,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 100, child: Placeholder()),
              SizedBox(height: 8),
              Text('Lorem Ipsum Lorem Ipsum',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(
                'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
