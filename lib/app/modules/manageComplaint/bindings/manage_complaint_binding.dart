import 'package:get/get.dart';

import '../controllers/manage_complaint_controller.dart';

class ManageComplaintBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManageComplaintController>(
      () => ManageComplaintController(),
    );
  }
}
