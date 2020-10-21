import 'package:deep6/menu.dart';
import 'package:flutter/material.dart';
import 'package:quiver/async.dart';

class CountDown {
  static CountdownTimer cdt;
  bool timerWorking = false;
  static Stopwatch stopwatch;

  void startCounting(BuildContext context) {
    stopwatch = new Stopwatch();

    cdt = new CountdownTimer(
        Duration(milliseconds: 20000), Duration(milliseconds: 500),
        stopwatch: stopwatch);

    cdt.listen((cdt) {
      stopwatch.start();
      //print("${stopwatch.isRunning} is Running");
    }, onDone: () {
      //print("COUNTING OF THE NEW CHAPTER IS DONE");
     // Navigator.pushReplacement(context,
        //MaterialPageRoute(builder: (context) => MenuScreen(),),);
      cdt.cancel();
    });
  }

  bool timerIsRunning() {
    try {
      return cdt.isRunning;
    } catch (e) {
      return false;
    }
  }
}
