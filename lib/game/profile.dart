import 'dart:convert';
import 'dart:io';

import 'package:deep6/game/profile_details.dart';
import 'package:deep6/game/scanner.dart';
import 'package:deep6/generated/i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:deep6/audio_player/click_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deep6/utility/preference.dart';


class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        S.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      localeResolutionCallback: S.delegate.resolution(fallback: new Locale("en", "")),
      home: ProfileFull("en"),
    );
  }
}

class ProfileFull extends StatefulWidget {
  String language = "de";

  ProfileFull(String language){
    this.language = language;
  }

  @override
  ProfileState createState() => new ProfileState();
}

class ProfileState extends State<ProfileFull> {
  int oldTime = 0;
  List<String> character = new List<String>();
  List<String> leftBio = new List<String>();
  List<String> rightBio = new List<String>();
  List<String> text = new List<String>();
  List<String> avatar = new List<String>();
  List<int> color = new List<int>();
  double width, height;
  ClickPlayer cPlay;
  double mainFontSize = 20.0;
  double buttonFontSize = 20.0;
  String lang = "de";

  @override
  void initState() {
    super.initState();
    cPlay = new ClickPlayer();
    lang = widget.language;
    readJson();
  }

  Future readJson() async {

    await SharedPreferences.getInstance().then((p) {
      p.setBool(PrefsKeys.bool_profiles_continuation, true);
    });

    try {
      var data =
      await rootBundle.loadString('assets/json/$lang/profile_details.json');
      var decodedData = json.decode(data);
      //middleText = decodedData['chapters'][0]['text'];
      List<dynamic> sceneArray = decodedData['profile'];
      for (int i = 0; i < sceneArray.length; i++) {
        character.add(sceneArray[i]['character']);
        leftBio.add(sceneArray[i]['leftBio']);
        rightBio.add(sceneArray[i]['rightBio']);
        text.add(sceneArray[i]['text']);
        color.add(sceneArray[i]['color']);
        if (sceneArray[i]['character'] == "C.U.R.E.") {
          avatar.add('assets/images/profile_cure.png');
        } else if (sceneArray[i]['character'] == "Dr. Robin Muller") {
          avatar.add('assets/images/profile_mueller.png');
        } else {
          avatar.add('assets/images/profile_orlow.png');
        }
      }
      //print(sceneArray.toString());
      //print("readJson");
    } on FormatException catch (e) {
      //print("${e.toString()} error");
    }
  }

  onNextButtonPressed() async {
    await SharedPreferences.getInstance().then((p) {
      p.setBool(PrefsKeys.bool_profiles_continuation, false);
      p.setBool(PrefsKeys.bool_scanner_continuation, true);
    });
    cPlay.playClick();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Scanner(lang),
      ),
    );
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
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
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
      ),
      body: new Column(
        children: <Widget>[
          new Container(
            padding: EdgeInsets.fromLTRB(5.0,5.0,5.0,5.0),
            color: Color.fromRGBO(0, 0, 0, 0.8),
            margin: const EdgeInsets.only(bottom: 10.0),
            height: height * 0.08,
            alignment: Alignment(0.0, 0.0),
            child: new SizedBox(
              width: double.infinity,
              child: Text(
                S.of(context).profile_heading,
                style: TextStyle(color: Colors.white, fontSize: buttonFontSize),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          new SizedBox(
            height: height * 0.70,
            child: new Column(
              children: <Widget>[
                new Column(
                  children: <Widget>[
                    new InkWell(
                      child: new Column(
                        children: <Widget>[
                          new SizedBox(
                            width: double.infinity,
                            child: new Container(
                              color: Color.fromRGBO(0, 0, 0, 0.3),
                              child: new Container(
                                width: double.infinity,
                                height: height * 0.125,
                                margin: const EdgeInsets.all(10.0),
                                child: Image.asset(
                                  'assets/images/profile_cure.png',
                                ),
                              ),
                            ),
                          ),
                          new SizedBox(
                            width: double.infinity,
                            child: new Container(
                              padding: EdgeInsets.all(5.0),
                              margin: EdgeInsets.only(bottom: 10.0),
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              child: Text(
                                "C.U.R.E",
                                style: TextStyle(
                                    color: Color.fromRGBO(104, 173, 212, 1.0),
                                    fontSize: mainFontSize),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        cPlay.playClick();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileDetails(
                                character[0],
                                text[0],
                                color[0],
                                avatar[0],
                                leftBio[0],
                                rightBio[0],
                                S.of(context).profile_close
                            ),
                          ),
                        );
                      },
                    ),
                    new InkWell(
                      child: new Column(
                        children: <Widget>[
                          new SizedBox(
                            width: double.infinity,
                            child: new Container(
                              color: Color.fromRGBO(0, 0, 0, 0.3),
                              child: new Container(
                                width: double.infinity,
                                height: height * 0.125,
                                margin: const EdgeInsets.all(10.0),
                                child: Image.asset(
                                  'assets/images/profile_mueller.png',
                                ),
                              ),
                            ),
                          ),
                          new SizedBox(
                            width: double.infinity,
                            child: new Container(
                              padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              margin: EdgeInsets.only(bottom: 10.0),
                              child: Text(
                                "Dr. Robin Muller",
                                style: TextStyle(
                                    color: Color.fromRGBO(255, 0, 230, 1.0),
                                    fontSize: mainFontSize),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        cPlay.playClick();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileDetails(
                                character[1],
                                text[1],
                                color[1],
                                avatar[1],
                                leftBio[1],
                                rightBio[1],
                                S.of(context).profile_close),
                          ),
                        );
                      },
                    ),
                    new InkWell(
                      child: new Column(
                        children: <Widget>[
                          new SizedBox(
                            width: double.infinity,
                            child: new Container(
                              color: Color.fromRGBO(0, 0, 0, 0.3),
                              child: new Container(
                                width: double.infinity,
                                height: height * 0.125,
                                margin: const EdgeInsets.all(10.0),
                                child: Image.asset(
                                  'assets/images/profile_orlow.png',
                                ),
                              ),
                            ),
                          ),
                          new SizedBox(
                            width: double.infinity,
                            child: new Container(
                              padding: EdgeInsets.all(5.0),
                              margin: EdgeInsets.only(bottom: 5.0),
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              child: Text(
                                "Prof. Jurij Orlow",
                                style: TextStyle(
                                    color: Color.fromRGBO(178, 63, 9, 1.0),
                                    fontSize: mainFontSize),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        //print("Orlaw is pressed");
                        cPlay.playClick();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileDetails(
                                character[2],
                                text[2],
                                color[2],
                                avatar[2],
                                leftBio[2],
                                rightBio[2],
                                S.of(context).profile_close
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
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
                    onPressed: () {
                      onNextButtonPressed();
                    },
                    child: new Text(
                      S.of(context).profile_next,
                      style: TextStyle(color: Colors.white, fontSize: buttonFontSize),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
