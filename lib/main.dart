import 'dart:io';
import 'dart:async';

import 'package:deep6/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Deep 6',
      home: ChapterScreen(),
    );
  }
}

class ChapterScreen extends StatefulWidget {
  @override
  ChapterState createState() => new ChapterState();
}

class ChapterState extends State<ChapterScreen> with SingleTickerProviderStateMixin{
  double width, height;
  static Timer timer;

  @override
  void initState() {
    super.initState();
    timer = new Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainMenu(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    width = mediaQueryData.size.width;
    height = mediaQueryData.size.height;

    return WillPopScope(
        child: new Scaffold(
          body: new Column(
            children: <Widget>[
              new Container(
                  width: width,
                  height: height,
                  decoration: new BoxDecoration(
                    color: const Color(0xff000000),
                    image: new DecorationImage(
                      image: AssetImage('assets/images/splash_screen.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
            ],
          ),
        ),
        onWillPop: () {
          exit(0);
        });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

}
