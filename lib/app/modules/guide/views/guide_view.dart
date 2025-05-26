import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/guide_controller.dart';

class GuideView extends GetView<GuideController> {
  const GuideView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Definisikan warna tema
    final Color primaryBlueGrey = Colors.blueGrey;
    final Color cardGrey = Colors.grey.shade200;
    final Color borderGrey = Colors.grey.shade400;
    final Color stepCircle = Colors.blueGrey;
    final Color expansionTileBg = Colors.blueGrey.shade50;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: primaryBlueGrey,
        title: const Text(
          'Panduan Penggunaan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.guideItems.length,
        itemBuilder: (context, index) {
          final item = controller.guideItems[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            color: cardGrey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: borderGrey, width: 1),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                splashColor: Colors.blueGrey.shade100,
                highlightColor: Colors.blueGrey.shade50,
                colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: primaryBlueGrey,
                      secondary: Colors.blueGrey,
                    ),
              ),
              child: ExpansionTile(
                backgroundColor: expansionTileBg,
                collapsedBackgroundColor: cardGrey,
                leading: CircleAvatar(
                  backgroundColor: primaryBlueGrey,
                  child: Icon(
                    _getIconForTitle(item['title']),
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  item['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: primaryBlueGrey,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Langkah-langkah:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.blueGrey.shade900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(
                          item['steps'].length,
                          (stepIndex) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: stepCircle,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.blueGrey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${stepIndex + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    item['steps'][stepIndex],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blueGrey.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      // Tombol bantuan mengambang di pojok kanan bawah, lebih menarik dari navbar
      floatingActionButton: Tooltip(
        message: 'Tanya Admin',
        child: FloatingActionButton.extended(
          onPressed: () {
            // Navigasi ke fitur chat
            Get.toNamed('/chat-list');
          },
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.help_outline),
          label: const Text(
            'Butuh Bantuan?',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title) {
      case 'Panduan Pengaduan':
        return Icons.report_problem;
      case 'Panduan Chat':
        return Icons.chat;
      case 'Memantau Progress':
        return Icons.track_changes;
      case 'Berita dan Informasi':
        return Icons.newspaper;
      default:
        return Icons.help;
    }
  }
}
