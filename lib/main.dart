import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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

class _MyHomePageState extends State<MyHomePage> {
  DateTime date = DateTime.now();
  DateTime targetDate = DateTime.now();
  bool inProgress = false;
  Duration increment = const Duration(hours: 3);
  TextStyle tStyle = const TextStyle(
    fontSize: 60,
    fontWeight: FontWeight.bold,
  );

  TextStyle cStyle = const TextStyle(
    fontSize: 80,
    fontWeight: FontWeight.bold,
  );

  @override
  void initState(){
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  void _startCountdown() async{
    inProgress = !inProgress;
    setState(() {
      inProgress;
    });
    String mode = "";
    mode = targetDate.compareTo(date) < 0 ? "-" : "+";
    if(mode == "-"){
      while(targetDate.compareTo(date) < 0){
        _countDown(mode);
        await Future.delayed(const Duration(milliseconds: 2));
      }
      date = date.add(increment);
    }else{
      while(targetDate.compareTo(date) > 0){
        _countDown(mode);
        await Future.delayed(const Duration(milliseconds: 2));
      }
      date = date.subtract(increment);
    }
  }

  void _modDay(String mode, Duration dur){
    if(dur == const Duration(days: 99)){
      if(mode == '-'){
        targetDate = DateTime(targetDate.year, targetDate.month - 1, targetDate.day, targetDate.hour, targetDate.minute);
      }else{
        targetDate = DateTime(targetDate.year, targetDate.month + 1, targetDate.day, targetDate.hour, targetDate.minute);
      }
    }else if(dur == const Duration(days: 365)){
      if(mode == '-'){
        targetDate = DateTime(targetDate.year - 1, targetDate.month, targetDate.day, targetDate.hour, targetDate.minute);
      }else{
        targetDate = DateTime(targetDate.year + 1, targetDate.month, targetDate.day, targetDate.hour, targetDate.minute);
      }
    }else{
      if(mode == '-'){
        targetDate = targetDate.subtract(dur);
      }else{
        targetDate = targetDate.add(dur);
      }
    }
    setState(() {
      targetDate;
    });
  }

  void _countDown(String mode) {
    if(mode == "-"){
      date = date.subtract(increment);
    }else{
      date = date.add(increment);
    }
    
    setState(() {
      date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Center(
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
                      onPressed: () => _modDay("+", const Duration(days: 1)),
                      child: const Icon(Icons.arrow_upward),
                    ),
                    Text(
                      DateFormat('dd').format(date),
                      style: tStyle,
                    ),
                    ElevatedButton(
                      onPressed: () => _modDay("-", const Duration(days: 1)),
                      child: const Icon(Icons.arrow_downward),
                    ),
                  ],
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _modDay("+", const Duration(days: 99)),
                      child: const Icon(Icons.arrow_upward),
                    ),
                    Text(
                      DateFormat('MM').format(date),
                      style: tStyle,
                    ),
                    ElevatedButton(
                      onPressed: () => _modDay("-", const Duration(days: 99)),
                      child: const Icon(Icons.arrow_downward),
                    ),
                  ],
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _modDay("+", const Duration(days: 365)),
                      child: const Icon(Icons.arrow_upward),
                    ),
                    Text(
                      DateFormat('yyyy').format(date),
                      style: tStyle,
                    ),
                    ElevatedButton(
                      onPressed: () => _modDay("-", const Duration(days: 365)),
                      child: const Icon(Icons.arrow_downward),
                    ),
                  ],
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _modDay("+", const Duration(hours: 1)),
                      child: const Icon(Icons.arrow_upward),
                    ),
                    Text(
                      DateFormat('HH').format(date),
                      style: tStyle,
                    ),
                    ElevatedButton(
                      onPressed: () => _modDay("-", const Duration(hours: 1)),
                      child: const Icon(Icons.arrow_downward),
                    ),
                  ],
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _modDay("+", const Duration(minutes: 1)),
                      child: const Icon(Icons.arrow_upward),
                    ),
                    Text(
                      DateFormat('mm').format(date),
                      style: tStyle,
                    ),
                    ElevatedButton(
                      onPressed: () => _modDay("-", const Duration(minutes: 1)),
                      child: const Icon(Icons.arrow_downward),
                    ),
                  ],
                )
              ],
            ),
            ),
            Visibility(
                visible: inProgress,
                child: Wrap(
              spacing: 20,
              children: [
                Column(
                  children: [
                    Text(
                      DateFormat('dd').format(date),
                      style: cStyle,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      DateFormat('MM').format(date),
                      style: cStyle,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      DateFormat('yyyy').format(date),
                      style: cStyle,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      DateFormat('HH').format(date),
                      style: cStyle,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      DateFormat('mm').format(date),
                      style: cStyle,
                    ),
                  ],
                )
              ],
            ),
            ),
          ],
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startCountdown,
        tooltip: 'Start',
        child: const Icon(Icons.play_arrow),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
