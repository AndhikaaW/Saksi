import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<bool> signInWithGoogle() async {
    try {
      // Memulai proses sign in dengan Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      // Jika user membatalkan proses login
      if (googleUser == null) {
        return false;
      }

      // Mendapatkan detail autentikasi dari permintaan
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Membuat credential untuk Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in ke Firebase dengan credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Memeriksa apakah user berhasil login
      if (userCredential.user != null) {
        return true;
      } else {
        print('Error: User credential is null');
        return false;
      }
    } catch (e) {
      print('Error dalam signInWithGoogle: $e');
      return false;
    }
  }

  // Metode untuk sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}