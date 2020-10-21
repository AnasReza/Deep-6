import 'dart:convert';
import 'dart:io';

import 'package:deep6/audio_player/click_player.dart';
import 'package:deep6/game/epilogue.dart';
import 'package:deep6/game/profile_details.dart';
import 'package:deep6/generated/i18n.dart';
import 'package:deep6/utility/countDown.dart';
import 'package:deep6/utility/preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deep6/utility/notification.dart' as noti;
import 'package:deep6/utility/waiting_times.dart';

class Scene extends StatefulWidget {
  int mainIndex, chapterIndex = 1;
  String lang = "de";
  List<List<String>> character = new List<List<String>>();
  List<List<String>> text = new List<List<String>>();
  List<dynamic> mainTextColor = new List<dynamic>();
  List<List<dynamic>> mainTextList = new List<List<dynamic>>();
  List<List<String>> avatar = new List<List<String>>();
  List<String> lbText = new List<String>();
  List<dynamic> lbTextTarget = new List<dynamic>();
  List<dynamic> lbTextColor = new List<dynamic>();
  List<String> rbText = new List<String>();
  List<dynamic> rbTextTarget = new List<dynamic>();
  List<dynamic> rbTextColor = new List<dynamic>();

  Scene(
      {Key key,
      this.lang,
      this.chapterIndex,
      this.mainIndex,
      this.character,
      this.mainTextList,
      this.text,
      this.mainTextColor,
      this.avatar,
      this.lbText,
      this.lbTextTarget,
      this.lbTextColor,
      this.rbText,
      this.rbTextTarget,
      this.rbTextColor})
      : super(key: key);

  @override
  SceneState createState() => new SceneState();
}

class SceneState extends State<Scene> with TickerProviderStateMixin {
  double width, height;
  List<String> content = new List<String>();
  CountDown customTimer;
  PrefsKeys prefs;
  int mainIndex = 0;
  int chapterIndex = 1;
  String lang = "de";
  bool isEnabled = false;
  List<List<String>> character = new List<List<String>>();
  List<List<dynamic>> mainTextList = new List<List<dynamic>>();
  List<List<String>> text = new List<List<String>>();
  List<dynamic> mainTextColor = new List<dynamic>();
  List<List<String>> avatar = new List<List<String>>();

  List<String> lbText = new List<String>();
  List<dynamic> lbTextTarget = new List<dynamic>();
  List<dynamic> lbTextColor = new List<dynamic>();

  List<String> rbText = new List<String>();
  List<dynamic> rbTextTarget = new List<dynamic>();
  List<dynamic> rbTextColor = new List<dynamic>();

  List<String> characterProfile = new List<String>();
  List<String> textProfile = new List<String>();
  List<String> avatarProfile = new List<String>();
  List<String> leftBioProfile = new List<String>();
  List<String> rightBioProfile = new List<String>();
  List<int> colorProfile = new List<int>();

