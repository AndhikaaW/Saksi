import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageAdminController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Map<String, dynamic>> admins = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> filteredAdmins = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    getAdmins();
  }

  void searchAdmin(String query) {
    if (query.isEmpty) {
      filteredAdmins.value = admins;
    } else {
      filteredAdmins.value = admins.where((admin) {
        final name = admin['name'].toString().toLowerCase();
        final email = admin['email'].toString().toLowerCase();
        final searchLower = query.toLowerCase();
        return name.contains(searchLower) || email.contains(searchLower);
      }).toList();
    }
  }

  Future<void> getAdmins() async {
    try {
      isLoading.value = true;
      final QuerySnapshot querySnapshot = await _firestore.collection('users').where('status', whereIn: [0, 1]).get();
      
      admins.value = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        String status = '';
        switch(data['status']) {
          case 0:
            status = 'Super Admin';
            break;
          case 1:
            status = 'Admin';
            break;
          default:
            status = '';
        }
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'status': status,
          'email': data['email'] ?? '',
          'photoUrl': data['photoUrl'] ?? '',
        };
      }).toList();

    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil data admin: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAdmin(String adminId) async {
    try {
      await _firestore.collection('users').doc(adminId).delete();
      await getAdmins();
      Get.snackbar(
        'Sukses',
        'Admin berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus admin: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateAdminRole(String adminId, int newRole) async {
    try {
      await _firestore.collection('users').doc(adminId).update({
        'status': newRole
      });
      await getAdmins();
      Get.snackbar(
        'Sukses',
        'Role admin berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui role admin: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
