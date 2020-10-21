import 'dart:convert';
import 'dart:io';

import 'package:deep6/audio_player/click_player.dart';
import 'package:deep6/game/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deep6/utility/preference.dart';

class NewGame extends StatefulWidget {
  String language = "de";

  NewGame(String language){
    this.language = language;
  }

  @override
  NewGameState createState() => new NewGameState();
}

class NewGameState extends State<NewGame> with TickerProviderStateMixin {
  double width, height;
  List<String> paraList = new List<String>();
  List<String> buttonList = new List<String>();
  MaterialButton nextButton;
  int index = 0;
  ClickPlayer cPlay;
  String mainText = "";
  String buttonText = "";
  var animDuration = 0;
  double mainFontSize = 20.0;
  double buttonFontSize = 20.0;
  AnimationController controller;
  dynamic animatedText = new SizedBox();
  bool isEnabled = false;
  String lang = "de";

  @override
  void initState() {
    super.initState();
    cPlay = new ClickPlayer();
    controller = new AnimationController(
      duration: Duration(milliseconds: 0),
      vsync: this,
    );
    lang = widget.language;
    readJson();
  }

  readJson() async {
    String data = await rootBundle.loadString('assets/json/$lang/prologue.json');
    await SharedPreferences.getInstance().then((p) {

      bool prologueContinuation = p.getBool(PrefsKeys.bool_prologue_continuation);
      if (prologueContinuation != null && prologueContinuation == true){
        index = p.getInt(PrefsKeys.prologue_index);
      }

      try {
        Map<String, dynamic> jsonResult = json.decode(data);
        List<dynamic> jsonArray = jsonResult['index'];

        for (int i = 0; i < jsonArray.length; i++) {
          paraList.add(jsonArray[i]['text']);
          buttonList.add(jsonArray[i]['button']);
        }

        setState(() {
          mainText = paraList[index];
          buttonText = buttonList[index];
        });

        initAnimatedText();

      } on FormatException catch (e) {}
    });
  }

  void onButtonPressed() async {
    cPlay.playClick();
    if (isEnabled) {
      index++;

      if (index < buttonList.length) {
        setState(() {
          mainText = paraList[index];
          buttonText = buttonList[index];
          isEnabled = false;
        });

        await SharedPreferences.getInstance().then((p) {
          p.setInt(PrefsKeys.prologue_index, index);
          p.setBool(PrefsKeys.bool_prologue_continuation, true);
        });

        initAnimatedText();

      } else if (index == buttonList.length) {

        await SharedPreferences.getInstance().then((p) {
          p.setInt(PrefsKeys.prologue_index, 0);
          p.setBool(PrefsKeys.bool_prologue_continuation, false);
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileFull(lang),
          ),
        );

      }

    }
  }

  void initAnimatedText() {
    //animDuration = length * 50 seems to be the most natural
    animDuration = mainText.length * 50;
    controller.duration = Duration(milliseconds: animDuration);

    Animation<int> typeWriter = new StepTween(
        begin: 0, end: mainText.length)
        .animate(new CurvedAnimation(parent: controller, curve: Curves.linear));

    Widget buildAnimation(BuildContext context, Widget child) {
      String txt = mainText.substring(0, typeWriter.value);
      Text text1 = new Text(
        txt,
        style: new TextStyle(
          color: Colors.white,
          fontSize: mainFontSize,
          height: 1.2,
          fontWeight: FontWeight.w300,
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
                          onPressed: () {onButtonPressed();},
                          child: new Text(
                            buttonText,
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
