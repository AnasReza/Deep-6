import 'package:flutter/material.dart';
import 'package:flutter/services.dart';



class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color.fromRGBO(30, 30, 30, 1.0),
          appBar: new AppBar(
            elevation: 0.0,
            backgroundColor: Color.fromRGBO(30, 30, 30, 1.0),
            actions: <Widget>[
              new IconButton(
                  icon: Icon(Icons.settings_power),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ],
            title: new Text(
              "ABOUT US",
              style: new TextStyle(color: Colors.white),
            ),
            centerTitle: true,
          ),
          body: new Container(
            margin: const EdgeInsets.all(10.0),
            child: new Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
              style: TextStyle(color: Colors.white, fontSize: 15.0),
            ),
          ),
        ));
  }
}
