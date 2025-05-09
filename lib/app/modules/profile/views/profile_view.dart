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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = controller.userProfile.value;
        if (user == null) {
          return const Center(child: Text('User not found.'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Image & Change Button
            ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: user.photoUrl != null && user.photoUrl.isNotEmpty
                    ? NetworkImage(user.photoUrl) as ImageProvider
                    : const AssetImage('assets/defaultProfile.png')
              ),
              
              title: Text(user.email),
              // trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              // onTap: () {
              //   // Future Feature: Change Profile Picture
              // },
            ),
            const Divider(),

            // Profile Details
            _buildProfileItem("Nama", user.name, context, controller),
            _buildProfileItem("Email", user.email, context, controller, isDisabled: true),
            _buildProfileItem("Gender", user.gender, context, controller),
            _buildProfileItem("Tempat Tanggal Lahir", user.ttl, context, controller),
            _buildProfileItem("Alamat", user.address, context, controller),
            _buildProfileItem("Nomor Ponsel", user.phone, context, controller),
            _buildProfileItem("Status Pengguna", user.statusPengguna, context, controller),

            SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: controller.logout,
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent[200],
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      }),
    );
  }

  Widget _buildProfileItem(String title, String value, BuildContext context, ProfileController controller, {bool isDisabled = false}) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value.isNotEmpty ? value : "Belum diisi", style: TextStyle(color: value.isEmpty ? Colors.red : Colors.black)),
      trailing: isDisabled ? null : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: isDisabled ? null : () {
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
    );
  }

  void showStatusPenggunaDialog(BuildContext context, String title, String currentValue, ProfileController controller) {
    String selectedStatus = currentValue;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(currentValue.isEmpty ? "Pilih $title" : "Edit $title"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButton<String>(
                value: selectedStatus.isNotEmpty ? selectedStatus : null,
                hint: Text("Pilih $title"),
                items: <String>['Mahasiswa', 'Pendidik/Dosen', 'Tenaga Kependidikan', 'Warga Kampus', 'Masyarakat Umum']
                    .map<DropdownMenuItem<String>>((String value) {
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
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                if (selectedStatus.isNotEmpty) {
                  await controller.updateUserProfile(title, selectedStatus);
                  Navigator.pop(context);
                }
              },
              child: Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  void showEditDialog(BuildContext context, String title, String currentValue, ProfileController controller) {
    TextEditingController controllerText = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(currentValue.isEmpty ? "Tambah $title" : "Edit $title"),
          content: TextField(
            controller: controllerText,
            decoration: InputDecoration(hintText: "Masukkan $title"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                if (controllerText.text.isNotEmpty) {
                  await controller.updateUserProfile(title, controllerText.text);
                  Navigator.pop(context);
                }
              },
              child: Text("Simpan"),
            ),
          ],
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
  void showGenderSelectionDialog(BuildContext context, String title, String currentValue, ProfileController controller) {
    // Create a local state variable for selected gender
    String selectedGender = currentValue;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(currentValue.isEmpty ? "Pilih Gender" : "Edit Gender"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text("Laki-laki"),
                    value: "Laki-laki",
                    groupValue: selectedGender,
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
                  child: Text("Batal"),
                ),
                TextButton(
                  onPressed: () async {
                    if (selectedGender.isNotEmpty) {
                      await controller.updateUserProfile(title, selectedGender);
                      Navigator.pop(context);
                    }
                  },
                  child: Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }
  // dialog ttl
  void showTempatTanggalLahirDialog(BuildContext context, String currentValue, ProfileController controller) async {
    String tempat = "";
    DateTime? tanggal;

    if (currentValue.contains(',')) {
      List<String> parts = currentValue.split(',');
      tempat = parts[0].trim();
      try {
        tanggal = DateFormat("dd-MM-yyyy").parse(parts[1].trim());
      } catch (_) {}
    }

    TextEditingController tempatController = TextEditingController(text: tempat);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(currentValue.isEmpty ? "Tambah Tempat Tanggal Lahir" : "Edit Tempat Tanggal Lahir"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: tempatController,
                    decoration: InputDecoration(hintText: "Masukkan Tempat Lahir"),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        tanggal != null ? DateFormat("dd-MM-yyyy").format(tanggal!) : "Pilih Tanggal Lahir",
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () async {
                          DateTime now = DateTime.now();
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: tanggal ?? DateTime(now.year - 20),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(now.year, now.month, now.day),
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
                  child: Text("Batal"),
                ),
                TextButton(
                  onPressed: () async {
                    if (tempatController.text.isNotEmpty && tanggal != null) {
                      String newValue = "${tempatController.text}, ${DateFormat("dd-MM-yyyy").format(tanggal!)}";
                      await controller.updateUserProfile("Tempat Tanggal Lahir", newValue);
                      Navigator.pop(context);
                    }
                  },
                  child: Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }
  //dialog alamat
  void showAlamatDialog(BuildContext context, String currentValue, ProfileController controller) {
    String? selectedProvinsi, selectedKabupaten, selectedKecamatan, selectedKelurahan;
    String? idProvinsi, idKabupaten, idKecamatan;

    List<dynamic> provinsiList = [];
    List<dynamic> kabupatenList = [];
    List<dynamic> kecamatanList = [];
    List<dynamic> kelurahanList = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          Future<void> loadProvinsi() async {
            provinsiList = await fetchWilayah('https://andhikaaw.github.io/api-wilayah-indonesia/api/provinces.json');
            setState(() {});
          }

          Future<void> loadKabupaten(String provinsiId) async {
            kabupatenList = await fetchWilayah('https://andhikaaw.github.io/api-wilayah-indonesia/api/regencies/$provinsiId.json');
            setState(() {});
          }

          Future<void> loadKecamatan(String kabupatenId) async {
            kecamatanList = await fetchWilayah('https://andhikaaw.github.io/api-wilayah-indonesia/api/districts/$kabupatenId.json');
            setState(() {});
          }

          Future<void> loadKelurahan(String kecamatanId) async {
            kelurahanList = await fetchWilayah('https://andhikaaw.github.io/api-wilayah-indonesia/api/villages/$kecamatanId.json');
            setState(() {});
          }

          if (provinsiList.isEmpty) loadProvinsi();

          return AlertDialog(
            title: Text("Pilih Alamat"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  DropdownButtonFormField(
                    hint: Text("Provinsi"),
                    value: selectedProvinsi,
                    items: provinsiList.map<DropdownMenuItem<String>>((item) {
                      return DropdownMenuItem(
                        child: Text(item['name']),
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
                  if (kabupatenList.isNotEmpty)
                    DropdownButtonFormField(
                      hint: const Text("Kabupaten/Kota"),
                      value: selectedKabupaten,
                      items: kabupatenList.map<DropdownMenuItem<String>>((item) {
                        return DropdownMenuItem(
                          child: Text(item['name']),
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
                        if (idKabupaten != null) loadKecamatan(idKabupaten!);
                      },
                    ),
                  if (kecamatanList.isNotEmpty)
                    DropdownButtonFormField(
                      hint: Text("Kecamatan"),
                      value: selectedKecamatan,
                      items: kecamatanList.map<DropdownMenuItem<String>>((item) {
                        return DropdownMenuItem(
                          child: Text(item['name']),
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
                        if (idKecamatan != null) loadKelurahan(idKecamatan!);
                      },
                    ),
                  if (kelurahanList.isNotEmpty)
                    DropdownButtonFormField(
                      hint: Text("Kelurahan"),
                      value: selectedKelurahan,
                      items: kelurahanList.map<DropdownMenuItem<String>>((item) {
                        return DropdownMenuItem(
                          child: Text(item['name']),
                          value: item['name'],
                        );
                      }).toList(),
                      onChanged: (val) {
                        selectedKelurahan = val as String;
                      },
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Batal"),
              ),
              TextButton(
                onPressed: () async {
                  if (selectedProvinsi != null &&
                      selectedKabupaten != null &&
                      selectedKecamatan != null &&
                      selectedKelurahan != null) {
                    String fullAddress =
                        "$selectedKelurahan, $selectedKecamatan, $selectedKabupaten, $selectedProvinsi";
                    await controller.updateUserProfile("Alamat", fullAddress);
                    Navigator.pop(context);
                  }
                },
                child: Text("Simpan"),
              ),
            ],
          );
        });
      },
    );
  }
  // dialog no telepon
  void showNoTeleponDialog(BuildContext context, String title, String currentValue, ProfileController controller) {
    TextEditingController controllerText = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(currentValue.isEmpty ? "Tambah $title" : "Edit $title"),
          content: TextField(
            keyboardType: TextInputType.number,
            controller: controllerText,
            decoration: InputDecoration(hintText: "Masukkan $title"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                if (controllerText.text.isNotEmpty) {
                  await controller.updateUserProfile(title, controllerText.text);
                  Navigator.pop(context);
                }
              },
              child: Text("Simpan"),
            ),
          ],
        );
      },
    );
  }
}
