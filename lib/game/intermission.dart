import 'dart:convert';
import 'dart:io';

import 'package:deep6/audio_player/click_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Intermission extends StatefulWidget {
  int chapterIndex = 0;
  String language = "de";

  Intermission(int chapterIndex, String language){
    this.chapterIndex = chapterIndex;
    this.language = language;
  }

  @override
  IntermissionState createState() => new IntermissionState();
}

class IntermissionState extends State<Intermission> with TickerProviderStateMixin {

  double width, height;
  var character = "C.U.R.E.";
  var mainText = "";
  var avatar = "assets/images/profile_cure.png";
  var btnText = "";
  ClickPlayer cPlay;
  String bgImg = "";
  String lang = "de";
  double mainFontSize = 20.0;
  double buttonFontSize = 15.0;
  var isEnabled = false;
  AnimationController controller;
  dynamic animatedText = new SizedBox();
  var animDuration = 0;
  int color = 6860244;

  @override
  void initState() {
    super.initState();
    setBg(widget.chapterIndex);
    lang = widget.language;
    readJson(widget.chapterIndex);
    cPlay = new ClickPlayer();
    controller = new AnimationController(
      duration: Duration(milliseconds: 0),
      vsync: this,
    );
  }

  void setBg(int chapterIndex) {
    if ((chapterIndex <= 7) || (chapterIndex > 14)){
      bgImg = "assets/images/comm_blue.png";
    } else {
      bgImg = "assets/images/comm_red.png";
    }
  }

  Future readJson(int chapter) async {
    try {
      var urlString = "assets/json/$lang/chapter_${(chapter - 1).toString()}.json";
      var data = await rootBundle.loadString(urlString);
      var decodedData = json.decode(data);

      //Scene Array
      List<dynamic> sceneArray = decodedData['story'];

      //Main Text
      List<dynamic> textArray = sceneArray.last['maintext'];

      //Button Text
      List<dynamic> lbArray = sceneArray.last['leftButton'];

      setState(() {
        mainText = textArray[0]['text'];
        btnText = lbArray[0]['lbText'];
      });

      initAnimatedText();

    } on FormatException catch (e) {
      //print("${e.toString()} error");
    }
  }

  void initAnimatedText() {
    //animDuration = length * 50 seems to be the most natural
    animDuration = mainText.length * 50;
    controller.duration = Duration(milliseconds: animDuration);

    Animation<int> typeWriter = new StepTween(
        begin: 0, end: mainText.length)
        .animate(new CurvedAnimation(parent: controller, curve: Curves.linear));

    var textAlign = TextAlign.start;
    if (mainText.startsWith("\n\n\n\n***")) {
      textAlign = TextAlign.center;
    }

    Widget buildAnimation(BuildContext context, Widget child) {
      String txt = mainText.substring(0, typeWriter.value);
      Text text1 = new Text(
        txt,
        style: new TextStyle(
          color: Color(color).withOpacity(1.0),
          fontSize: mainFontSize,
        ),
        textAlign: textAlign,
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
    if (Platform.isIOS) {height = height * 0.92;}
    mainFontSize = (height + width) / 55;
    buttonFontSize = (height + width) / 80;

    var charImage = new Image.asset(
      avatar,
      fit: BoxFit.contain,
      height: height * 0.15,
    );

    var charName = new Text(
      character,
      style: new TextStyle(
        color: Color(color).withOpacity(1.0),
        fontSize: mainFontSize,
      ),
    );

    var imageRow = new Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        new Container(
          child: charImage,
          margin: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 10.0),
        )
      ],
    );

    var charRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        new Container(
          child: charName,
          margin: EdgeInsets.fromLTRB(15.0,5.0,15.0,5.0),
        )
      ],
    );

    var buttonText = new Text(
      btnText,
      style: new TextStyle(
          fontSize: buttonFontSize,
          color: isEnabled
              ? Colors.white
              : Colors.transparent),
      textAlign: TextAlign.center,
      softWrap: true,
      maxLines: 10,
    );

    var theButton = new MaterialButton(
      key: null,
      onPressed: () {
        cPlay.playClick();
        if (isEnabled) {
            Navigator.pop(context);
        }
      },
      color: Color.fromRGBO(0, 0, 0, 0.9),
      child: new SizedBox(
        child: new Container(
          margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: new Center(
            child: buttonText,
          ),
        ),
      ),
    );

    return new Scaffold(
      backgroundColor: new Color(0xFF000000),
      body: new Container(
        height: double.infinity,
        width: double.infinity,
        decoration: new BoxDecoration(
            image: DecorationImage(
                image: new AssetImage(bgImg),
                fit: BoxFit.cover)),
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              new SafeArea(
                top: true,
                bottom: false,
                child: new SizedBox(
                  child: new Container(
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        new IconButton(
                            color: Colors.white,
                            icon: Icon(Icons.settings_power),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                      ],
                    ),
                  ),
                  width: double.infinity,
                ),
              ),
              new SizedBox(
                width: double.infinity,
                child: new Container(
                  child: new Center(
                    child: imageRow,
                  ),
                ),
              ),
              new SizedBox(
                width: double.infinity,
                child: new Container(
                  color: Color.fromRGBO(0, 0, 0, 0.9),
                  child: new Center(
                    child: charRow,
                  ),
                ),
              ),
              new SizedBox(
                width: double.infinity,
                height: height * 0.45,
                child: new Container(
                  margin: EdgeInsets.symmetric(vertical: 5.0),
                  color: Color.fromRGBO(0, 0, 0, 0.9),
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: ListView(
                      children: <Widget>[animatedText],
                    ),
                  ),
                ),
              ),
              new SafeArea(
                top: false,
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new SizedBox(
                      width: width * 1,
                      height: height * 0.25,
                      child: theButton,
                    ),
                  ],
                ),
              ),
            ]),
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
