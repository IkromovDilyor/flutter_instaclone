import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_instaclone/pages/home_page.dart';
import 'package:flutter_instaclone/pages/signin_page.dart';
import 'package:flutter_instaclone/pages/signup_page.dart';
import 'package:flutter_instaclone/pages/splash_page.dart';
import 'package:flutter_instaclone/services/prefs_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  var initAndroidSetting = AndroidInitializationSettings("@mipmap/ic_launcher");
  var initIosSetting = IOSInitializationSettings();
  var initSetting = InitializationSettings(android: initAndroidSetting, iOS: initIosSetting);
  await FlutterLocalNotificationsPlugin().initialize(initSetting);
SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_)  {
  runApp(MyApp());
});
}

class MyApp extends StatelessWidget {
  // login qilingan qilinmaganiga qarab qaysi pagega borishni tanledigon method. firebase ucun
  Widget _callStartPage() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(), // login qilingan qilinmaganini aytib beregon joyi
      builder: (BuildContext context, AsyncSnapshot userSnapshot) {
        if (userSnapshot.hasData) {
          Prefs.saveUserId(userSnapshot.data.uid);
          return SplashPage();
        } else {
          Prefs.removeUserId();
          return SignInPage();
        }
      },
    );}
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: _callStartPage(),
      routes: {
        SplashPage.id: (context) => SplashPage(),
        SignUpPage.id: (context) => SignUpPage(),
        SignInPage.id: (context) => SignInPage(),
        HomePage.id: (context) => HomePage(),
      },
    );
  }
}
