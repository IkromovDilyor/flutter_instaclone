import 'dart:io';
import 'dart:math';

import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instaclone/services/prefs_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils {
  static void fireToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.purple,
      textColor: Colors.white,
      fontSize: 16,
    );
  }

  static String currentDate() {
    DateTime now = DateTime.now();

    String convertedDateTime =
        "${now.year.toString()}-${now.month.toString().padLeft(2, "0")}-${now.day.toString().padLeft(2, "0")} ${now.hour.toString()}:${now.minute.toString()}";
    return convertedDateTime;
  }

  static Future<bool> dialogCommmon(
      BuildContext context, String title, String message, bool isSingle) async {
    return await showDialog(
        context: context,
        builder: (BuildContext) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              !isSingle
                  ? TextButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    )
                  : SizedBox.shrink(),
              TextButton(
                child: Text("Confirm"),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              )
            ],
          );
        });
  }

  static Future<Map<String, String>> deviceParams() async {
    Map<String, String> params = Map();
    var deviceInfo = DeviceInfoPlugin();
    String? fcm_token = await Prefs.loadFCM();

    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      params.addAll({
        "device_id": iosDeviceInfo.identifierForVendor,
        "device_type": "I",
        "device_token": fcm_token!,
      });
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      params.addAll({
        "device_id": androidDeviceInfo.androidId,
        "device_type": "A",
        "device_token": fcm_token!,
      });
    }
    return params;
  }

  static Future showLocalNotification(RemoteMessage message) async {
    String title = message.data["title"];
    String body = message.data["body"];

    if (Platform.isAndroid) {
      title = message.data["notification"]["title"];
      body = message.data["notification"]["body"];
    }

    var android = AndroidNotificationDetails(
        "channelId", "channelName", "channelDescription");
    var iOS = IOSNotificationDetails();
    var platform = NotificationDetails(android: android, iOS: iOS);

    num a = pow(2, 31) - 1;
    int b = a.toInt();

    int id = Random().nextInt(b);
    await FlutterLocalNotificationsPlugin().show(id, title, body, platform);
  }
}
