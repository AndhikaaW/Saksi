import 'package:flutter/material.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:saksi_app/app/routes/app_pages.dart';
// Tambahkan import berikut agar Lottie dikenali
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  String getInitialRoute() {
    final box = GetStorage();
    final isLoggedIn = box.read('isLoggedIn') ?? false;
    final userStatus = box.read('userStatus');

    if (isLoggedIn) {
      if (userStatus == 0) {
        return Routes.DASHBOARD_SUPERADMIN;
      } else if (userStatus == 1) {
        return Routes.DASHBOARD_ADMIN;
      } else if (userStatus == 2) {
        return Routes.DASHBOARD_USER;
      }
    }
    return Routes.GET_STARTED;  
  }

  @override
  Widget build(BuildContext context) {
    return FlutterSplashScreen.fadeIn(
      backgroundColor: Colors.white,
      childWidget: SizedBox(
        height: 200,
        width: 200,
        child: Lottie.asset(
          "assets/splashScreen.json",
          repeat: false,
        ),
      ),
      duration: const Duration(seconds: 3),
      onAnimationEnd: () {
        Get.offAllNamed(getInitialRoute());
      },
    );
  }
}
