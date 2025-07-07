import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saksi_app/app/routes/app_pages.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
                Image.asset(
                  'assets/logo.png',
                  height: 110,
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center, 
                children: [
                Image.asset(
                  'assets/logoPoltek.png',
                  height: 100,
                ),
                const SizedBox(width: 16),
                Image.asset(
                  'assets/logoPPKS.png',
                  height: 100,
                ),
              ]),
              const SizedBox(height: 24),
              Text(
                'Selamat Datang di SAKSI',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Sistem Aduan Kekerasan Seksual Internal\nPoliteknik Negeri Madiun',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueGrey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.offAllNamed(Routes.LOGIN);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Mulai',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
