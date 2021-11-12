import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:map_note/screens/home.dart';

class AppController extends GetxController {
  static CollectionReference mapData =
      FirebaseFirestore.instance.collection('map_data');
  static GoogleSignIn googleSignIn = GoogleSignIn();
  var isLogin = false.obs;
  var userData = <String, dynamic>{}.obs;

  Future<void> addMapData({required data}) {
    return mapData.add(data);
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    Get.offAll(() => const Home());

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.signOut();
    checkAuth();
  }

  void checkAuth() {
    FirebaseAuth.instance.idTokenChanges().listen((User? user) {
      if (user == null) {
        userData({});
        isLogin(false);
      } else {
        var userJsonData = {
          'displayName' : user.displayName,
          'uid' : user.uid,
          'email' : user.email,
        };
        userData(userJsonData);
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
