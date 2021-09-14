import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instaclone/pages/signin_page.dart';
import 'package:flutter_instaclone/services/auth_service.dart';
import 'package:flutter_instaclone/services/prefs_service.dart';
import 'package:flutter_instaclone/services/utils_service.dart';
import 'package:flutter_instaclone/model/user_model.dart';
import 'package:flutter_instaclone/services/data_service.dart';
import 'home_page.dart';

class SignUpPage extends StatefulWidget {
  static final String id = 'signup_page';

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  var isLoading = false;

  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var cpasswordController = TextEditingController();
  var fullnameController = TextEditingController();

  _doSignUp(/*String email_value, String pass_value*/) {
    String name = fullnameController.text.toString().trim();
    String email = emailController.text.toString().trim();
    String password = passwordController.text.toString().trim();
    String cpassword = cpasswordController.text.toString().trim();
    if (name.isEmpty) {
      Utils.fireToast("Please enter name");
      return;
    }

//validation of password
//     String message;
//     String pattern1 =
//         r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
//     RegExp regExp1 = new RegExp(pattern1);
//validation of email
//     String pattern2 =
//         r'^(([^<>()[\]\\.,#;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
//     RegExp regExp2 = new RegExp(pattern2);

//validation of email
//     print(email_value);
//     if (email_value.isEmpty) {
//       message = "Please enter email";
//       Utils.fireToast(message);
//       return;
//     } else if (!regExp2.hasMatch(email_value)) {
//       message = "Enter valid email";
//       Utils.fireToast(message);
//       return;
//     }

//validation of password
//     print(pass_value);
//     if (pass_value.isEmpty) {
//       message = "Please enter password";
//       Utils.fireToast(message);
//       return;
//     } else if (!regExp1.hasMatch(pass_value)) {
//       message = "Enter valid password";
//       Utils.fireToast(message);
//       return;
//     }
    // confirm password bn passwordni uzi kcokcimu ciqiwomasa return qaytarvoradi
    if (password != cpassword) {
      Utils.fireToast("Password and confirm password does not match");
      return;
    }

    setState(() {
      isLoading = true;
    });

    USer user = new USer(fullname: name, email: email, password: password);

    AuthService.signUpUser(context, name, email, password)
        .then((firebaseUser) => {
              _getFirebaseUser(user, firebaseUser),
            });
  }

  _getFirebaseUser(USer user, User? firebaseUser) async {
    setState(() {
      isLoading = false;
    });

    if (firebaseUser == null) {
      Utils.fireToast("Check your informations");
    } else {
      await Prefs.saveUserId(firebaseUser.uid);
      DataService.storeUser(user).then((value) => {
            Navigator.pushReplacementNamed(context, HomePage.id),
          });
    }

    // if (!map.containsKey("SUCCESS")) {
    //   if (map.containsKey("ERROR_EMAIL_ALREADY_IN_USE"))
    //     Utils.fireToast("The account already exists for that email");
    //   if (map.containsKey("ERROR")) Utils.fireToast("Try again later");
    //   return;
    // }
    // firebaseUser = map["SUCCESS"]!;
    // if (firebaseUser == null) return;
    //
    // await Prefs.saveUserId(firebaseUser.uid);
    // DataService.storeUser(user).then((value) => {
    //       Navigator.pushReplacementNamed(context, HomePage.id),
    //     });
  }

  _callSignInPage() => Navigator.pushReplacementNamed(context, SignInPage.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(193, 53, 132, 1),
                  Color.fromRGBO(131, 58, 180, 1),
                ]),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Instagram",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 45,
                              fontFamily: "Billabong"),
                        ),
                        //#fullname
                        Container(
                          height: 50,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.2),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: TextField(
                            style: TextStyle(color: Colors.white),
                            controller: fullnameController,
                            decoration: InputDecoration(
                              hintText: 'Fullname',
                              hintStyle: TextStyle(
                                  color: Colors.white54, fontSize: 17),
                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        SizedBox(
                          height: 10,
                        ),

                        //#email
                        Container(
                          height: 50,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.2),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: TextField(
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: Colors.white),
                            controller: emailController,
                            decoration: InputDecoration(
                              hintText: 'Email',
                              hintStyle: TextStyle(
                                  color: Colors.white54, fontSize: 17),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        //#password
                        Container(
                          height: 50,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.2),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: TextField(
                            obscureText: true,
                            style: TextStyle(color: Colors.white),
                            controller: passwordController,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: TextStyle(
                                  color: Colors.white54, fontSize: 17),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        //#Confir Password
                        Container(
                          height: 50,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.2),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: TextField(
                            obscureText: true,
                            style: TextStyle(color: Colors.white),
                            controller: cpasswordController,
                            decoration: InputDecoration(
                              hintText: 'Confirm Password',
                              hintStyle: TextStyle(
                                  color: Colors.white54, fontSize: 17),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        //#SignUp
                        GestureDetector(
                          onTap: () {
                            _doSignUp(
                                /*  emailController.text, passwordController.text*/);
                          },
                          child: Container(
                            height: 50,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white54.withOpacity(.2),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Center(
                              child: Text(
                                "Sign Up",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: _callSignInPage,
                          child: Text(
                            "Sign In",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: Colors.red, backgroundColor: Colors.white))
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
