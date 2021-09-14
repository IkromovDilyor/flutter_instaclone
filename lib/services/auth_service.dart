import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_instaclone/pages/signin_page.dart';
import 'package:flutter_instaclone/services/prefs_service.dart';
import 'package:flutter_instaclone/services/utils_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

// SignInUser - ro'yxatdan o'tib bo'lingan accountga kirish
  static Future<User?> signInUser(
      BuildContext context, String email, String password) async {

    try {
      // UserCredential userCredential = await FirebaseAuth.instance
      //     .signInWithEmailAndPassword(email: email, password: password);
     await _auth.signInWithEmailAndPassword(email: email, password: password);
      final User user = _auth.currentUser!;
      print(user.toString());
      return user;
    }
    //on FirebaseAuthException catch (e) {
    //   if (e.code == 'user-not-found') {
    //     print('No user found for that email');
    //   } else if (e.code == 'wrong-password') {
    //     print('Wrong password provided for that user');
    //   }
    // }
    catch (e) {
      print( "xatolikkkkkkkkkkkk: " + e.toString());

    }
    // catch (error) {
    //   print(error.toString());
    //   map.addAll({"ERROR": null!});
    // }

    return null;
  }

  // SignUpUser - Registration ya'ni yangi account yaratish
  static Future<User?> signUpUser(
      BuildContext context, String name, String email, String password) async {

    try {
      // UserCredential userCredential = await FirebaseAuth.instance
      //     .createUserWithEmailAndPassword(email: email, password: password);
      var authResult = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = authResult.user;
      print(user.toString());
      return user;

    } // on FirebaseAuthException catch (e) {
    //   if (e.code == 'weak-password') {
    //     print('The password provided is too weak');
    //   } else if (e.code == 'email-already-in-use') {
    //     print('The account already exists for that email');
    //   }
    // }
    catch(e){
      print(e);
    }
    return null;
  }

  //SignOutUser -  local hotiradegi ma'lumotni ucirish orqali accounttan ciqamz
  static Future<void> signOutUser(BuildContext context) async {
    //await FirebaseAuth.instance.signOut();
    _auth.signOut();
    Prefs.removeUserId().then(
            (value) => {Navigator.pushReplacementNamed(context, SignInPage.id)});
  }
}