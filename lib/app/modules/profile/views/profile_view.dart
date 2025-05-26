import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../controllers/profile_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Profil Saya",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(
            color: Colors.blueGrey,
          ));
        }

        final user = controller.userProfile.value;
        if (user == null) {
          return const Center(child: Text('User tidak ditemukan.'));
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          children: [
            // Header Profile Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
              // Contoh decoration yang berbeda: menggunakan warna solid dan border, tanpa gradient
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade200,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(250),
                  bottomRight: Radius.circular(250),
                ),
                // border: Border.all(
                //   color: Colors.blueGrey.shade400,
                //   width: 2,
                // ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueGrey.shade100.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => showChangePhotoDialog(context, controller),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Obx(() => CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.white,
                              backgroundImage: controller.userProfile.value?.photoUrl != null &&
                                      controller.userProfile.value!.photoUrl.isNotEmpty
                                  ? (
                                      controller.userProfile.value!.photoUrl.startsWith('http')
                                          // Jika link (dari Google, dsb)
                                          ? NetworkImage(controller.userProfile.value!.photoUrl)
                                          // Jika base64
                                          : MemoryImage(
                                              base64Decode(
                                                controller.userProfile.value!.photoUrl
                                                    .replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '')
                                              )
                                            ) as ImageProvider
                                    )
                                  : null,
                              child: (controller.userProfile.value?.photoUrl == null ||
                                      controller.userProfile.value!.photoUrl.isEmpty)
                                  ? Text(
                                      (controller.userProfile.value?.name.isNotEmpty ?? false)
                                          ? controller.userProfile.value!.name[0].toUpperCase()
                                          : '',
                                      style: const TextStyle(
                                        fontSize: 36,
                                        color: Colors.blueGrey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            )),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade700,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.edit, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      user.statusPengguna.isNotEmpty ? user.statusPengguna : "Status belum diisi",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Profile Details Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueGrey.shade100.withOpacity(0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildProfileItem("Nama", user.name, context, controller),
                  _buildProfileItem("Email", user.email, context, controller, isDisabled: true),
                  _buildProfileItem("Gender", user.gender, context, controller),
                  _buildProfileItem("Tempat Tanggal Lahir", user.ttl, context, controller),
                  _buildProfileItem("Alamat", user.address, context, controller),
                  _buildProfileItem("Nomor Ponsel", user.phone, context, controller),
                  _buildProfileItem("Status Pengguna", user.statusPengguna, context, controller),
                ],
              ),
            ),

            const SizedBox(height: 32),
            // Tombol Logout
            Center(
              child: ElevatedButton.icon(
                onPressed: controller.logout,
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent[200],
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  shadowColor: Colors.redAccent.withOpacity(0.2),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        );
      }),
    );
  }

  Widget _buildProfileItem(String title, String value, BuildContext context,
      ProfileController controller,
      {bool isDisabled = false}) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: isDisabled
          ? null
          : () {
              if (title == "Gender") {
                showGenderSelectionDialog(context, title, value, controller);
              } else if (title == "Tempat Tanggal Lahir") {
                showTempatTanggalLahirDialog(context, value, controller);
              } else if (title == "Alamat") {
                showAlamatDialog(context, value, controller);
              } else if (title == "Nomor Ponsel") {
                showNoTeleponDialog(context, title, value, controller);
              } else if (title == "Status Pengguna") {
                showStatusPenggunaDialog(context, title, value, controller);
              } else {
                showEditDialog(context, title, value, controller);
              }
            },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey.shade100 : Colors.blueGrey.shade50,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              _getProfileIcon(title),
              color: Colors.blueGrey.shade700,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey.shade700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value.isNotEmpty ? value : "Belum diisi",
                    style: TextStyle(
                      color: value.isEmpty ? Colors.red : Colors.blueGrey.shade900,
                      fontSize: 15,
                      fontWeight: value.isEmpty ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            if (!isDisabled)
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blueGrey),
          ],
        ),
      ),
    );
  }

  IconData _getProfileIcon(String title) {
    switch (title) {
      case "Nama":
        return Icons.person_rounded;
      case "Email":
        return Icons.email_rounded;
      case "Gender":
        return Icons.wc_rounded;
      case "Tempat Tanggal Lahir":
        return Icons.cake_rounded;
      case "Alamat":
        return Icons.home_rounded;
      case "Nomor Ponsel":
        return Icons.phone_rounded;
      case "Status Pengguna":
        return Icons.verified_user_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  void showEditDialog(BuildContext context, String title, String currentValue,
      ProfileController controller) {
    TextEditingController controllerText =
        TextEditingController(text: currentValue);
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                currentValue.isEmpty ? "Tambah $title" : "Edit $title",
                style: TextStyle(
                  color: Colors.blueGrey.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: isLoading
                  ? SizedBox(
                      height: 80,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.blueGrey,
                        ),
                      ),
                    )
                  : TextField(
                      controller: controllerText,
                      decoration: InputDecoration(
                        hintText: "Masukkan $title",
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blueGrey.shade100),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blueGrey, width: 2),
                        ),
                      ),
                    ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blueGrey,
                  ),
                  child: Text("Batal"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (controllerText.text.isNotEmpty) {
                            setState(() => isLoading = true);
                            await controller.updateUserProfile(
                                title, controllerText.text);
                            setState(() => isLoading = false);
                            Navigator.pop(context);
                          }
                        },
                  child: isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<dynamic>> fetchWilayah(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal memuat data wilayah');
    }
  }

  // dialog gender
  void showGenderSelectionDialog(BuildContext context, String title,
      String currentValue, ProfileController controller) {
    String selectedGender = currentValue;
    bool isLoading = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                currentValue.isEmpty ? "Pilih Gender" : "Edit Gender",
                style: TextStyle(
                  color: Colors.blueGrey.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: isLoading
                  ? SizedBox(
                      height: 80,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.blueGrey,
                        ),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<String>(
                          title: const Text("Laki-laki"),
                          value: "Laki-laki",
                          groupValue: selectedGender,
                          activeColor: Colors.blueGrey,
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value!;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: const Text("Perempuan"),
                          value: "Perempuan",
                          groupValue: selectedGender,
                          activeColor: Colors.blueGrey,
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value!;
                            });
                          },
                        ),
                      ],
                    ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blueGrey,
                  ),
                  child: Text("Batal"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (selectedGender.isNotEmpty) {
                            setState(() => isLoading = true);
                            await controller.updateUserProfile(title, selectedGender);
                            setState(() => isLoading = false);
                            Navigator.pop(context);
                          }
                        },
                  child: isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // dialog ttl
  void showTempatTanggalLahirDialog(BuildContext context, String currentValue,
      ProfileController controller) async {
    String tempat = "";
    DateTime? tanggal;
    bool isLoading = false;

    if (currentValue.contains(',')) {
      List<String> parts = currentValue.split(',');
      tempat = parts[0].trim();
      try {
        tanggal = DateFormat("dd-MM-yyyy").parse(parts[1].trim());
      } catch (_) {}
    }

    TextEditingController tempatController =
        TextEditingController(text: tempat);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                currentValue.isEmpty
                    ? "Tambah Tempat Tanggal Lahir"
                    : "Edit Tempat Tanggal Lahir",
                style: TextStyle(
                  color: Colors.blueGrey.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: isLoading
                  ? SizedBox(
                      height: 80,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.blueGrey,
                        ),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: tempatController,
                          decoration: InputDecoration(
                            hintText: "Masukkan Tempat Lahir",
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blueGrey.shade100),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.blueGrey, width: 2),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              tanggal != null
                                  ? DateFormat("dd-MM-yyyy").format(tanggal!)
                                  : "Pilih Tanggal Lahir",
                              style: TextStyle(
                                color: Colors.blueGrey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              icon: Icon(Icons.calendar_today, color: Colors.blueGrey),
                              onPressed: () async {
                                DateTime now = DateTime.now();
                                DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: tanggal ?? DateTime(now.year - 20),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime(now.year, now.month, now.day),
                                  builder: (context, child) {
                                    return Theme(
                                      data: ThemeData.light().copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: Colors.blueGrey,
                                          onPrimary: Colors.white,
                                          surface: Colors.grey.shade100,
                                          onSurface: Colors.blueGrey.shade900,
                                        ),
                                        dialogBackgroundColor: Colors.grey.shade100,
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setState(() => tanggal = picked);
                                }
                              },
                            )
                          ],
                        )
                      ],
                    ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blueGrey,
                  ),
                  child: Text("Batal"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (tempatController.text.isNotEmpty && tanggal != null) {
                            setState(() => isLoading = true);
                            String newValue =
                                "${tempatController.text}, ${DateFormat("dd-MM-yyyy").format(tanggal!)}";
                            await controller.updateUserProfile(
                                "Tempat Tanggal Lahir", newValue);
                            setState(() => isLoading = false);
                            Navigator.pop(context);
                          }
                        },
                  child: isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  //dialog alamat
  void showAlamatDialog(
      BuildContext context, String currentValue, ProfileController controller) {
    String? selectedProvinsi,
        selectedKabupaten,
        selectedKecamatan,
        selectedKelurahan;
    String? idProvinsi, idKabupaten, idKecamatan;

    List<dynamic> provinsiList = [];
    List<dynamic> kabupatenList = [];
    List<dynamic> kecamatanList = [];
    List<dynamic> kelurahanList = [];
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          Future<void> loadProvinsi() async {
            provinsiList = await fetchWilayah(
                'https://andhikaaw.github.io/api-wilayah-indonesia/api/provinces.json');
            setState(() {});
          }

          Future<void> loadKabupaten(String provinsiId) async {
            kabupatenList = await fetchWilayah(
                'https://andhikaaw.github.io/api-wilayah-indonesia/api/regencies/$provinsiId.json');
            setState(() {});
          }

          Future<void> loadKecamatan(String kabupatenId) async {
            kecamatanList = await fetchWilayah(
                'https://andhikaaw.github.io/api-wilayah-indonesia/api/districts/$kabupatenId.json');
            setState(() {});
          }

          Future<void> loadKelurahan(String kecamatanId) async {
            kelurahanList = await fetchWilayah(
                'https://andhikaaw.github.io/api-wilayah-indonesia/api/villages/$kecamatanId.json');
            setState(() {});
          }

          if (provinsiList.isEmpty) loadProvinsi();

          return AlertDialog(
            backgroundColor: Colors.grey.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Text(
              "Pilih Alamat",
              style: TextStyle(
                color: Colors.blueGrey.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: isLoading
                ? SizedBox(
                    height: 80,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.blueGrey,
                      ),
                    ),
                  )
                : SizedBox(
                    width: 350,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 2.0, horizontal: 2.0),
                            child: DropdownButtonFormField(
                              isExpanded: true,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.blueGrey.shade100),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.blueGrey, width: 2),
                                ),
                              ),
                              hint: Text("Provinsi"),
                              value: selectedProvinsi,
                              dropdownColor: Colors.grey.shade200,
                              items:
                                  provinsiList.map<DropdownMenuItem<String>>((item) {
                                return DropdownMenuItem(
                                  child: SizedBox(
                                    width: 250,
                                    child: Text(item['name'],
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  value: item['name'],
                                  onTap: () {
                                    idProvinsi = item['id'];
                                  },
                                );
                              }).toList(),
                              onChanged: (val) {
                                selectedProvinsi = val as String;
                                selectedKabupaten = null;
                                selectedKecamatan = null;
                                selectedKelurahan = null;
                                kabupatenList.clear();
                                kecamatanList.clear();
                                kelurahanList.clear();
                                if (idProvinsi != null) loadKabupaten(idProvinsi!);
                              },
                            ),
                          ),
                          if (kabupatenList.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2.0, horizontal: 2.0),
                              child: DropdownButtonFormField(
                                isExpanded: true,
                                dropdownColor: Colors.grey.shade200,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 4),
                                  filled: true,
                                  fillColor: Colors.grey.shade200,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.blueGrey.shade100),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.blueGrey, width: 2),
                                  ),
                                ),
                                hint: const Text("Kabupaten/Kota"),
                                value: selectedKabupaten,
                                items: kabupatenList
                                    .map<DropdownMenuItem<String>>((item) {
                                  return DropdownMenuItem(
                                    child: SizedBox(
                                      width: 250,
                                      child: Text(item['name'],
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                    value: item['name'],
                                    onTap: () {
                                      idKabupaten = item['id'];
                                    },
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  selectedKabupaten = val as String;
                                  selectedKecamatan = null;
                                  selectedKelurahan = null;
                                  kecamatanList.clear();
                                  kelurahanList.clear();
                                  if (idKabupaten != null)
                                    loadKecamatan(idKabupaten!);
                                },
                              ),
                            ),
                          if (kecamatanList.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2.0, horizontal: 2.0),
                              child: DropdownButtonFormField(
                                isExpanded: true,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 4),
                                  filled: true,
                                  fillColor: Colors.grey.shade200,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.blueGrey.shade100),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.blueGrey, width: 2),
                                  ),
                                ),
                                hint: Text("Kecamatan"),
                                value: selectedKecamatan,
                                items: kecamatanList
                                    .map<DropdownMenuItem<String>>((item) {
                                  return DropdownMenuItem(
                                    child: SizedBox(
                                      width: 250,
                                      child: Text(item['name'],
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                    value: item['name'],
                                    onTap: () {
                                      idKecamatan = item['id'];
                                    },
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  selectedKecamatan = val as String;
                                  selectedKelurahan = null;
                                  kelurahanList.clear();
                                  if (idKecamatan != null)
                                    loadKelurahan(idKecamatan!);
                                },
                              ),
                            ),
                          if (kelurahanList.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2.0, horizontal: 2.0),
                              child: DropdownButtonFormField(
                                isExpanded: true,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 4),
                                  filled: true,
                                  fillColor: Colors.grey.shade200,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.blueGrey.shade100),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.blueGrey, width: 2),
                                  ),
                                ),
                                hint: Text("Kelurahan"),
                                value: selectedKelurahan,
                                items: kelurahanList
                                    .map<DropdownMenuItem<String>>((item) {
                                  return DropdownMenuItem(
                                    child: SizedBox(
                                      width: 250,
                                      child: Text(item['name'],
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                    value: item['name'],
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  selectedKelurahan = val as String;
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blueGrey,
                ),
                child: Text("Batal"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: isLoading
                    ? null
                    : () async {
                        if (selectedProvinsi != null &&
                            selectedKabupaten != null &&
                            selectedKecamatan != null &&
                            selectedKelurahan != null) {
                          setState(() => isLoading = true);
                          String fullAddress =
                              "$selectedKelurahan, $selectedKecamatan, $selectedKabupaten, $selectedProvinsi";
                          await controller.updateUserProfile("Alamat", fullAddress);
                          setState(() => isLoading = false);
                          Navigator.pop(context);
                        }
                      },
                child: isLoading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text("Simpan"),
              ),
            ],
          );
        });
      },
    );
  }

  // dialog no telepon
  void showNoTeleponDialog(BuildContext context, String title,
      String currentValue, ProfileController controller) {
    TextEditingController controllerText =
        TextEditingController(text: currentValue);
    bool isLoading = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                currentValue.isEmpty ? "Tambah $title" : "Edit $title",
                style: TextStyle(
                  color: Colors.blueGrey.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: isLoading
                  ? SizedBox(
                      height: 80,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.blueGrey,
                        ),
                      ),
                    )
                  : TextField(
                      keyboardType: TextInputType.number,
                      controller: controllerText,
                      decoration: InputDecoration(
                        hintText: "Masukkan $title",
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blueGrey.shade100),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blueGrey, width: 2),
                        ),
                      ),
                    ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blueGrey,
                  ),
                  child: Text("Batal"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (controllerText.text.isNotEmpty) {
                            setState(() => isLoading = true);
                            await controller.updateUserProfile(
                                title, controllerText.text);
                            setState(() => isLoading = false);
                            Navigator.pop(context);
                          }
                        },
                  child: isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showStatusPenggunaDialog(BuildContext context, String title,
      String currentValue, ProfileController controller) {
    String selectedStatus = currentValue;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                currentValue.isEmpty ? "Pilih $title" : "Edit $title",
                style: TextStyle(
                  color: Colors.blueGrey.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: isLoading
                  ? SizedBox(
                      height: 80,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.blueGrey,
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blueGrey.shade100),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          elevation: 1,
                          dropdownColor: Colors.grey.shade200,
                          value: selectedStatus.isNotEmpty ? selectedStatus : null,
                          hint: Text("Pilih $title"),
                          isExpanded: true,
                          items: <String>[
                            'Mahasiswa',
                            'Pendidik/Dosen',
                            'Tenaga Kependidikan',
                            'Warga Kampus',
                            'Masyarakat Umum'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedStatus = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blueGrey,
                  ),
                  child: Text("Batal"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (selectedStatus.isNotEmpty) {
                            setState(() => isLoading = true);
                            await controller.updateUserProfile(title, selectedStatus);
                            setState(() => isLoading = false);
                            Navigator.pop(context);
                          }
                        },
                  child: isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showChangePhotoDialog(BuildContext context, ProfileController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Obx(() => AlertDialog(
          backgroundColor: Colors.grey.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            "Ganti Foto Profil",
            style: TextStyle(
              color: Colors.blueGrey.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: controller.isLoading.value
              ? SizedBox(
                  height: 120,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.blueGrey,
                    ),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blueGrey.shade200,
                      radius: 50,
                      backgroundImage: controller.userProfile.value?.photoUrl != null &&
                              controller.userProfile.value!.photoUrl.isNotEmpty
                          ? (
                              controller.userProfile.value!.photoUrl.startsWith('http')
                                // Jika link (dari Google, dsb)
                                ? NetworkImage(controller.userProfile.value!.photoUrl)
                                // Jika base64
                                : MemoryImage(
                                    base64Decode(
                                      controller.userProfile.value!.photoUrl
                                        .replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '')
                                    )
                                  ) as ImageProvider
                            )
                          : null,
                      child: (controller.userProfile.value?.photoUrl == null ||
                              controller.userProfile.value!.photoUrl.isEmpty)
                          ? Text(
                              (controller.userProfile.value?.name.isNotEmpty ?? false)
                                  ? controller.userProfile.value!.name[0].toUpperCase()
                                  : '',
                              style: const TextStyle(
                                fontSize: 32,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Fungsi untuk memilih gambar dari galeri
                        final pickedFile = await controller.pickImageFromGallery();
                        if (pickedFile != null) {
                          await controller.uploadProfilePhoto(pickedFile);
                          if (!controller.isLoading.value) {
                            Navigator.pop(context);
                          }
                        }
                      },
                      icon: Icon(Icons.photo_library),
                      label: Text("Pilih dari Galeri"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Fungsi untuk mengambil gambar dari kamera
                        final pickedFile = await controller.pickImageFromCamera();
                        if (pickedFile != null) {
                          await controller.uploadProfilePhoto(pickedFile);
                          if (!controller.isLoading.value) {
                            Navigator.pop(context);
                          }
                        }
                      },
                      icon: Icon(Icons.camera_alt),
                      label: Text("Ambil dari Kamera"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blueGrey,
              ),
              child: Text("Batal"),
            ),
          ],
        ));
      },
    );
  }
}
