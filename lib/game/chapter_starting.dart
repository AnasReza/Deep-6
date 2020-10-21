import 'dart:convert';

import 'package:deep6/game/scene.dart';

import 'package:deep6/utility/countDown.dart';
import 'package:deep6/utility/preference.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChapterStarting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChapterStartingFull(),
    );
  }
}

class ChapterStartingFull extends StatefulWidget {
  String chapterHeading;
  String language = "de";

  bool newGame;

  ChapterStartingFull({Key key, this.chapterHeading, this.newGame, this.language}) : super(key: key);

  @override
  ChapterStartingState createState() => new ChapterStartingState();
}

class ChapterStartingState extends State<ChapterStartingFull> {
  double width, height;
  List<String> content = new List<String>();
  CountDown customTimer;
  String middleText = "";
  String lang = "de";

  bool newGameStart;

  Text middleTextWidget;

  int chapter;

  List<List<String>> character = new List<List<String>>();
  List<List<String>> text = new List<List<String>>();
  List<List<dynamic>> mainTextList = new List<List<dynamic>>();
  List<List<int>> mainTextColor = new List<List<int>>();
  List<List<String>> avatar = new List<List<String>>();

  List<String> lbText = new List<String>();
  List<int> lbTextTarget = new List<int>();
  List<int> lbTextColor = new List<int>();

  List<String> rbText = new List<String>();
  List<int> rbTextTarget = new List<int>();
  List<int> rbTextColor = new List<int>();

  String bg_image = "assets/images/bg_ch_1_4.png";

  int startingChapter = 1;

  bool loaded = false;

  @override
  void initState() {
    super.initState();
    loaded = false;
    middleText = widget.chapterHeading;
    newGameStart = widget.newGame;
    lang = widget.language;
  }

  Future readJson(bool newGame) async {
      await SharedPreferences.getInstance().then((p) async {
        if (newGame) {
          p.setInt(PrefsKeys.chapter_index, startingChapter);
          chapter = startingChapter;
        } else {
          chapter = p.getInt(PrefsKeys.chapter_index);
        }
        String bg_image_uri = "assets/images/bg_ch_1_4.png";
        if (chapter <= 4){
          bg_image_uri = "assets/images/bg_ch_1_4.png";
        } else if (chapter <= 7) {
          bg_image_uri = "assets/images/bg_ch_5_7.png";
        } else if (chapter <= 9) {
          bg_image_uri = "assets/images/bg_ch_8_9.png";
        } else if (chapter <= 11) {
          bg_image_uri = "assets/images/bg_ch_10_11.png";
        } else if (chapter <= 13) {
          bg_image_uri = "assets/images/bg_ch_12_13.png";
        } else if (chapter == 14) {
          bg_image_uri = "assets/images/bg_ch_14.png";
        }

        setState(() {
          bg_image = bg_image_uri;
        });

        try {

          var urlString = "assets/json/$lang/chapter_${chapter.toString()}.json";

          var data = await rootBundle.loadString(urlString);
          var decodedData = json.decode(data);

          List<dynamic> sceneArray = decodedData['story'];
          for (int i = 0; i < sceneArray.length; i++) {
            //Collecting Data for image , its text and text color
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
            character.add(charStr);
            avatar.add(avStr);

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
              lbText.add(lbArray[l]['lbText']);
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
        } on FormatException catch (e) {
          //print("${e.toString()} error");
        }

        loaded = true;
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    //print("build is Running");
    final mediaQueryData = MediaQuery.of(context);
    width = mediaQueryData.size.width;
    height = mediaQueryData.size.height;

    readJson(newGameStart);

    void enterChapter(){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Scene(
            lang: lang,
            chapterIndex: chapter,
            mainIndex: 0,
            character: character,
            mainTextList: mainTextList,
            text: text,
            mainTextColor: mainTextColor,
            avatar: avatar,
            lbText: lbText,
            lbTextTarget: lbTextTarget,
            lbTextColor: lbTextColor,
            rbText: rbText,
            rbTextTarget: rbTextTarget,
            rbTextColor: rbTextColor,
          ),
        ),
      );
    }

    return new Scaffold(
      backgroundColor: new Color.fromRGBO(0, 0, 0, 1.0),
      body: new Container(
        height: double.infinity,
        width: double.infinity,
        decoration: new BoxDecoration(
            image: DecorationImage(
                image: new AssetImage(bg_image),
                fit: BoxFit.cover)),
        child: new InkWell(
          child: new Center(
            child: new SizedBox(
              width: double.infinity,
              height: height,//height * 0.4,
              child: new Container(
                child: new Center(
                  child: new Text(
                    middleText,
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                    textAlign: TextAlign.center,
                  ),
                ),
                color: new Color.fromRGBO(0, 0, 0, 0.0),
              ),
            ),
          ),
          onTap: () {
            if (loaded) {
              enterChapter();
            }
          },
        ),
      ),
    );
  }
}
