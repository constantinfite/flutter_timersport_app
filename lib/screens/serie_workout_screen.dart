import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sport_timer/services/exercice_service.dart';
import 'package:sport_timer/models/exercice.dart';
import 'package:flutter_conditional_rendering/flutter_conditional_rendering.dart';
import 'package:intl/intl.dart';
import 'package:sport_timer/presentation/icons.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class SerieWorkoutScreen extends StatefulWidget {
  const SerieWorkoutScreen({Key? key, required this.id}) : super(key: key);
  final int id;

  @override
  State<SerieWorkoutScreen> createState() => _SerieWorkoutScreenState();
}

class _SerieWorkoutScreenState extends State<SerieWorkoutScreen> {
  final _exerciceService = ExerciceService();
  final _exercice = Exercice();

  final primaryColor = Color.fromARGB(255, 255, 95, 77);
  final secondaryColor = Color.fromARGB(255, 60, 60, 60);
  final backgroundColor = Color.fromARGB(255, 241, 241, 241);
  var f = NumberFormat("00");
  int _seconds = 5;
  int _minutes = 1;
  int _round = 0;
  double _sliderRound = 0;
  Timer _timer = Timer(Duration(milliseconds: 1), () {});

  @override
  void initState() {
    super.initState();
    _exercice.resttime = 0;
    _exercice.serie = 1;
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
      _round++;
    });

    if (_round % 2 == 0) {
      _sliderRound = (0.5 * _round).round() * (1 / _exercice.serie!.toInt());
    }
    if (_round / 2 == _exercice.serie) {
      Navigator.pop(context);
    }
  }

  previousRound() {
    var _timeSecond = _minutes * 60 + _seconds;
    if (_exercice.resttime! > _timeSecond) {
      _timer.cancel();
      setState(() {
        _minutes = _exercice.resttime! ~/ 60;
        _seconds = _exercice.resttime!.toInt() % 60;
      });
    } else {
      _timer.cancel();
      getExercice();
      setState(() {
        _round--;
      });
      if (_round % 2 == 0) {
        _sliderRound = (0.5 * _round).round() * (1 / _exercice.serie!.toInt());
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
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
            SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Card(
                color: Colors.white,
                elevation: 2.0,
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.white)),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        MyFlutterApp.noun_repetition,
                        color: primaryColor,
                        size: 50,
                      ),
                      SizedBox(width: 15),
                      SizedBox(
                        width: 70,
                        child: Column(
                          children: [
                            Text(
                              _exercice.name.toString(),
                              style: TextStyle(
                                fontSize: 20,
                                color: secondaryColor,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(width: 20),
              Card(
                color: Colors.white,
                elevation: 2.0,
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.white)),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                  child: Row(
                    children: [
                      Conditional.single(
                        context: context,
                        conditionBuilder: (BuildContext context) =>
                            _round % 2 == 1,
                        widgetBuilder: (BuildContext context) => Icon(
                          MyFlutterApp.noun_number,
                          color: primaryColor,
                          size: 50,
                        ),
                        fallbackBuilder: (BuildContext context) => Icon(
                          MyFlutterApp.noun_time,
                          color: primaryColor,
                          size: 50,
                        ),
                      ),
                      SizedBox(width: 15),
                      Text(
                        "Mode",
                        style: TextStyle(
                            fontSize: 20,
                            color: secondaryColor,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
            ]),
            SizedBox(height: 50),
            Conditional.single(
              context: context,
              conditionBuilder: (BuildContext context) => _round % 2 == 1,
              widgetBuilder: (BuildContext context) => Text(
                "${f.format(_minutes)}:${f.format(_seconds)}",
                style: TextStyle(
                    color: secondaryColor,
                    fontSize: 100,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    wordSpacing: 1),
              ),
              fallbackBuilder: (BuildContext context) => Text(
                  _exercice.repetition?.toInt().toString() ?? "",
                  style: TextStyle(
                      color: secondaryColor,
                      fontSize: 100,
                      fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 50.0),
                Visibility(
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  visible: _round > 0,
                  child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_rounded),
                      color: primaryColor,
                      iconSize: 50,
                      onPressed: () => previousRound()
                      // 2
                      ),
                ),
                Visibility(
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  visible: _round % 2 == 1,
                  child: IconButton(
                      icon: Icon(_timer.isActive
                          ? Icons.abc
                          : Icons.play_arrow_outlined),
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
                ),
                IconButton(
                    icon: Icon(Icons.arrow_forward_ios_rounded),
                    color: primaryColor,
                    iconSize: 50,
                    onPressed: () => nextRound()
                    // 2
                    ),
                const SizedBox(width: 50.0)
              ],
            ),
            SizedBox(height: 100),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: Row(children: [
                buildSideLabel(0),
                SizedBox(width: 30),
                Expanded(
                    child: LinearProgressIndicator(
                  backgroundColor: secondaryColor,
                  color: primaryColor,
                  value: _sliderRound,
                )),
                SizedBox(width: 30),
                buildSideLabel(0),
              ]),
            )
          ],
        ));
  }

  Widget buildSideLabel(double value) => Text(
        value.round().toString(),
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      );
}
