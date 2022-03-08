import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sport_timer/services/exercice_service.dart';
import 'package:sport_timer/models/exercice.dart';
import 'package:intl/intl.dart';
import 'package:sport_timer/presentation/icons.dart';
import 'package:sport_timer/presentation/app_theme.dart';

class SerieWorkoutScreen extends StatefulWidget {
  const SerieWorkoutScreen({Key? key, required this.id}) : super(key: key);
  final int id;

  @override
  State<SerieWorkoutScreen> createState() => _SerieWorkoutScreenState();
}

class _SerieWorkoutScreenState extends State<SerieWorkoutScreen> {
  final _exerciceService = ExerciceService();
  final _exercice = Exercice();

  var f = NumberFormat("00");
  int _seconds = 5;
  int _minutes = 1;
  int _round = 0;

  int totalSecond = 0;
  // index start at 0 [0,1  2,3  4,5]

  final commentControler = TextEditingController();

  Timer _timer = Timer(Duration(milliseconds: 1), () {});
  Timer _totalTimer = Timer(Duration(milliseconds: 1), () {});
  double progress = 1.0;

  @override
  void initState() {
    super.initState();
    _exercice.resttime = 10;
    _exercice.serie = 1;
    _exercice.color = 0;
    getExercice();
    startTotalTimer();
  }

