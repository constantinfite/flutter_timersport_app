import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sport_timer/services/exercice_service.dart';
import 'package:sport_timer/models/exercice.dart';
import 'package:flutter_conditional_rendering/flutter_conditional_rendering.dart';
import 'package:intl/intl.dart';

class SerieWorkoutScreen extends StatefulWidget {
  const SerieWorkoutScreen({Key? key, required this.id}) : super(key: key);
  final int id;

  @override
  State<SerieWorkoutScreen> createState() => _SerieWorkoutScreenState();
}

class _SerieWorkoutScreenState extends State<SerieWorkoutScreen> {
  @override
  final _exerciceService = ExerciceService();
  final _exercice = Exercice();

  final primaryColor = Color.fromARGB(255, 255, 95, 77);
  final secondaryColor = Color.fromARGB(255, 60, 60, 60);
  final backgroundColor = Color.fromARGB(255, 241, 241, 241);
  var f = NumberFormat("00");
  int _seconds = 5;
  int _minutes = 1;
  var round = 0;
  Timer _timer = Timer(Duration(milliseconds: 1), () {});

  void initState() {
    super.initState();
    _exercice.resttime = 0;
    getExercice();
  }

  getExercice() async {
    var exercice = await _exerciceService.readExerciceById(widget.id);
    setState(() {
      _exercice.id = exercice[0]['id'];
      _exercice.name = exercice[0]['name'] ?? 'No name';
      _exercice.repetition = exercice[0]['repetition'] ?? 0;
      _exercice.serie = exercice[0]['serie'] ?? 0;
      _exercice.resttime = exercice[0]['resttime'] ?? 0;
      _exercice.exercicetime = exercice[0]['exercicetime'] ?? 0;
      _exercice.mode = exercice[0]['mode'] ?? "";
      //set minute and second for timer
      _minutes = _exercice.resttime! ~/ 60;
      _seconds = _exercice.resttime!.toInt() % 60;
    });
  }

  nextRound() {
    _timer.cancel();
    getExercice();
    setState(() {
      round++;
    });
  }

  previousRound() {
    _timer.cancel();
    getExercice();
    setState(() {
      round--;
    });
  }

  void _startTimer() {
    if (_minutes > 0) {
      _seconds = _seconds + _minutes * 60;
    }
    if (_seconds > 0) {
      _minutes = (_seconds / 60).floor();
      _seconds = _seconds - (_minutes * 60);
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          if (_minutes > 0) {
            _seconds = 59;
            _minutes--;
          } else {
            _timer.cancel();
          }
        }
      });
    });
  }

  void _pauseTimer() {
    _timer.cancel();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.clear),
            color: secondaryColor,
            iconSize: 40,
            onPressed: () => Navigator.pop(context),

            // 2
          ),
          backgroundColor: Colors.transparent,
          actionsIconTheme: IconThemeData(color: primaryColor, size: 36),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              elevation: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    title: Text(
                      _exercice.name.toString(),
                      style: TextStyle(fontSize: 20),
                    ),
                    subtitle: Text(_exercice.serie?.toInt().toString() ?? " "),
                  ),
                ],
              ),
              margin: EdgeInsets.fromLTRB(30, 20, 30, 0),
              shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: BorderSide(color: Colors.white)),
            ),
            SizedBox(height: 20),
            Icon(
              Icons.sports_sharp,
              color: secondaryColor,
              size: 100,
            ),
            Conditional.single(
              context: context,
              conditionBuilder: (BuildContext context) => round % 2 == 1,
              widgetBuilder: (BuildContext context) => Text(
                "${f.format(_minutes)} : ${f.format(_seconds)}",
                style: TextStyle(
                    color: secondaryColor,
                    fontSize: 100,
                    letterSpacing: 1,
                    wordSpacing: 1),
              ),
              fallbackBuilder: (BuildContext context) => Text(
                  _exercice.repetition?.toInt().toString() ?? "",
                  style: TextStyle(color: secondaryColor, fontSize: 130)),
            ),
            SizedBox(height: 100),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 50.0),
                IconButton(
                    icon: Icon(Icons.arrow_back_ios_rounded),
                    color: primaryColor,
                    iconSize: 70,
                    onPressed: () => previousRound()
                    // 2
                    ),
                Conditional.single(
                  context: context,
                  conditionBuilder: (BuildContext context) => round % 2 == 1,
                  widgetBuilder: (BuildContext context) => IconButton(
                      icon: Icon(
                          _timer.isActive ? Icons.pause : Icons.play_arrow),
                      color: primaryColor,
                      iconSize: 70,
                      onPressed: () {
                        if (!_timer.isActive) {
                          ///start
                          _startTimer();
                        } else {
                          ///pause
                          _pauseTimer();
                        }
                        setState(() {
                          ///change icon
                        });
                        // 2
                      }),
                  fallbackBuilder: (BuildContext context) => Text(''),
                ),
                IconButton(
                    icon: Icon(Icons.arrow_forward_ios_rounded),
                    color: primaryColor,
                    iconSize: 70,
                    onPressed: () => nextRound()
                    // 2
                    ),
                const SizedBox(width: 50.0)
              ],
            )
          ],
        ));
  }
}
