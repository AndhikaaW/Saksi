import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:get/get.dart';
// import 'package:http/http.dart';
import 'package:saksi_app/app/modules/dashboard/dashboardUser/controllers/dashboard_user_controller.dart';
import 'package:intl/intl.dart';
import 'package:saksi_app/app/modules/news/views/news_detail_view.dart';
import 'package:saksi_app/app/modules/news/controllers/news_controller.dart';

class HomeTabViewUser extends GetView<DashboardUserController> {
  const HomeTabViewUser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(
            color: Colors.blueGrey,
          ));
        }

        final user = controller.userProfile.value;
        final userData = controller.email.value;

        if (user == null && userData.isEmpty) {
          return const Center(
              child: Text('User not found.',
                  style: TextStyle(color: Colors.blueGrey)));
        }

        final String userName = user?.name ?? userData;
        final String? userPhoto = user?.photoUrl;

        return RefreshIndicator(
          onRefresh: () async {
            // Refresh data saat pengguna menarik ke bawah
            await controller.fetchUserProfile();
            await controller.fetchLatestNews();
            await controller.fetchAdminUsers();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 30),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card utama seperti saldo rekening
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 16),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(
                                top: 10, bottom: 10, left: 10, right: 10),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                userPhoto != null && userPhoto.isNotEmpty
                                    ? (userPhoto.startsWith('http')
                                        // Jika link (dari Google, dsb)
                                        ? CircleAvatar(
                                            radius: 30,
                                            backgroundColor: Colors.blueGrey.shade200,
                                            backgroundImage:
                                                NetworkImage(userPhoto),
                                          )
                                        // Jika base64
                                        : CircleAvatar(
                                            radius: 30,
                                            backgroundColor: Colors.blueGrey.shade200,
                                            backgroundImage: MemoryImage(
                                                base64Decode(userPhoto.replaceFirst(
                                                    RegExp(
                                                        r'data:image/[^;]+;base64,'),
                                                    ''))),
                                          ))
                                    : CircleAvatar(
                                        radius: 30,
                                        backgroundColor:
                                            Colors.blueGrey.shade200,
                                        child: Text(
                                          userName.isNotEmpty
                                              ? userName[0].toUpperCase()
                                              : '',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hallo, $userName',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.blueGrey.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        userData,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.blueGrey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.notifications,
                                      size: 30, color: Colors.blueGrey),
                                  onPressed: () {
                                    // Aksi notifikasi
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Menu-menu di dalam card
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMenuItem(
                                context: context,
                                icon: Icons.receipt_long,
                                label: 'Pengaduan',
                                color: Colors.blueGrey
                                    .shade700, // warna biru grey yang lebih soft
                                onTap: () async {
                                  if (_isProfileIncomplete() == true) {
                                    _showProfileIncompleteDialog(context);
                                  } else {
                                    bool hasActiveComplaint = await Get.find<
                                            DashboardUserController>()
                                        .checkActiveComplaints();
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
                                color: Colors.blueGrey
                                    .shade700, // hijau diganti ke bluegrey agar tidak terlalu kontras
                                onTap: () {
                                  Get.toNamed('/chat-list');
                                },
                              ),
                              _buildMenuItem(
                                context: context,
                                icon: Icons.book,
                                label: 'Panduan',
                                color: Colors.blueGrey
                                    .shade700, // oranye diganti ke bluegrey yang lebih muda
                                onTap: () {
                                  Get.toNamed('/guide');
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Struktur Satgas PPKS',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(
                        child:
                            CircularProgressIndicator(color: Colors.blueGrey),
                      );
                    }

                    if (controller.admins.isEmpty) {
                      return const Center(
                        child: Text(
                          'Tidak ada data struktur Satgas PPKS',
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      );
                    }

                    // Tentukan berapa admin yang ditampilkan di baris utama
                    int jumlahTampil = controller.admins.length >= 3 ? 3 : controller.admins.length;

                    return Card(
                      elevation: 4,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Baris horizontal admin utama
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                jumlahTampil,
                                (index) {
                                  final admin = controller.admins[index];
                                  return GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            title: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 24,
                                                  backgroundColor:
                                                      Colors.blueGrey[100],
                                                  backgroundImage: (admin[
                                                                  'photoUrl'] !=
                                                              null &&
                                                          admin['photoUrl'] !=
                                                              '')
                                                      ? (admin['photoUrl']
                                                              .toString()
                                                              .startsWith(
                                                                  'http')
                                                          // Jika link (dari Google, dsb)
                                                          ? NetworkImage(
                                                              admin['photoUrl'])
                                                          // Jika base64
                                                          : MemoryImage(base64Decode(admin[
                                                                      'photoUrl']
                                                                  .toString()
                                                                  .replaceFirst(
                                                                      RegExp(
                                                                          r'data:image/[^;]+;base64,'),
                                                                      '')))
                                                              as ImageProvider)
                                                      : null,
                                                  child: (admin['photoUrl'] ==
                                                              null ||
                                                          admin['photoUrl'] ==
                                                              '')
                                                      ? Text(
                                                          (admin['name'] ?? '-')
                                                                  .toString()
                                                                  .isNotEmpty
                                                              ? (admin['name'] ??
                                                                      '-')[0]
                                                                  .toUpperCase()
                                                              : '-',
                                                          style:
                                                              const TextStyle(
                                                            color:
                                                                Colors.blueGrey,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18,
                                                          ),
                                                        )
                                                      : null,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    admin['name'] ?? '-',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blueGrey,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(Icons.badge,
                                                        color: Colors.blueGrey,
                                                        size: 20),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        admin['status'] ?? '-',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              Colors.blueGrey,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 12),
                                                if (admin['email'] != null &&
                                                    admin['email'] != '')
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.email,
                                                          color:
                                                              Colors.blueGrey,
                                                          size: 20),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          admin['email'],
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                Colors.blueGrey,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                if (admin['phone'] != null &&
                                                    admin['phone'] != '')
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 12.0),
                                                    child: Row(
                                                      children: [
                                                        const Icon(Icons.phone,
                                                            color:
                                                                Colors.blueGrey,
                                                            size: 20),
                                                        const SizedBox(
                                                            width: 8),
                                                        Expanded(
                                                          child: Text(
                                                            admin['phone'],
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                              color: Colors
                                                                  .blueGrey,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Get.toNamed('/chat-list');
                                                },
                                                child: const Text('Hubungi',
                                                    style: TextStyle(
                                                        color:
                                                            Colors.blueGrey)),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Tutup',
                                                    style: TextStyle(
                                                        color:
                                                            Colors.blueGrey)),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      width: 100,
                                      margin: const EdgeInsets.only(
                                          right: 8,
                                          left: 8,
                                          bottom: 8,
                                          top: 12),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 24,
                                            backgroundColor:
                                                Colors.blueGrey[100],
                                            backgroundImage: admin[
                                                            'photoUrl'] !=
                                                        null &&
                                                    admin['photoUrl'] != ''
                                                ? (admin['photoUrl']
                                                        .toString()
                                                        .startsWith('http')
                                                    // Jika link (dari Google, dsb)
                                                    ? NetworkImage(
                                                        admin['photoUrl'])
                                                    // Jika base64
                                                    : MemoryImage(base64Decode(admin[
                                                            'photoUrl']
                                                        .toString()
                                                        .replaceFirst(
                                                            RegExp(
                                                                r'data:image/[^;]+;base64,'),
                                                            ''))) as ImageProvider)
                                                : null,
                                            child: (admin['photoUrl'] == null ||
                                                    admin['photoUrl'] == '')
                                                ? Text(
                                                    (admin['name'] ?? '-')
                                                            .toString()
                                                            .isNotEmpty
                                                        ? (admin['name'] ??
                                                                '-')[0]
                                                            .toUpperCase()
                                                        : '-',
                                                    style: const TextStyle(
                                                      color: Colors.blueGrey,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            admin['name'] ?? '-',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueGrey,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            admin['status'] ?? '-',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.blueGrey,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          // Jika expanded, tampilkan admin lain (selain 3 pertama) dalam bentuk list di bawahnya
                          // AnimatedCrossFade untuk animasi expand/collapse
                          AnimatedCrossFade(
                            crossFadeState: (controller.isExpanded.value &&
                                    controller.admins.length > 3)
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            duration: const Duration(milliseconds: 350),
                            firstCurve: Curves.easeInOut,
                            secondCurve: Curves.easeInOut,
                            sizeCurve: Curves.easeInOut,
                            firstChild: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 8),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: List.generate(
                                    controller.admins.length - 3,
                                    (i) {
                                      final admin = controller.admins[i + 3];
                                      return GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                title: Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 24,
                                                      backgroundColor:
                                                          Colors.blueGrey[100],
                                                      backgroundImage: admin[
                                                                      'photoUrl'] !=
                                                                  null &&
                                                              admin['photoUrl'] !=
                                                                  ''
                                                          ? (admin['photoUrl']
                                                                  .toString()
                                                                  .startsWith(
                                                                      'http')
                                                              // Jika link (dari Google, dsb)
                                                              ? NetworkImage(admin[
                                                                  'photoUrl'])
                                                              // Jika base64
                                                              : MemoryImage(base64Decode(admin[
                                                                      'photoUrl']
                                                                  .toString()
                                                                  .replaceFirst(
                                                                      RegExp(
                                                                          r'data:image/[^;]+;base64,'),
                                                                      ''))) as ImageProvider)
                                                          : null,
                                                      child: (admin['photoUrl'] ==
                                                                  null ||
                                                              admin['photoUrl'] ==
                                                                  '')
                                                          ? Text(
                                                              (admin['name'] ??
                                                                          '-')
                                                                      .toString()
                                                                      .isNotEmpty
                                                                  ? (admin['name'] ??
                                                                          '-')[0]
                                                                      .toUpperCase()
                                                                  : '-',
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .blueGrey,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 18,
                                                              ),
                                                            )
                                                          : null,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        admin['name'] ?? '-',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Colors.blueGrey,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Icon(Icons.badge,
                                                            color:
                                                                Colors.blueGrey,
                                                            size: 20),
                                                        const SizedBox(
                                                            width: 8),
                                                        Expanded(
                                                          child: Text(
                                                            admin['status'] ??
                                                                '-',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                              color: Colors
                                                                  .blueGrey,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 12),
                                                    if (admin['email'] !=
                                                            null &&
                                                        admin['email'] != '')
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                              Icons.email,
                                                              color: Colors
                                                                  .blueGrey,
                                                              size: 20),
                                                          const SizedBox(
                                                              width: 8),
                                                          Expanded(
                                                            child: Text(
                                                              admin['email'],
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .blueGrey,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    if (admin['gender'] !=
                                                            null &&
                                                        admin['gender'] != '')
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 12.0),
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                                Icons.person,
                                                                color: Colors
                                                                    .blueGrey,
                                                                size: 20),
                                                            const SizedBox(
                                                                width: 8),
                                                            Expanded(
                                                              child: Text(
                                                                admin['gender'],
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .blueGrey,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Get.toNamed('/chat-list');
                                                    },
                                                    child: const Text('Hubungi',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .blueGrey)),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text('Tutup',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .blueGrey)),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: Container(
                                          width: 100,
                                          margin: const EdgeInsets.all(8),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              CircleAvatar(
                                                radius: 24,
                                                backgroundColor:
                                                    Colors.blueGrey[100],
                                                backgroundImage: admin[
                                                                'photoUrl'] !=
                                                            null &&
                                                        admin['photoUrl'] != ''
                                                    ? (admin['photoUrl']
                                                            .toString()
                                                            .startsWith('http')
                                                        // Jika link (dari Google, dsb)
                                                        ? NetworkImage(
                                                            admin['photoUrl'])
                                                        // Jika base64
                                                        : MemoryImage(base64Decode(admin[
                                                                    'photoUrl']
                                                                .toString()
                                                                .replaceFirst(
                                                                    RegExp(
                                                                        r'data:image/[^;]+;base64,'),
                                                                    '')))
                                                            as ImageProvider)
                                                    : null,
                                                child: (admin['photoUrl'] ==
                                                            null ||
                                                        admin['photoUrl'] == '')
                                                    ? Text(
                                                        (admin['name'] ?? '-')
                                                                .toString()
                                                                .isNotEmpty
                                                            ? (admin['name'] ??
                                                                    '-')[0]
                                                                .toUpperCase()
                                                            : '-',
                                                        style: const TextStyle(
                                                          color:
                                                              Colors.blueGrey,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                admin['name'] ?? '-',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blueGrey,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                admin['status'] ?? '-',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.blueGrey,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            secondChild: const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 12),
                          const Divider(
                            color: Colors.grey,
                            height: 0.5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (controller.admins.length > 3)
                                GestureDetector(
                                  onTap: () {
                                    controller.isExpanded.value =
                                        !controller.isExpanded.value;
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    width: 350,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        AnimatedSwitcher(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          transitionBuilder:
                                              (child, animation) =>
                                                  FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          ),
                                          child: Text(
                                            controller.isExpanded.value
                                                ? 'Tutup'
                                                : 'Lainnya',
                                            key: ValueKey(
                                                controller.isExpanded.value),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.blueGrey,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        AnimatedSwitcher(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          transitionBuilder:
                                              (child, animation) =>
                                                  RotationTransition(
                                            turns: Tween<double>(
                                                    begin: 0, end: 0.5)
                                                .animate(animation),
                                            child: child,
                                          ),
                                          child: Icon(
                                            controller.isExpanded.value
                                                ? Icons.arrow_drop_down
                                                : Icons.arrow_drop_up,
                                            key: ValueKey(
                                                controller.isExpanded.value),
                                            size: 32,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.only(
                        left:
                            10.0), // margin start setara dengan card di atasnya
                    child: Text(
                      'Berita Terkini',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (controller.latestNews.isEmpty) {
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                        color: Colors.grey[100],
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          child: const Column(
                            children: [
                              const Icon(Icons.newspaper,
                                  size: 50, color: Colors.blueGrey),
                              const SizedBox(height: 16),
                              const Text(
                                'Belum ada berita terbaru',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.blueGrey),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.latestNews.length,
                        itemBuilder: (context, index) {
                          final news = controller.latestNews[index];
                          return _buildNewsCard(context, news);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
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
      child: SizedBox(
        width: 95,
        height: 95,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: Colors.white,
              elevation: 4,
              shadowColor: Colors.grey.withOpacity(1),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(icon, size: 30, color: color),
              ),
            ),
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
    );
  }

  Widget _buildNewsCard(BuildContext context, newsItem) {
    return InkWell(
      onTap: () {
        Get.to(() => NewsDetailView(news: newsItem));
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        color: Colors.white,
        shadowColor: Colors.grey.withOpacity(1),
        child: SizedBox(
          width: 172,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
                child: newsItem.imageUrl.isNotEmpty
                    ? Image.network(
                        newsItem.imageUrl,
                        height: 100,
                        width: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 100,
                            width: 180,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported,
                                color: Colors.grey),
                          );
                        },
                      )
                    : Container(
                        height: 100,
                        width: 180,
                        color: Colors.grey[200],
                        child: const Icon(Icons.newspaper,
                            size: 40, color: Colors.grey),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      newsItem.title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd MMM yyyy')
                              .format(newsItem.publishedAt),
                          style:
                              const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                    if (newsItem.newsUrl.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () {
                          final newsController = Get.find<NewsController>();
                          newsController.openNewsUrl(newsItem.newsUrl);
                        },
                        child: Row(
                          children: const [
                            Icon(Icons.link, size: 12, color: Colors.blue),
                            SizedBox(width: 4),
                            Text(
                              'Buka Link',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue,
                                // decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isProfileIncomplete() {
    final user = controller.userProfile.value;
    // final userData = controller.email.value;

    if ((user != null && user.name.isNotEmpty && user.gender.isNotEmpty)) {
      return false;
    }
    return true;
  }

  void _showProfileIncompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Lengkapi Data Diri",
            style: TextStyle(color: Colors.blueGrey)),
        content: const Text(
            "Silakan lengkapi data diri Anda sebelum mengakses fitur pengaduan.",
            style: TextStyle(color: Colors.blueGrey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text("Batal", style: TextStyle(color: Colors.blueGrey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.find<DashboardUserController>().changeTab(2);
            },
            child: const Text("Isi Sekarang",
                style: TextStyle(color: Colors.blueGrey)),
          ),
        ],
      ),
    );
  }

  void _showActiveComplaintDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Pengaduan Aktif",
            style: TextStyle(color: Colors.blueGrey)),
        content: const Text(
            "Anda masih memiliki pengaduan yang sedang diproses. Silakan tunggu hingga pengaduan selesai sebelum membuat pengaduan baru.",
            style: TextStyle(color: Colors.blueGrey)),
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
            child: const Text("Lihat Progres",
                style: TextStyle(color: Colors.blueGrey)),
          ),
        ],
      ),
    );
  }
}
