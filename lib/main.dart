import 'dart:developer';

import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Machine',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class TimeStrings {
  String day = "";
  String month = "";
  String year = "";
  String hour = "";
  String minute = "";

  void update(DateTime date) {
    day = DateFormat('dd').format(date);
    month = DateFormat('MM').format(date);
    year = DateFormat('yyyy').format(date);
    hour = DateFormat('HH').format(date);
    minute = DateFormat('mm').format(date);
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  DateTime date = DateTime.now();
  DateTime targetDate = DateTime.now();
  TimeStrings dateString = TimeStrings();
  TimeStrings targetString = TimeStrings();
  bool inProgress = false;
  Duration increment = const Duration(days: 5);
  String travelText = "";
  Color defaultGreen = const Color(0xFF20c20e);

  TextStyle subTStyle = const TextStyle();
  TextStyle tStyle = const TextStyle();

  TextStyle subCStyle = const TextStyle();
  TextStyle cStyle = const TextStyle();

  late AudioPlayer player;

  ButtonStyle bStyle = const ButtonStyle();

  BoxDecoration decFin = const BoxDecoration(
      color: Colors.black
  );

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);


    String cacheDate = "";
    SharedPreferences.getInstance().then((SharedPreferences prefVal) => {
      cacheDate = prefVal.getString("current") ?? "",
      setState((){
        date = DateTime.parse(cacheDate);
        dateString.update(date);
        targetDate = DateTime.parse(cacheDate);
        targetString.update(targetDate);
      })
    });


    dateString.update(date);
    targetString.update(targetDate);
    player = AudioPlayer();

    subTStyle =  TextStyle(
      fontSize: 80,
      color: defaultGreen,
    );

    subCStyle = TextStyle(
      fontSize: 100,
      color: defaultGreen,
    );

    tStyle = GoogleFonts.vt323(
      textStyle: subTStyle,
    );

    cStyle = GoogleFonts.vt323(
      textStyle: subCStyle,
    );

    bStyle = ButtonStyle(
      foregroundColor: MaterialStateProperty.all<Color>(defaultGreen),
      backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
    );
  }

  void _startCountdown() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString("current", DateFormat('yyyy-dd-MM HH:mm:00').format(targetDate));

    await player.setAsset('assets/TimeMachine.mp3');
    await player.setLoopMode(LoopMode.one);
    inProgress = !inProgress;
    setState(() {
      inProgress;
    });

    if(inProgress){
      travelText = "Traveling...";
      player.play();
    }

    String mode = "";
    mode = targetDate.compareTo(date) < 0 ? "-" : "+";
    if (mode == "-") {
      while (targetDate.compareTo(date) < 0) {
        _countDown(mode);
        await Future.delayed(const Duration(milliseconds: 2));
      }
    } else {
      while (targetDate.compareTo(date) > 0) {
        _countDown(mode);
        await Future.delayed(const Duration(milliseconds: 2));
      }
    }
    player.stop();
    date = targetDate;
    dateString.update(date);
    travelText = "Welcome to:";
    if(inProgress){
      for(int i = 0; i < 10; i++){
        if(i%2 == 0){
          decFin = BoxDecoration(
              color: defaultGreen
          );
        }else{
          decFin = const BoxDecoration(
              color: Colors.black
          );
        }
        setState(() {
          decFin;
        });
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  void _modDate(String mode, Duration dur) {
    if (dur == const Duration(days: 99)) {
      if (mode == '-') {
        targetDate = DateTime(targetDate.year, targetDate.month - 1,
            targetDate.day, targetDate.hour, targetDate.minute);
      } else {
        targetDate = DateTime(targetDate.year, targetDate.month + 1,
            targetDate.day, targetDate.hour, targetDate.minute);
      }
    } else if (dur == const Duration(days: 365)) {
      if (mode == '-') {
        targetDate = DateTime(targetDate.year - 1, targetDate.month,
            targetDate.day, targetDate.hour, targetDate.minute);
      } else {
        targetDate = DateTime(targetDate.year + 1, targetDate.month,
            targetDate.day, targetDate.hour, targetDate.minute);
      }
    } else {
      if (mode == '-') {
        targetDate = targetDate.subtract(dur);
      } else {
        targetDate = targetDate.add(dur);
      }
    }
    targetString.update(targetDate);
    setState(() {
      targetDate;
      targetString;
    });
  }

  void _countDown(String mode) {
    if (mode == "-") {
      date = date.subtract(increment);
    } else {
      date = date.add(increment);
    }
    dateString.update(date);
    //log('${dateString.day} ${dateString.month} ${dateString.year} ${dateString.hour} ${dateString.minute}');
    setState(() {
      date;
      dateString;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Container(
          decoration: decFin,
          child:  Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: !inProgress,
                    child: Wrap(
                      spacing: 20,
                      children: [
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: () => _modDate("+", const Duration(days: 1)),
                              child: const Icon(Icons.arrow_upward),
                              style: bStyle,
                            ),
                            Text(
                              targetString.day,
                              style: tStyle,
                            ),
                            ElevatedButton(
                              onPressed: () => _modDate("-", const Duration(days: 1)),
                              child: const Icon(Icons.arrow_downward),
                              style: bStyle,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: () => _modDate("+", const Duration(days: 99)),
                              child: const Icon(Icons.arrow_upward),
                              style: bStyle,
                            ),
                            Text(
                              targetString.month,
                              style: tStyle,
                            ),
                            ElevatedButton(
                              onPressed: () => _modDate("-", const Duration(days: 99)),
                              child: const Icon(Icons.arrow_downward),
                              style: bStyle,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: () => _modDate("+", const Duration(days: 365)),
                              child: const Icon(Icons.arrow_upward),
                              style: bStyle,
                            ),
                            Text(
                              targetString.year,
                              style: tStyle,
                            ),
                            ElevatedButton(
                              onPressed: () => _modDate("-", const Duration(days: 365)),
                              child: const Icon(Icons.arrow_downward),
                              style: bStyle,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: () => _modDate("+", const Duration(hours: 1)),
                              child: const Icon(Icons.arrow_upward),
                              style: bStyle,
                            ),
                            Text(
                              targetString.hour,
                              style: tStyle,
                            ),
                            ElevatedButton(
                              onPressed: () => _modDate("-", const Duration(hours: 1)),
                              child: const Icon(Icons.arrow_downward),
                              style: bStyle,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: () =>
                                  _modDate("+", const Duration(minutes: 1)),
                              child: const Icon(Icons.arrow_upward),
                              style: bStyle,
                            ),
                            Text(
                              targetString.minute,
                              style: tStyle,
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  _modDate("-", const Duration(minutes: 1)),
                              child: const Icon(Icons.arrow_downward),
                              style: bStyle,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Visibility(
                    visible: inProgress,
                    child: Column(
                      children:[
                        Visibility(
                            child:
                            Text(
                              travelText,
                              style: tStyle,
                            ),
                        ),
                        Wrap(
                          spacing: 20,
                          children: [
                            Column(
                              children: [
                                Text(
                                  dateString.day,
                                  style: cStyle,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  dateString.month,
                                  style: cStyle,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  dateString.year,
                                  style: cStyle,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  dateString.hour,
                                  style: cStyle,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  dateString.minute,
                                  style: cStyle,
                                ),
                              ],
                            )
                          ],
                        ),
                      ]
                    )
                  ),
                ],
              )),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _startCountdown,
        tooltip: 'Start',
        child: const Icon(Icons.play_arrow),
        backgroundColor: Colors.black,
        foregroundColor: defaultGreen,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
