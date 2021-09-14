import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instaclone/pages/home_page.dart';
import 'package:flutter_instaclone/services/prefs_service.dart';

class SplashPage extends StatefulWidget {
  static final String id = 'splash_page';

  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  _initTimer() {
    Timer(Duration(seconds: 2), () {
      _callHomePage();
    });
  }

  _callHomePage() {
    Navigator.pushReplacementNamed(context, HomePage.id);
  }

  _initNotification() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true);
    print("Settings registered: ${settings.authorizationStatus}");
    _firebaseMessaging.getToken().then((token)
    {
       assert(token != null);
      print(token);
      Prefs.saveFCM(token);
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initTimer();
    _initNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context)
            .size
            .width, // ekrandi eni avtomaticski teldiki bn bir xil boladi
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(193, 53, 132, 1),
              Color.fromRGBO(131, 58, 180, 1),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  "Instagram",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 45,
                      fontFamily: "Billabong"),
                ),
              ),
            ),
            Text(
              "All rights reserved",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
