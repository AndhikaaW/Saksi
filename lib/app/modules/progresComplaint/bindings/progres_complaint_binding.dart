import 'package:get/get.dart';

import '../controllers/progres_complaint_controller.dart';

class ProgresComplaintBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProgresComplaintController>(
      () => ProgresComplaintController(),
    );
  }
}
