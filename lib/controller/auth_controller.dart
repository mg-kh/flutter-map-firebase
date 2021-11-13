import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:map_note/models/user_model.dart';

class AuthController extends GetxController {
  static GoogleSignIn googleSignIn = GoogleSignIn();
  var isLogin = false.obs;
  var userData = UserModel(
    displayName: '',
    uid: '',
    email: '',
  ).obs;

  ///Sign In to account
  Future<UserCredential> signInWithGoogle() async {
    /// Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    /// Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    Get.offAllNamed('/');

    /// Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  ///Logout
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.signOut();
    checkAuth();
  }

  ///Check user
  void checkAuth() {
    FirebaseAuth.instance.idTokenChanges().listen((User? user) {
      if (user == null) {
        userData.value = UserModel(
          displayName: '',
          uid: '',
          email: '',
        );
        isLogin(false);
      } else {
        userData.value = UserModel(
          displayName: user.displayName,
          uid: user.uid,
          email: user.email,
        );
        isLogin(true);
      }
    });
  }

  @override
  void onInit() {
    super.onInit();
    checkAuth();
  }
}