  Image cureImage, mullerImage, orlowImage;
  Text textCure, textMuller, textOrlow;
  Text charName, mainText, leftText, rightText;
  MaterialButton leftButton, rightButton;
  int colorCure = 6860244;
  int colorMuller = 16711910;
  int colorOrlaw = 11681540;
  ClickPlayer cPlay;
  var mainTextStr;
  static AnimationController controller;
  Row imageRow, charRow;
  bool visibilityCure = false,
      visibilityMuller = false,
      visibilityOrlow = false;
  String cureImg, mullerImg, orlowImg;
  String charCure, charMuller, charOrlaw;
  AnimatedBuilder animationBuilder;
  List<dynamic> avInt;
  List<dynamic> charStr;
  List<List<dynamic>> mainList;
  List<dynamic> animList;
  var animDuration = 0;
  String bgImg = "";
  double mainFontSize = 20.0;
  double buttonFontSize = 15.0;
  noti.Notification notify;
  double leftButtonWidthMultiplier = 0.49;
  double rightButtonWidthMultiplier = 0.49;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    lang = widget.lang;
    mainIndex = widget.mainIndex;
    if (mainIndex == -1) {
      mainIndex = 0;
    }
    chapterIndex = (widget.chapterIndex != null) ? widget.chapterIndex : 1;
    mainTextStr = new StringBuffer();
    character = widget.character;
    mainTextList = widget.mainTextList;
    text = widget.text;
    mainTextColor = widget.mainTextColor;
    avatar = widget.avatar;
    lbText = widget.lbText;
    lbTextTarget = widget.lbTextTarget;
    lbTextColor = widget.lbTextColor;
    rbText = widget.rbText;
    rbTextTarget = widget.rbTextTarget;
    rbTextColor = widget.rbTextColor;
    cPlay = new ClickPlayer();
    animList = new List<dynamic>();
    animList.add(new Container());
    animList.add(new Container());
    animList.add(new Container());
    controller = new AnimationController(
      duration: Duration(milliseconds: 0),
      vsync: this,
    );
    preference();
    initAnimatedText(0);
    setBg(chapterIndex);
    readProfileJson();
  }

  Future readProfileJson() async {
    try {
      var data =
          await rootBundle.loadString('assets/json/$lang/profile_details.json');
      var decodedData = json.decode(data);
      //middleText = decodedData['chapters'][0]['text'];
      List<dynamic> sceneArray = decodedData['profile'];
      for (int i = 0; i < sceneArray.length; i++) {
        characterProfile.add(sceneArray[i]['character']);
        leftBioProfile.add(sceneArray[i]['leftBio']);
        rightBioProfile.add(sceneArray[i]['rightBio']);
        textProfile.add(sceneArray[i]['text']);
        colorProfile.add(sceneArray[i]['color']);
        if (sceneArray[i]['character'] == "C.U.R.E.") {
          avatarProfile.add('assets/images/profile_cure.png');
        } else if (sceneArray[i]['character'] == "Dr. Robin Muller") {
          avatarProfile.add('assets/images/profile_mueller.png');
        } else {
          avatarProfile.add('assets/images/profile_orlow.png');
        }
      }
    } on FormatException catch (e) {
      //print("${e.toString()} error");
    }
  }

  readEpilogJson() async {
    try {
      String data = await rootBundle.loadString('assets/json/$lang/epilogue.json');
      Map<String, dynamic> jsonResult = json.decode(data);
      List<dynamic> jsonArray = jsonResult['index'];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Epilogue(jsonArray[0]['text'],jsonArray[0]['button']),
        ),
      );
    } on FormatException catch (e) {
      //print("${e.toString()} error");
    }
  }

  void preference() async {
    await SharedPreferences.getInstance().then((pref) {
      pref.setBool(PrefsKeys.bool_continuation, true);
      pref.setInt(PrefsKeys.current_index, mainIndex);
    });
  }

  void setBg(int chapterIndex) {
    if ((chapterIndex <= 7) || (chapterIndex >= 14)) {
      bgImg = "assets/images/comm_blue.png";
    } else {
      bgImg = "assets/images/comm_red.png";
    }
  }

  void loadImages(){
    cureImage = new Image.asset(
      "assets/images/profile_cure.png",
      fit: BoxFit.contain,
      height: height * 0.15,
    );
    mullerImage = new Image.asset(
      "assets/images/profile_mueller.png",
      fit: BoxFit.contain,
      height: height * 0.15,
    );
    orlowImage = new Image.asset(
      "assets/images/profile_orlow.png",
      fit: BoxFit.contain,
      height: height * 0.15,
    );
  }

  void setScene(int index) async {
    controller.reset();
    controller = new AnimationController(
      duration: Duration(milliseconds: 0),
      vsync: this,
    );

    animList = new List<dynamic>();
    animList.add(new Container());
    animList.add(new Container());
    animList.add(new Container());

    cPlay.playClick();

    mainIndex = index;

    await SharedPreferences.getInstance().then((p) {
      p.setInt(PrefsKeys.current_index, mainIndex);
      p.setInt(PrefsKeys.chapter_index, chapterIndex);
    });

    if (mainIndex == -1) {
      await SharedPreferences.getInstance().then((pref) {
        notify = new noti.Notification();
        int waitTime = 0;
        int chpIndex = pref.getInt(PrefsKeys.chapter_index);
        switch (chpIndex) {
          case 1:
            waitTime = Waiting_Times.chapter_1;
            break;
          case 2:
            waitTime = Waiting_Times.chapter_2;
            break;
          case 3:
            waitTime = Waiting_Times.chapter_3;
            break;
          case 4:
            waitTime = Waiting_Times.chapter_4;
            break;
          case 5:
            waitTime = Waiting_Times.chapter_5;
            break;
          case 6:
            waitTime = Waiting_Times.chapter_6;
            break;
          case 7:
            waitTime = Waiting_Times.chapter_7;
            break;
          case 8:
            waitTime = Waiting_Times.chapter_8;
            break;
          case 9:
            waitTime = Waiting_Times.chapter_9;
            break;
          case 10:
            waitTime = Waiting_Times.chapter_10;
            break;
          case 11:
            waitTime = Waiting_Times.chapter_11;
            break;
          case 12:
            waitTime = Waiting_Times.chapter_12;
            break;
          case 13:
            waitTime = Waiting_Times.chapter_13;
            break;
          case 14:
            waitTime = Waiting_Times.chapter_14;
            break;
        }
        chpIndex++;
        pref.setInt(PrefsKeys.chapter_index, chpIndex);
        pref.setInt(PrefsKeys.waiting_time, waitTime);
        pref.setInt(PrefsKeys.str_timestamp, new DateTime.now().millisecondsSinceEpoch);
        notify.showNotification(waitTime,S.of(context).notification_message);
        Navigator.pop(context);
      });
    } else if (mainIndex == -2) {
      await SharedPreferences.getInstance().then((pref) {
        pref.setBool(PrefsKeys.bool_continuation, false);
        pref.setInt(PrefsKeys.chapter_index, 0);
        pref.setInt(PrefsKeys.current_index, 0);
      });
      readEpilogJson();
    } else {
      visibilityOrlow = false;
      visibilityMuller = false;
      visibilityCure = false;

      setState(() {
        isEnabled = false;
        avInt.clear();
        animationBuilder = null;
        leftText = null;
        rightText = null;

        avInt = avatar[mainIndex];

        for (int avIndex = 0; avIndex < avInt.length; avIndex++) {
          if (avInt[avIndex].contains('profile_cure')) {
            visibilityCure = true;
            cureImg = avInt[avIndex];
            textCure = new Text(
              "C.U.R.E.",
              style: new TextStyle(
                  color: Color(colorCure).withOpacity(1.0),
                  fontSize: mainFontSize),
            );
          } else if (avInt[avIndex].contains('profile_mueller')) {
            visibilityMuller = true;
            mullerImg = avInt[avIndex];
            textMuller = new Text(
              "Dr. Muller",
              style: new TextStyle(
                  color: Color(colorMuller).withOpacity(1.0),
                  fontSize: mainFontSize),
            );
          } else if (avInt[avIndex].contains('profile_orlow')) {
            visibilityOrlow = true;
            orlowImg = avInt[avIndex];
            textOrlow = new Text(
              "Prof. Orlow",
              style: new TextStyle(
                  color: Color(colorOrlaw).withOpacity(1.0),
                  fontSize: mainFontSize),
            );
          }
        }

        imageRow = new Row(
          children: <Widget>[
            visibilityCure ? cureImage : new Container(),
            visibilityMuller ? mullerImage : new Container(),
            visibilityOrlow ? orlowImage : new Container(),
          ],
        );

        charRow = new Row(
          children: <Widget>[
            visibilityCure ? textCure : new Container(),
            visibilityMuller ? textMuller : new Container(),
            visibilityOrlow ? textOrlow : new Container(),
          ],
        );

        leftText = new Text(
          lbText[mainIndex],
          style: new TextStyle(
              fontSize: buttonFontSize,
              color: isEnabled
                  ? Color(lbTextColor[mainIndex]).withOpacity(1.0)
                  : Colors.transparent),
          textAlign: TextAlign.center,
          softWrap: true,
          maxLines: 10,
        );

        if (rbText[mainIndex] == "") {
          leftButtonWidthMultiplier = 1;
          rightButtonWidthMultiplier = 0.00;
          rightText = null;
          rightButton = new MaterialButton(
            key: null,
            onPressed: () {},
            color: Color.fromRGBO(0, 0, 0, 0.9),
            height: 0.0,
            minWidth: 0.0,
            child: null,
          );
        } else {
          leftButtonWidthMultiplier = 0.49;
          rightButtonWidthMultiplier = 0.49;
          rightText = new Text(
            rbText[mainIndex],
            style: new TextStyle(
              fontSize: buttonFontSize,
              color: isEnabled
                  ? Color(rbTextColor[mainIndex]).withOpacity(1.0)
                  : Colors.transparent,
            ),
            textAlign: TextAlign.center,
          );
        }
      });
      initAnimatedText(0);
    }
  }

  void initAnimatedText(int textIndex) {
    if ((mainIndex > -1)&&(mainIndex < mainTextList.length)) {
      //animDuration = length * 50 seems to be the most natural
      animDuration = mainTextList[mainIndex][textIndex]['text'].length * 50;

      controller.duration = Duration(milliseconds: animDuration);

      Animation<int> typeWriter = new StepTween(
          begin: 0, end: mainTextList[mainIndex][textIndex]['text'].length)
          .animate(
          new CurvedAnimation(parent: controller, curve: Curves.linear));

      var colorText = mainTextList[mainIndex][textIndex]['color'];
      var fontStyleText = FontStyle.normal;
      if ((colorText == 16711910) || (colorText == 11681540)) {
        fontStyleText = FontStyle.italic;
      }
      var textAlign = TextAlign.start;
      if (mainTextList[mainIndex][textIndex]['text'].startsWith("\n\n\n\n***")){
        textAlign = TextAlign.center;
      }

      Widget buildAnimation(BuildContext context, Widget child) {
        String txt = mainTextList[mainIndex][textIndex]['text'].substring(
            0, typeWriter.value);
        Text text1 = new Text(
          txt,
          style: new TextStyle(
            color: Color(colorText).withOpacity(1.0),
            fontSize: mainFontSize,
            fontStyle: fontStyleText,
          ),
          textAlign: textAlign,
        );
        return new SizedBox(
          width: double.infinity,
          child: new Container(
            child: text1,
            padding: const EdgeInsets.all(15.0),
          ),
        );
      }

      controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            animList[textIndex] = getStaticText(textIndex);
            isEnabled = false;
          });
          if (textIndex < (mainTextList[mainIndex].length - 1)) {
            print("textIndex: " + textIndex.toString());
            initAnimatedText(textIndex + 1);
          } else {
            controller.stop();
            setState(() {
              isEnabled = true;
            });
          }
        }
      });

      setState(() {
        animList[textIndex] = new AnimatedBuilder(animation: typeWriter, builder: buildAnimation);
      });

      controller.reset();

      new Future.delayed(const Duration(seconds: 1), () {
        try{
          controller.forward();
        }catch(err){
          //print(err);
        }
      });

    }
  }

  SizedBox getStaticText(int textIndex) {
    if ((mainIndex > -1)&&(mainIndex < mainTextList.length)) {
      var colorText = mainTextList[mainIndex][textIndex]['color'];
      var fontStyleText = FontStyle.normal;
      if ((colorText == 16711910) || (colorText == 11681540)) {
        fontStyleText = FontStyle.italic;
      }
      var textAlign = TextAlign.start;
      if (mainTextList[mainIndex][textIndex]['text'].startsWith("\n\n\n\n***")) {
        textAlign = TextAlign.center;
      }
      return new SizedBox(
        width: double.infinity,
        child: new Container(
          child: new Text(
            mainTextList[mainIndex][textIndex]['text'],
            style: new TextStyle(
              color: Color(colorText).withOpacity(1.0),
              fontSize: mainFontSize,
              fontStyle: fontStyleText,
            ),
            textAlign: textAlign,
          ),
          padding: const EdgeInsets.all(15.0),
        ),
      );
    } else {
      return new SizedBox();
    }
  }

  void screenTap() {
    /*setState(() {
      isEnabled = true;
    });
    setScene(lbTextTarget[mainIndex]);*/
  }

  void profileTap(context, index) {
    cPlay.playClick();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileDetails(
            characterProfile[index],
            textProfile[index],
            colorProfile[index],
            avatarProfile[index],
            leftBioProfile[index],
            rightBioProfile[index],
            S.of(context).profile_close),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    width = mediaQueryData.size.width;
    height = mediaQueryData.size.height;
    if (Platform.isIOS) {height = height * 0.92;}
    mainFontSize = (height + width) / 55;
    buttonFontSize = (height + width) / 80;
    if (mainIndex > -1){avInt = avatar[mainIndex];}
    loadImages();

    for (int avIndex = 0; avIndex < avInt.length; avIndex++) {
      if (avInt[avIndex].contains('profile_cure')) {
        visibilityCure = true;
        cureImg = avInt[avIndex];
        textCure = new Text(
          "C.U.R.E.",
          textAlign: TextAlign.center,
          style: new TextStyle(
              color: Color(colorCure).withOpacity(1.0), fontSize: mainFontSize),
        );
      } else if (avInt[avIndex].contains('profile_mueller')) {
        visibilityMuller = true;
        mullerImg = avInt[avIndex];
        textMuller = new Text(
          "Dr. Muller",
          textAlign: TextAlign.center,
          style: new TextStyle(
              color: Color(colorMuller).withOpacity(1.0),
              fontSize: mainFontSize),
        );
      } else if (avInt[avIndex].contains('profile_orlow')) {
        visibilityOrlow = true;
        orlowImg = avInt[avIndex];
        textOrlow = new Text(
          "Prof. Orlow",
          textAlign: TextAlign.center,
          style: new TextStyle(
              color: Color(colorOrlaw).withOpacity(1.0),
              fontSize: mainFontSize),
        );
      }
    }

    imageRow = new Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        visibilityCure
            ? new Container(
                margin: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 10.0),
                child: new InkWell(
                  child: cureImage,
                  onTap: () {profileTap(context, 0);},
                ),
              )
            : new Container(),
        visibilityMuller
            ? new Container(
                margin: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 10.0),
                child: new InkWell(
                  child: mullerImage,
                  onTap: () {profileTap(context, 1);},
                ),
              )
            : new Container(),
        visibilityOrlow
            ? new Container(
                margin: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 10.0),
                child: new InkWell(child: orlowImage,
                  onTap: () {profileTap(context, 2);},
                ),
              )
            : new Container(),
      ],
    );

    charRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        visibilityCure
            ? new Container(
                child: textCure,
                margin: EdgeInsets.fromLTRB(15.0,5.0,15.0,5.0),
              )
            : new Container(),
        visibilityMuller
            ? new Container(
                child: textMuller,
                margin: EdgeInsets.fromLTRB(15.0,5.0,15.0,5.0),
              )
            : new Container(),
        visibilityOrlow
            ? new Container(
                child: textOrlow,
                margin: EdgeInsets.fromLTRB(15.0,5.0,15.0,5.0),
              )
            : new Container(),
      ],
    );

    if (rbText[mainIndex] == "") {
      leftButtonWidthMultiplier = 1;
      rightButtonWidthMultiplier = 0.00;
    } else {
      leftButtonWidthMultiplier = 0.49;
      rightButtonWidthMultiplier = 0.49;
    }

    leftText = new Text(
      lbText[mainIndex],
      style: new TextStyle(
          fontSize: buttonFontSize,
          color: isEnabled
              ? Color(lbTextColor[mainIndex]).withOpacity(1.0)
              : Colors.transparent),
      textAlign: TextAlign.center,
      softWrap: true,
      maxLines: 10,
    );

    rightText = new Text(
      rbText[mainIndex],
      style: new TextStyle(
          fontSize: buttonFontSize,
          color: isEnabled
              ? Color(rbTextColor[mainIndex]).withOpacity(1.0)
              : Colors.transparent),
      textAlign: TextAlign.center,
      softWrap: true,
      maxLines: 10,
    );

    leftButton = new MaterialButton(
      key: null,
      onPressed: () {
        if (isEnabled) {
          setScene(lbTextTarget[mainIndex]);
        }
      },
      color: Color.fromRGBO(0, 0, 0, 0.9),
      child: new SizedBox(
        child: new Container(
          margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: new Center(
            child: leftText,
          ),
        ),
      ),
    );

    rightButton = new MaterialButton(
      key: null,
      onPressed: () {
        if (isEnabled) {
          setScene(rbTextTarget[mainIndex]);
        }
      },
      color: Color.fromRGBO(0, 0, 0, 0.9),
      child: new SizedBox(
        child: new Container(
          margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: new Center(
            child: rightText,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Text(
                          "",//"Chapter: ${chapterIndex.toString()}\nScene: ${mainIndex.toString()}",
                          style: TextStyle(color: Colors.white),
                        ),
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
                  color: Color.fromRGBO(0, 0, 0, 0.90),
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
                  color: Color.fromRGBO(0, 0, 0, 0.90),
                  child: new InkWell(
                    child:
                    MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: ListView(
                          children: <Widget>[animList[0], animList[1], animList[2]],
                      ),
                    ),
                    onTap: () {
                      screenTap();
                    },
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
                      width: width * leftButtonWidthMultiplier,
                      height: height * 0.25,
                      child: leftButton,
                    ),
                    new SizedBox(
                      width: width * rightButtonWidthMultiplier,
                      height: height * 0.25,
                      child: rightButton,
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
