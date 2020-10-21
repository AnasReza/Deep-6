import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:deep6/audio_player/background_player.dart';
import 'package:deep6/audio_player/click_player.dart';
import 'package:deep6/game/chapter_starting.dart';
import 'package:deep6/game/intermission.dart';
import 'package:deep6/game/prologue.dart';
import 'package:deep6/game/scene.dart';
import 'package:deep6/generated/i18n.dart';
import 'package:deep6/utility/notification.dart' as noti;
import 'package:deep6/utility/notifications.dart';
import 'package:deep6/utility/preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiver/async.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:screen/screen.dart';
import 'package:deep6/game/profile.dart';
import 'package:deep6/game/scanner.dart';
import 'package:deep6/game/rateus.dart';

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      localeResolutionCallback: S.delegate.resolution(fallback: new Locale("en", "")),
      title: 'Deep 6',
      home: MenuScreen(),
    );
  }
}

class MenuScreen extends StatefulWidget {
  @override
  MenuState createState() => new MenuState();
}

class MenuState extends State<MenuScreen> with WidgetsBindingObserver {
  CountdownTimer cdt;
  ClickPlayer cPlay;
  Notifications notify;

  String middleText = "";
  int oldTime = 0, newTime, difference = 0;
  final Player player = new Player();

  List<List<String>> characterList = new List<List<String>>();
  List<List<String>> text = new List<List<String>>();
  List<dynamic> mainTextColor = new List<dynamic>();
  List<List<dynamic>> mainTextList = new List<List<dynamic>>();
  List<List<String>> avatarList = new List<List<String>>();

  List<String> lbTextList = new List<String>();
  List<dynamic> lbTextTarget = new List<dynamic>();
  List<dynamic> lbTextColor = new List<dynamic>();

  List<String> rbText = new List<String>();
  List<dynamic> rbTextTarget = new List<dynamic>();
  List<dynamic> rbTextColor = new List<dynamic>();

  bool continueEnabled = false;
  bool continuePrologueEnabled = false;
  bool continueProfileEnabled = false;
  bool continueScannerEnabled = false;
  bool backgroundMusic = true;

  Color continueTextColor = Colors.white;

  String lang = "de";

  @override
  void initState() {
    super.initState();
    cPlay = new ClickPlayer();
    player.playAudio();
    WidgetsBinding.instance.addObserver(this);
    Screen.keepOn(true);
  }

