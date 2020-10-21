import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notification{
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid;
  var initializationSettingsIOS;
  var initializationSettings;
  void showNotification(int waitTime,String msg) async {

    initializationSettingsAndroid = new AndroidInitializationSettings('ic_stat_notif');
    initializationSettingsIOS = new IOSInitializationSettings();
    initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);
    var scheduledNotificationDateTime =
    new DateTime.now().add(new Duration(milliseconds: waitTime));
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        '0', 'Deep6', 'Notification',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.schedule(
        0,
        'C.U.R.E.',
        msg,
        scheduledNotificationDateTime,
        platformChannelSpecifics);

  }

  Future onSelectNotification(String payload) async {
    //Here you can do sth
    if (payload != null) {}
  }
  void notificationCancel(){
    flutterLocalNotificationsPlugin.cancelAll();
  }
}