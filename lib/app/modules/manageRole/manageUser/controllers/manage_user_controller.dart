import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUserController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Map<String, dynamic>> users = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> filteredUsers = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    getUsers();
  }


  void searchUser(String query) {
    if (query.isEmpty) {
      filteredUsers.value = users;
    } else {
      filteredUsers.value = users.where((user) {
        final name = user['name'].toString().toLowerCase();
        final email = user['email'].toString().toLowerCase();
        final searchLower = query.toLowerCase();
        return name.contains(searchLower) || email.contains(searchLower);
      }).toList();
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      await getUsers();
      Get.snackbar(
        'Sukses',
        'Pengguna berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Gagal menghapus pengguna: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }


  Future<void> updateUserRole(String userId, int newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': newRole
      });
      await getUsers(); 
      Get.snackbar(
        'Sukses',
        'Role pengguna berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui role pengguna: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> getUsers() async {
    try {
      isLoading.value = true;
      final QuerySnapshot querySnapshot = await _firestore.collection('users').where('status', isEqualTo: 2).get();
      
      users.value = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        String status = '';
        switch(data['status']) {
          case 2:
            status = 'User';
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
        'Gagal mengambil data pengguna: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
