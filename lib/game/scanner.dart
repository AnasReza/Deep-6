import 'package:deep6/game/chapter_starting.dart';
import 'package:deep6/generated/i18n.dart';
import 'package:deep6/utility/preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Scanner extends StatelessWidget {
  int oldTime = 0;
  String language = "de";

  Scanner(String language) {
    this.language = language;
  }

  timeCalculate(BuildContext context) async {
    await SharedPreferences.getInstance().then((p) {
      p.setBool(PrefsKeys.bool_scanner_continuation, false);
      p.setBool(PrefsKeys.bool_continuation, true);
      p.setInt(PrefsKeys.chapter_index, 1);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChapterStartingFull(
                chapterHeading: S.of(context).chapter_1,
                newGame: true,
                language: language,
              ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        S.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      localeResolutionCallback:
          S.delegate.resolution(fallback: new Locale("de", "")),
      home: new Container(
        decoration: new BoxDecoration(
            image: DecorationImage(
                image: new AssetImage('assets/images/bg_main.png'),
                fit: BoxFit.cover)),
        child: new Scaffold(
          backgroundColor: Colors.transparent,
          body: new Container(
            child: new Stack(
              children: <Widget>[
                new SizedBox(
                  width: double.infinity,
                  child: new Column(
                      children: <Widget>[
                        new Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(5.0, 40.0, 5.0, 20.0),
                          color: Color.fromRGBO(0, 0, 0, 0.5),
                          child: new Text(
                          S.of(context).scanner_heading,
                          style: new TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        ),
                      ],
                    ),
                  ),
                new Center(
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new InkWell(
                        borderRadius:
                            new BorderRadius.all(new Radius.circular(500.0)),
                        child: new Container(
                          width: 150.0,
                          height: 150.0,
                          padding: EdgeInsets.all(10.0),
                          decoration: new BoxDecoration(
                            borderRadius: new BorderRadius.all(new Radius.circular(500.0)),
                            border: new Border.all(
                              color: Colors.red.withOpacity(0.5),
                              width: 1.0,
                            ),
                          ),
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              new Image.asset(
                                "assets/images/fingerprint.png",
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ),
                        onLongPress: () {
                          timeCalculate(context);
                        },
                      ),
                    ],
                  ),
                ),
                new SizedBox(
                  width: double.infinity,
                  child: new Align(
                    alignment: FractionalOffset.bottomCenter,
                    child:
                    new SafeArea(
                      child: new SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: new Text(
                          S.of(context).scan_text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white, fontSize: 20.0),
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
