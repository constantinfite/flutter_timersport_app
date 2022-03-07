import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sport_timer/services/exercice_service.dart';
import 'package:sport_timer/models/exercice.dart';
import 'package:flutter_conditional_rendering/flutter_conditional_rendering.dart';
import 'package:intl/intl.dart';
import 'package:sport_timer/presentation/icons.dart';

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

  Timer _timer = Timer(Duration(milliseconds: 1), () {});
  double progress = 1.0;

  @override
  void initState() {
    super.initState();
    _exercice.resttime = 0;
    _exercice.serie = 1;
    _exercice.color = 0;
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
      _exercice.color = exercice[0]['color'] ?? 0;
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
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                MyFlutterApp.noun_workout,
                                color: Color(_exercice.color!),
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                _exercice.name.toString(),
                                style: TextStyle(
                                  fontSize: 30,
                                  fontFamily: 'BalooBhai',
                                  color: secondaryColor,
                                ),
                              )
                            ],
                          ),
                          Text(
                            "Exercice",
                            style: TextStyle(
                                fontSize: 20,
                                color: secondaryColor,
                                fontFamily: 'Roboto',
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w400),
                          )
                        ],
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                MyFlutterApp.noun_repetition,
                                color: Color(_exercice.color!),
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                ((_round + 2) ~/ 2).toString() +
                                    "/" +
                                    _exercice.serie.toString(),
                                style: TextStyle(
                                  fontSize: 30,
                                  fontFamily: 'BalooBhai',
                                  color: secondaryColor,
                                ),
                              )
                            ],
                          ),
                          Text(
                            "Serie",
                            style: TextStyle(
                                fontSize: 20,
                                color: secondaryColor,
                                fontFamily: 'Roboto',
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w400),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ]),
            SizedBox(height: 50),
            Stack(
              alignment: Alignment.center,
              children: [
                Conditional.single(
                  context: context,
                  conditionBuilder: (BuildContext context) => _round % 2 == 1,
                  widgetBuilder: (BuildContext context) => Text(
                    "${f.format(_minutes)}:${f.format(_seconds)}",
                    style: TextStyle(
                        fontSize: 80,
                        fontFamily: 'BalooBhai',
                        color: secondaryColor,
                        letterSpacing: 1,
                        wordSpacing: 1),
                  ),
                  fallbackBuilder: (BuildContext context) => Text(
                      _exercice.repetition?.toInt().toString() ?? "",
                      style: TextStyle(
                          fontSize: 100,
                          fontFamily: 'BalooBhai',
                          color: secondaryColor)),
                ),
                GestureDetector(
                  onTap: () => {
                    if (_round % 2 == 0)
                      {print("rep"), nextRound()}
                    else
                      {print("time")}
                  },
                  child: SizedBox(
                    width: 250,
                    height: 250,
                    child: CircularProgressIndicator(
                      color: Color(_exercice.color!),
                      value: progress,
                      strokeWidth: 10,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
            Row(children: [
              Expanded(
                child: Container(
                  height: 160.0,
                  color: secondaryColor,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _exercice.serie! * 2,
                      itemBuilder: (context, index) {
                        return buildCard(index: index);
                      }),
                ),
              ),
            ]),
          ],
        ));
  }

  Widget buildCard({required index}) => Padding(
        padding: index % 2 == 0
            ? EdgeInsets.fromLTRB(15, 10, 1, 10)
            : EdgeInsets.fromLTRB(2, 10, 5, 10),
        child: SizedBox(
          width: 140,
          child: GestureDetector(
            onTap: () {},
            child: Card(
              margin: EdgeInsets.zero,
              color: _round == index ? Color(_exercice.color!) : Colors.white,
              shape:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(index % 2 == 0 ? "Exercice" : "Rest",
                        style: TextStyle(
                            fontSize: 20,
                            color: secondaryColor,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700)),
                    Text(
                        index % 2 == 0
                            ? _exercice.repetition.toString() + " rep"
                            : _exercice.resttime.toString(),
                        style: TextStyle(
                          fontSize: 27,
                          color: _round == index
                              ? Colors.white
                              : Color(_exercice.color!),
                          fontFamily: 'BalooBhai',
                        )),
                    Text("Serie " + ((index + 2) ~/ 2).toString(),
                        style: TextStyle(
                            fontSize: 20,
                            color: secondaryColor,
                            fontFamily: 'Roboto',
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w400))
                  ]),
            ),
          ),
        ),
      );

  Widget buildSideLabel(double value) => Text(
        value.round().toString(),
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      );
}
