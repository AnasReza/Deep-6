import 'package:deep6/audio_player/click_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class Epilogue extends StatefulWidget {
  String description,backText;
  Epilogue(String des,String backStr) {
    this.description = des;
    this.backText=backStr;
  }

  @override
  EpilogueState createState() => new EpilogueState();

}
class EpilogueState extends State<Epilogue>with TickerProviderStateMixin{
  String des, text;
  double width,height;
  double mainFontSize = 20.0;
  double buttonFontSize = 20.0;
  dynamic animatedText = new SizedBox();
  bool isEnabled = false;
  ClickPlayer cPlay;
  AnimationController controller;
  var animDuration = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cPlay = new ClickPlayer();
    controller = new AnimationController(
      duration: Duration(milliseconds: 0),
      vsync: this,
    );
    des=widget.description;
    text=widget.backText;
    initAnimatedText();
  }

  void initAnimatedText() {
    //animDuration = length * 50 seems to be the most natural
    animDuration = des.length * 50;
    controller.duration = Duration(milliseconds: animDuration);

    Animation<int> typeWriter = new StepTween(
        begin: 0, end: des.length)
        .animate(new CurvedAnimation(parent: controller, curve: Curves.linear));

    Widget buildAnimation(BuildContext context, Widget child) {
      String txt = des.substring(0, typeWriter.value);
      Text text1 = new Text(
        txt,
        style: new TextStyle(
          color: Colors.white,
          fontSize: mainFontSize,
        ),
        textAlign: TextAlign.start,
      );
      return new SizedBox(
        width: double.infinity,
        child: new Container(
          child: text1,
          padding: EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0, bottom: 20.0),
        ),
      );
    }

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.stop();
        setState(() {
          isEnabled = true;
        });
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
    final mediaQueryData = MediaQuery.of(context);
    width = mediaQueryData.size.width;
    height = mediaQueryData.size.height;
    if (Platform.isIOS) {height = height * 0.95;}
    mainFontSize = (height + width) / 55;
    buttonFontSize = (height + width) / 60;

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
            margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 30.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new SizedBox(
                  width: double.infinity,
                  height: height * 0.80,
                  child: new Container(
                    color: Color.fromRGBO(0, 0, 0, 0.0),
                    child: ListView(
                      children: <Widget>[animatedText],
                    ),
                  ),
                ),
                // para,
                new Expanded(
                  child: new Align(
                    alignment: FractionalOffset.bottomCenter,
                    child:
                    new SafeArea(
                      child: new SizedBox(
                        width: double.infinity,
                        height: height * 0.05,
                        child: new MaterialButton(
                          color: Color.fromRGBO(0, 0, 0, 0.8),
                          onPressed: () {Navigator.of(context).pop();},
                          child: new Text(
                            text,
                            style: TextStyle(
                                color: isEnabled
                                    ? Colors.white
                                    : Colors.transparent,
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

  @override
  void dispose() {
    if (controller != null) {
      controller.dispose();
    }
    super.dispose();
  }

}
