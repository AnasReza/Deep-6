import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:deep6/audio_player/click_player.dart';

class ProfileDetails extends StatefulWidget {
  String character;
  String text;
  String avatar;
  String profile_close;
  String leftBio;
  String rightBio;
  int color;

  ProfileDetails(String character, String text, int color, String avatar, String leftBio, String rightBio, String close) {
    this.character = character;
    this.text = text;
    this.color = color;
    this.avatar = avatar;
    this.leftBio = leftBio;
    this.rightBio = rightBio;
    this.profile_close = close;
  }

  @override
  ProfileDetailState createState() => new ProfileDetailState();
}

class ProfileDetailState extends State<ProfileDetails> with TickerProviderStateMixin {

  double width, height;
  String character;
  String text;
  String avatar;
  String profile_close;
  String leftBio;
  String rightBio;
  int color;
  ClickPlayer cPlay;
  AnimationController controller;
  dynamic animatedText = new SizedBox();
  var animDuration = 0;
  double mainFontSize = 20.0;
  double buttonFontSize = 15.0;

  @override
  void initState() {
    super.initState();
    character = widget.character;
    text = widget.text;
    avatar = widget.avatar;
    color = widget.color;
    profile_close = widget.profile_close;
    leftBio = widget.leftBio;
    rightBio = widget.rightBio;
    cPlay = new ClickPlayer();
    controller = new AnimationController(
      duration: Duration(milliseconds: 0),
      vsync: this,
    );
  }

  void initAnimatedText() {
    //animDuration = length * 50 seems to be the most natural
    animDuration = text.length * 50;
    controller.duration = Duration(milliseconds: animDuration);

    Animation<int> typeWriter = new StepTween(
        begin: 0, end: text.length)
        .animate(new CurvedAnimation(parent: controller, curve: Curves.linear));

    Widget buildAnimation(BuildContext context, Widget child) {
      String txt = text.substring(0, typeWriter.value);
      Text text1 = new Text(
        txt,
        style: new TextStyle(
          color: Colors.white,
          fontSize: mainFontSize,
          height: 1.1,
        ),
        textAlign: TextAlign.start,
      );
      return new SizedBox(
        width: double.infinity,
        child: new Container(
          child: text1
        ),
      );
    }

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.stop();
      }
    });

    setState(() {
      animatedText = new AnimatedBuilder(animation: typeWriter, builder: buildAnimation);
    });
    controller.reset();

    new Future.delayed(const Duration(seconds: 1), () {
      controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    final mediaQueryData = MediaQuery.of(context);
    width = mediaQueryData.size.width;
    height = mediaQueryData.size.height;
    if (Platform.isIOS) {height = height * 0.90;}
    mainFontSize = (height + width) / 70;
    buttonFontSize = (height + width) / 55;
    initAnimatedText();
    return new Container(
      decoration: new BoxDecoration(
          image: DecorationImage(
              image: new AssetImage('assets/images/bg_main.png'),
              fit: BoxFit.cover)),
      child: new Scaffold(
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.0),
        appBar: new AppBar(
          elevation: 0.0,
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.0),
          leading: new SizedBox(
            width: double.infinity,
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[Container()],
            ),
          ),
          actions: <Widget>[
            new IconButton(
                icon: Icon(Icons.settings_power),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ],
          centerTitle: true,
        ),
        body: new Center(
          child: new Container(
            margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Container(
                  margin: EdgeInsets.only(bottom: 5.0),
                  child: new SizedBox(
                    width: double.infinity,
                    child: new Container(
                      child: new Center(
                        child: new Image.asset(
                          avatar,
                          fit: BoxFit.contain,
                          height: height * 0.125,
                        ),
                      ),
                    ),
                  ),
                ),
                new SizedBox(
                  width: double.infinity,
                  child: new Container(
                    margin: EdgeInsets.only(top: 10.0,bottom: 5.0),
                    padding: EdgeInsets.all(5.0),
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    child: new Center(
                      child: new Text(
                        character,
                        style: new TextStyle(
                          color: Color(color).withOpacity(1.0),
                          fontSize: buttonFontSize,
                        ),
                      ),
                    ),
                  ),
                ),
                new SizedBox(
                  width: double.infinity,
                  height: height * 0.65,
                  child: new Container(
                    color: Colors.black.withOpacity(0.7),
                    padding: EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0, bottom: 20.0),
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: ListView(
                      children: <Widget>[
                        new Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            new SizedBox(
                              width: width * 0.4,
                              child: new Text(
                                leftBio,

                                style: new TextStyle(
                                  color: Colors.white,
                                  fontSize: mainFontSize,
                                  height: 1.1,
                                ),
                              ),
                            ),
                            new SizedBox(
                              width: width * 0.5,
                              child: new Text(
                                rightBio,
                                style: new TextStyle(
                                  color: Colors.white,
                                  fontSize: mainFontSize,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        animatedText
                      ],
                    ),
                  ),
                ),
                new Expanded(
                  child: new Align(
                    alignment: FractionalOffset.center,
                    child:
                    new SafeArea(
                      child: new SizedBox(
                        width: double.infinity,
                        height: height * 0.05,
                        child: new MaterialButton(
                          color: Color.fromRGBO(0, 0, 0, 0.8),
                          onPressed: () {Navigator.pop(context);},
                          child: new Text(
                            profile_close,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: buttonFontSize),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