  Future continueGame(int chapter, int sceneIndex) async {
    mainTextList.clear();
    characterList.clear();
    text.clear();
    mainTextColor.clear();
    avatarList.clear();
    lbTextList.clear();
    lbTextTarget.clear();
    lbTextColor.clear();
    rbText.clear();
    rbTextTarget.clear();
    rbTextColor.clear();
    try {
      var urlString = "assets/json/$lang/chapter_${chapter.toString()}.json";
      var data = await rootBundle.loadString(urlString);
      var decodedData = json.decode(data);
      List<dynamic> sceneArray = decodedData['story'];

      for (int i = 0; i < sceneArray.length; i++) {
        List<dynamic> charArray = sceneArray[i]['character'];
        List<String> charStr = new List<String>();
        List<String> avStr = new List<String>();
        for (int c = 0; c < charArray.length; c++) {
          charStr.add(charArray[c]['char']);
          if (charArray[c]['char'] == "C.U.R.E.") {
            avStr.add('assets/images/profile_cure.png');
          } else if (charArray[c]['char'] == "Dr. Muller") {
            avStr.add('assets/images/profile_mueller.png');
          } else {
            avStr.add('assets/images/profile_orlow.png');
          }
        }
        characterList.add(charStr);
        avatarList.add(avStr);

        List<dynamic> textArray = sceneArray[i]['maintext'];
        mainTextList.add(textArray);
        List<String> textStr = new List<String>();
        List<int> colorInt = new List<int>();
        for (int m = 0; m < textArray.length; m++) {
          textStr.add(textArray[m]['text']);
          colorInt.add(textArray[m]['color']);
        }
        text.add(textStr);
        mainTextColor.add(colorInt);

        //Collecting Data for left button
        List<dynamic> lbArray = sceneArray[i]['leftButton'];
        for (int l = 0; l < lbArray.length; l++) {
          lbTextList.add(lbArray[l]['lbText']);
          lbTextTarget.add(lbArray[l]['targetId']);
          lbTextColor.add(lbArray[l]['color']);
        }

        //Collecting Data for Right Button
        List<dynamic> rbArray = sceneArray[i]['rightButton'];
        for (int r = 0; r < rbArray.length; r++) {
          rbText.add(rbArray[r]['rbText']);
          rbTextTarget.add(rbArray[r]['targetId']);
          rbTextColor.add(rbArray[r]['color']);
        }
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scene(
            lang: lang,
            chapterIndex: chapter,
            mainIndex: sceneIndex,
            mainTextList: mainTextList,
            character: characterList,
            text: text,
            mainTextColor: mainTextColor,
            avatar: avatarList,
            lbText: lbTextList,
            lbTextTarget: lbTextTarget,
            lbTextColor: lbTextColor,
            rbText: rbText,
            rbTextTarget: rbTextTarget,
            rbTextColor: rbTextColor,
          ),
        ),
      );

    } on FormatException catch (e) {
      //print("${e.toString()} error");
    }
  }

  onContinuePressed() async {
    bool continuation = false;
    bool prologueContinuation = false;
    bool profilesContinuation = false;
    bool scannerContinuation = false;
    int timeLimit = 0;

    await SharedPreferences.getInstance().then((p) {
      oldTime = p.getInt(PrefsKeys.str_timestamp) ?? 0;
      newTime = DateTime.now().millisecondsSinceEpoch;
      int chapterInt = p.getInt(PrefsKeys.chapter_index);
      timeLimit = p.getInt(PrefsKeys.waiting_time);
      int difference = newTime - oldTime;
      int mainIndex = p.getInt(PrefsKeys.current_index);
      continuation = p.getBool(PrefsKeys.bool_continuation);
      prologueContinuation = p.getBool(PrefsKeys.bool_prologue_continuation);
      profilesContinuation = p.getBool(PrefsKeys.bool_profiles_continuation);
      scannerContinuation = p.getBool(PrefsKeys.bool_scanner_continuation);
      if (continuation == null){continuation = false;}
      if (prologueContinuation == null){prologueContinuation = false;}
      if (profilesContinuation == null){profilesContinuation = false;}
      if (scannerContinuation == null){scannerContinuation = false;}
      if (prologueContinuation) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewGame(lang),
          ),
        );
      } else if (profilesContinuation) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileFull(lang),
            ),
          );
      } else if (scannerContinuation) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scanner(lang),
          ),
        );
      } else if (continuation) {
          if (mainIndex != -1) {
            continueGame(chapterInt, mainIndex);
          } else {
            if (difference < timeLimit) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Intermission(chapterInt, lang),
                ),
              );
            } else {
              int chapter = p.getInt(PrefsKeys.chapter_index);
                String middleText = S
                    .of(context)
                    .chapter_1;
                switch (chapter) {
                  case 2:
                    middleText = S
                        .of(context)
                        .chapter_2;
                    break;
                  case 3:
                    middleText = S
                        .of(context)
                        .chapter_3;
                    break;
                  case 4:
                    middleText = S
                        .of(context)
                        .chapter_4;
                    break;
                  case 5:
                    middleText = S
                        .of(context)
                        .chapter_5;
                    break;
                  case 6:
                    middleText = S
                        .of(context)
                        .chapter_6;
                    break;
                  case 7:
                    middleText = S
                        .of(context)
                        .chapter_7;
                    break;
                  case 8:
                    middleText = S
                        .of(context)
                        .chapter_8;
                    break;
                  case 9:
                    middleText = S
                        .of(context)
                        .chapter_9;
                    break;
                  case 10:
                    middleText = S
                        .of(context)
                        .chapter_10;
                    break;
                  case 11:
                    middleText = S
                        .of(context)
                        .chapter_11;
                    break;
                  case 12:
                    middleText = S
                        .of(context)
                        .chapter_12;
                    break;
                  case 13:
                    middleText = S
                        .of(context)
                        .chapter_13;
                    break;
                  case 14:
                    middleText = S
                        .of(context)
                        .chapter_14;
                    break;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChapterStartingFull(
                          chapterHeading: middleText,
                          language: lang,
                          newGame: false,
                        ),
                  ),
                );
              }
            }
          }
        //}
    });
    // sleep(new Duration(seconds: 1));
  }

  void checkContinueEnabled() async {
    SharedPreferences.getInstance().then((p) {
      continueEnabled = p.getBool(PrefsKeys.bool_continuation);
      continuePrologueEnabled = p.getBool(PrefsKeys.bool_prologue_continuation);
      continueProfileEnabled = p.getBool(PrefsKeys.bool_profiles_continuation);
      continueScannerEnabled = p.getBool(PrefsKeys.bool_scanner_continuation);
      if ((continueEnabled != null && continueEnabled) ||
          (continuePrologueEnabled != null && continuePrologueEnabled) ||
          (continueProfileEnabled != null && continueProfileEnabled) ||
          (continueScannerEnabled != null && continueScannerEnabled) ) {
        setState(() {
          continueTextColor = Colors.white;
        });
      } else {
        setState(() {
          continueTextColor = Colors.grey.withOpacity(0.5);
        });
      }
    });
  }

  void onNewGamePressed(BuildContext context, String msg, String yesStr, String noStr, String title) async {
    bool continuation = false;
    bool prologueContinuation = false;
    await SharedPreferences.getInstance().then((p) {
      continuation = p.getBool(PrefsKeys.bool_continuation);
      prologueContinuation = p.getBool(PrefsKeys.bool_prologue_continuation);
      if (continuation == null){continuation = false;}
      if (prologueContinuation == null){prologueContinuation = false;}
      if (!continuation && !prologueContinuation) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewGame(lang),
          ),
        );
      } else {
        newGameDialog(msg, yesStr, noStr, title);
      }
    });
  }

  AlertDialog dialog;

  Future<bool> newGameDialog(
      String msg, String yesStr, String noStr, String title) async {
    return showDialog(
        context: context,
        builder: (BuildContext ctx) {
          dialog = new AlertDialog(
            title: new Text(
              title,
              style: TextStyle(color: Colors.black),
            ),
            content: new Text(
              msg,
              style: TextStyle(color: Colors.black),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text(
                  yesStr,
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  startNewGame();
                },
              ),
              new FlatButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: new Text(
                  noStr,
                  style: TextStyle(color: Colors.blue),
                ),
              )
            ],
          );

          return dialog;
        });
  }

  void startNewGame() async {
    await SharedPreferences.getInstance().then((p) {
      p.setBool(PrefsKeys.bool_continuation, false);
      p.setBool(PrefsKeys.bool_prologue_continuation, false);
      p.setBool(PrefsKeys.bool_profiles_continuation, false);
      p.setBool(PrefsKeys.bool_scanner_continuation, false);
      p.setInt(PrefsKeys.chapter_index, 0);
      p.setInt(PrefsKeys.current_index, 0);
      p.setInt(PrefsKeys.prologue_index, 0);

      noti.Notification notify = new noti.Notification();
      notify.notificationCancel();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewGame(lang),
        ),
      );
    });
  }

  AlertDialog indicatorDialog;

  void toggleMusic(bool value) {
    if (value){
      player.resumeAudio();
    } else {
      player.pauseAudio();
    }
    setState(() {
      backgroundMusic = value;
    });
  }

  Future<bool> loadingDialog() async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx) {
          indicatorDialog = new AlertDialog(
            content: new Container(
              height: 50.0,
              width: 50.0,
              color: Colors.transparent,
              alignment: Alignment(0.0, 0.0),
              child:  SizedBox(
                  width: 50.0,
                  height: 50.0,
                  child: new CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation(Colors.blueGrey),
                      strokeWidth: 5.0
                  ),
                )
            )
          );
          return indicatorDialog;
        });
  }

  void onRateButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Rateus(0,lang),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if ((state == AppLifecycleState.paused) || (state == AppLifecycleState.suspending) || (state == AppLifecycleState.inactive)) {
      player.pauseAudio();
    } else if (state == AppLifecycleState.resumed && backgroundMusic) {
      player.resumeAudio();
    }
  }

  @override
  Widget build(BuildContext context) {
    lang = S.of(context).lang;
    checkContinueEnabled();
    return new WillPopScope(
        child: new Scaffold(
          backgroundColor: Colors.black,
          body: new Container(
              decoration: new BoxDecoration(
                  color: Colors.black,
                  image: DecorationImage(
                      image: new AssetImage('assets/images/bg_main.png'),
                      fit: BoxFit.cover)),
              child: new Column(
                children: <Widget>[
                  new SafeArea(
                    top: true,
                    bottom: false,
                    child: new SizedBox(
                      child: new Container(
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            new IconButton(
                                color: Colors.white,
                                icon: backgroundMusic ? Icon(Icons.volume_up) : Icon(Icons.volume_off),
                                onPressed: () {
                                  toggleMusic(!backgroundMusic);
                                }),
                          ],
                        ),
                      ),
                      width: double.infinity,
                    ),
                  ),


                  new Expanded (
                  child:  new Column (
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new SizedBox(
                          width: double.infinity,
                          child: new RaisedButton(
                            onPressed: () {
                              onContinuePressed();
                            },
                            color: const Color(0x80000000),
                            child: new Text(
                                S.of(context).continueStr,
                                style:
                                    TextStyle(color: continueTextColor, fontSize: 20.0)),
                          ),
                        ),
                        new SizedBox(
                          width: double.infinity,
                          child: new RaisedButton(
                            onPressed: () {
                              onNewGamePressed(
                                  context,
                                  S.of(context).dialog_msg,
                                  S.of(context).yesStr,
                                  S.of(context).noStr,
                                  S.of(context).new_game);
                            },
                            color: const Color(0x80000000),
                            child: new Text(
                                S.of(context).new_game,
                                style:
                                    TextStyle(color: Colors.white, fontSize: 20.0)),
                          ),
                        ),
                        new SizedBox(
                          width: double.infinity,
                          child: new RaisedButton(
                            onPressed: () {
                              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                              if (Platform.isIOS){exit(0);}
                            },
                            color: const Color(0x80000000),
                            child: new Text(
                                S.of(context).exit,
                                style: TextStyle(color: Colors.white, fontSize: 20.0)),
                          ),
                        ),
                      ],
                    ),
                  ),


                  new SafeArea(
                    top: false,
                    bottom: true,
                    child: new Container(
                      alignment: Alignment.centerRight,
                      child: new FractionallySizedBox(
                        alignment: Alignment.center,
                        child: new InkWell(
                          onTap: () {
                            onRateButtonPressed();
                          },
                          child: new Padding(
                            padding: EdgeInsets.all(10.0),
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                new Text(
                                    S.of(context).rate_us + "  ",
                                    style:
                                    TextStyle(color: Colors.white, fontSize: 18.0)),
                                new Icon(Icons.thumb_up,color: Colors.white,size: 20)
                              ],
                            ),
                          ),
                        ),
                        widthFactor: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ),
        onWillPop: () {
          player.stopAudio();
          //exit(0);
        });
  }
}
