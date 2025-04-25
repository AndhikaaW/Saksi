import 'package:get/get.dart';

import '../controllers/manage_admin_controller.dart';

class ManageAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManageAdminController>(
      () => ManageAdminController(),
    );
  }
}