  startTotalTimer() {
    _totalTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        totalSecond++;
      });
    });
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

    /*if (_round / 2 == _exercice.serie) {
      Navigator.pop(context);
    }*/
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
            nextRound();
          }
        }
      });
    });
  }

  String formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes;
    final seconds = totalSeconds % 60;

    final minutesString = '$minutes'.padLeft(1, '0');
    final secondsString = '$seconds'.padLeft(2, '0');
    return '$minutesString m $secondsString s';
  }

  String actualSerie(int round) {
    if (round > _exercice.serie!) {
      return _exercice.serie.toString() + "/" + _exercice.serie.toString();
    } else {
      return ((_round + 2) ~/ 2).toString() + "/" + _exercice.serie.toString();
    }
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Continue"),
      onPressed: () {
        Navigator.pop(context);
        _timer.cancel();
        _totalTimer.cancel();
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Exit workout before finishing"),
      content: Text("You will lose all the progress"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppTheme.colors.backgroundColor,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.clear),
              color: AppTheme.colors.secondaryColor,
              iconSize: 40,
              onPressed: () => {showAlertDialog(context)}

              // 2
              ),
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Card(
                color: Colors.white,
                elevation: 2.0,
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.white)),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
                                size: 35,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                _exercice.name.toString(),
                                style: TextStyle(
                                  fontSize: 25,
                                  fontFamily: 'BalooBhai',
                                  color: AppTheme.colors.secondaryColor,
                                ),
                              )
                            ],
                          ),
                          Text(
                            "Exercice",
                            style: TextStyle(
                                fontSize: 15,
                                color: AppTheme.colors.secondaryColor,
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
                                size: 30,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                actualSerie(_round),
                                style: TextStyle(
                                  fontSize: 25,
                                  fontFamily: 'BalooBhai',
                                  color: AppTheme.colors.secondaryColor,
                                ),
                              )
                            ],
                          ),
                          Text(
                            "Serie",
                            style: TextStyle(
                                fontSize: 15,
                                color: AppTheme.colors.secondaryColor,
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
                textCercle(),
                GestureDetector(
                  onTap: () => {
                    if (_round % 2 == 0 && _round < (_exercice.serie! * 2))
                      {nextRound()},
                    if (_round == (_exercice.serie! * 2))
                      {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(30))),
                          constraints: BoxConstraints(),
                          builder: (BuildContext context) {
                            return bottomSheet();
                          },
                        )
                      }
                    else
                      {
                        if (!_timer.isActive)
                          {_startTimer()}
                        else
                          {_timer.cancel()}
                      }
                  },
                  child: SizedBox(
                    width: 280,
                    height: 280,
                    child: CircularProgressIndicator(
                      color: Color(_exercice.color!),
                      value: (_seconds + _minutes * 60) / _exercice.resttime!,
                      strokeWidth: 10,
                      backgroundColor: Colors.white,
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
                  color: AppTheme.colors.secondaryColor,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: (_exercice.serie! * 2) + 1,
                      itemBuilder: (context, index) {
                        return buildCard(
                            index: index,
                            numberElement: (_exercice.serie! * 2) + 1);
                      }),
                ),
              ),
            ]),
          ],
        ));
  }

  Widget buildCard({required index, numberElement}) {
    if (index + 1 == numberElement) {
      return Padding(
        padding: EdgeInsets.fromLTRB(10, 10, 5, 10),
        child: SizedBox(
          width: 140,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _timer.cancel();
                getExercice();
                _round = index;
              });
            },
            child: Card(
              margin: EdgeInsets.zero,
              color: _round == index ? Color(_exercice.color!) : Colors.white,
              shape:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Finish",
                        style: TextStyle(
                          fontSize: 27,
                          color: _round == index
                              ? Colors.white
                              : Color(_exercice.color!),
                          fontFamily: 'BalooBhai',
                        )),
                  ]),
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: index % 2 == 0
            ? EdgeInsets.fromLTRB(15, 10, 1, 10)
            : EdgeInsets.fromLTRB(2, 10, 5, 10),
        child: SizedBox(
          width: 140,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _timer.cancel();
                getExercice();
                _round = index;
              });
            },
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
                            color: AppTheme.colors.secondaryColor,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700)),
                    Text(
                        index % 2 == 0
                            ? _exercice.repetition.toString() + " rep"
                            : formatDuration(_exercice.resttime!),
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
                            color: AppTheme.colors.secondaryColor,
                            fontFamily: 'Roboto',
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w400))
                  ]),
            ),
          ),
        ),
      );
    }
  }

  Widget textCercle() {
    if (_round == (_exercice.serie! * 2)) {
      return Text(
        "Finish",
        style: TextStyle(
            fontSize: 80,
            fontFamily: 'BalooBhai',
            color: AppTheme.colors.secondaryColor,
            letterSpacing: 1,
            wordSpacing: 1),
      );
    }
    if (_round % 2 == 1) {
      return Text(
        "${f.format(_minutes)}:${f.format(_seconds)}",
        style: TextStyle(
            fontSize: 80,
            fontFamily: 'BalooBhai',
            color: AppTheme.colors.secondaryColor,
            letterSpacing: 1,
            wordSpacing: 1),
      );
    } else {
      return Text(_exercice.repetition?.toInt().toString() ?? "",
          style: TextStyle(
              fontSize: 100,
              fontFamily: 'BalooBhai',
              color: AppTheme.colors.secondaryColor));
    }
  }

  Widget bottomSheet() {
    return SingleChildScrollView(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        padding: EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width * 0.90,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              /* Text(d
                _exercice.name.toString(),
                style: TextStyle(
                  fontSize: 40,
                  fontFamily: 'BalooBhai',
                  color: AppTheme.colors.secondaryColor,
                ),
              ),*/
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Number of repetition",
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'BalooBhai2',
                            color: AppTheme.colors.secondaryColor,
                            fontWeight: FontWeight.w700),
                      ),
                      Text("Number of serie",
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'BalooBhai2',
                              color: AppTheme.colors.secondaryColor,
                              fontWeight: FontWeight.w700)),
                      Text("Rest time",
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'BalooBhai2',
                              color: AppTheme.colors.secondaryColor,
                              fontWeight: FontWeight.w700)),
                      Text("Total time",
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'BalooBhai2',
                              color: AppTheme.colors.secondaryColor,
                              fontWeight: FontWeight.w700))
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_exercice.serie.toString(),
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'BalooBhai2',
                              color: AppTheme.colors.secondaryColor,
                              fontWeight: FontWeight.w700)),
                      Text(_exercice.repetition.toString(),
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'BalooBhai2',
                              color: AppTheme.colors.secondaryColor,
                              fontWeight: FontWeight.w700)),
                      Text(formatDuration(_exercice.resttime!),
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'BalooBhai2',
                              color: AppTheme.colors.secondaryColor,
                              fontWeight: FontWeight.w700)),
                      Text(formatDuration(totalSecond),
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'BalooBhai2',
                              color: AppTheme.colors.secondaryColor,
                              fontWeight: FontWeight.w700))
                    ],
                  )
                ],
              ),
              SizedBox(
                width: 300,
                child: TextField(
                  style: TextStyle(
                    color: AppTheme.colors.secondaryColor,
                    fontSize: 20,
                    fontFamily: 'BalooBhai',
                  ),
                  controller: commentControler,
                  decoration: InputDecoration(
                    hintText: 'Comments of your workout',
                    filled: true,
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(_exercice.color!)),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(_exercice.color!),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(20.0)),
                  ),
                ),
              ),
              ElevatedButton(
                child: Text('Save workout'),
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                  primary: Color(_exercice.color!),
                  textStyle: TextStyle(fontFamily: "BalooBhai", fontSize: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
