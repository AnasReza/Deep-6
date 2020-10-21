import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path/path.dart';

class Notifications{
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  var initializationSettingsAndroid;
  var initializationSettingsIOS ;
  var initializationSettings ;

  Notifications(){
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    initializationSettingsAndroid = new AndroidInitializationSettings('ic_stat_notif');
    initializationSettingsIOS = new IOSInitializationSettings();
    initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {
    //Here you can do sth
    if (payload != null) {}
  }

  displayingNoti() async{

    var scheduledNotificationDateTime =
    new DateTime.now().add(new Duration(seconds: 10));
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        '0', 'Deep6', 'Notification',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.schedule(
        0,
        'scheduled title',
        'scheduled body',
        scheduledNotificationDateTime,
        platformChannelSpecifics);

  }
}