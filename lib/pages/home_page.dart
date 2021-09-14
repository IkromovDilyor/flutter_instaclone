import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instaclone/pages/my_feed_page.dart';
import 'package:flutter_instaclone/pages/my_likes_page.dart';
import 'package:flutter_instaclone/pages/my_profile_page.dart';
import 'package:flutter_instaclone/pages/my_search_page.dart';
import 'package:flutter_instaclone/pages/my_upload_page.dart';
import 'package:flutter_instaclone/services/utils_service.dart';

class HomePage extends StatefulWidget {
  static final String id = 'home_page';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  PageController?  _pageController;
  int _currentTap = 0;

  _initNotification() {
    // onMessage: When the app is open and it receives a push notification

    FirebaseMessaging.onMessage.listen((message) {
      print("onMessage: $message");
      Utils.showLocalNotification(message);
    });

    // workaround for onLaunch: When the app is completely closed (not in the background) and opened directly from the push notification
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      // print("onLaunch: $message");
    });

    // replacement for onResume: When the app is in the background and opened directly from the push notification.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onResume: $message");
    });

  }

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initNotification();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          MyFeedPage(pageController: _pageController!),
          MySearchPage(),
          MyUploadPage(pageController: _pageController!),
          MyLikesPage(),
          MyProfilePage(),
        ],
        onPageChanged: (int index) {
          setState(() {
            _currentTap = index;
          });
        },
      ),
      bottomNavigationBar: CupertinoTabBar(
        onTap: (int index) {
          setState(() {
            _currentTap = index;
            _pageController!.animateToPage(index,
                duration: Duration(milliseconds: 200), curve: Curves.easeIn);
          });
        },
        currentIndex: _currentTap,
        activeColor: Color.fromRGBO(193, 53, 132, 1),
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 30,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              size: 30,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_box,
              size: 30,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite,
              size: 30,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}
