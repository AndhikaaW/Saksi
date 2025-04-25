import 'package:get/get.dart';

import '../controllers/dashboard_superadmin_controller.dart';

class DashboardSuperadminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardSuperadminController>(
      () => DashboardSuperadminController(),
    );
  }
}
