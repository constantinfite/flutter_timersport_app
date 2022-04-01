import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sport_timer/models/events.dart';
import 'package:sport_timer/services/exercice_service.dart';
import 'package:sport_timer/services/event_service.dart';
import 'package:sport_timer/models/exercice.dart';
import 'package:intl/intl.dart';
import 'package:sport_timer/presentation/icons.dart';
import 'package:sport_timer/presentation/app_theme.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class TimerWorkoutScreen extends StatefulWidget {
  const TimerWorkoutScreen({Key? key, required this.id}) : super(key: key);
  final int id;

  @override
  State<TimerWorkoutScreen> createState() => _TimerWorkoutScreenState();
}

class _TimerWorkoutScreenState extends State<TimerWorkoutScreen> {
  final _eventService = EventService();
  final _exerciceService = ExerciceService();
  final _exercice = Exercice();

  var nowDate = DateTime.now().toUtc();

  var f = NumberFormat("00");
  int _secondsRest = 5;
  int _minutesRest = 1;

  int _secondsExercice = 5;
  int _minutesExercice = 1;
  int _round = 0;

  int serieDone = 0;

  final commentControler = TextEditingController();

  final scrollController = ScrollController();

  //Sound
  AudioCache audioCache = AudioCache();

  //Timer
  Timer _timerRest = Timer(Duration(milliseconds: 1), () {});
  Timer _timerExercice = Timer(Duration(milliseconds: 1), () {});
  Timer _totalTimer = Timer(Duration(milliseconds: 1), () {});
  int totalSecond = 0;
  double progress = 1.0;

  @override
  void initState() {
    super.initState();

    _exercice.resttime = 10;
    _exercice.exercicetime = 10;
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
      //set minute and second for timerRest and timerExercice
      _minutesRest = _exercice.resttime! ~/ 60;
      _secondsRest = _exercice.resttime!.toInt() % 60;

      _minutesExercice = _exercice.exercicetime! ~/ 60;
      _secondsExercice = _exercice.exercicetime!.toInt() % 60;
    });
  }

  reInitializeTime() {
    _minutesRest = _exercice.resttime! ~/ 60;
    _secondsRest = _exercice.resttime!.toInt() % 60;

    _minutesExercice = _exercice.exercicetime! ~/ 60;
    _secondsExercice = _exercice.exercicetime!.toInt() % 60;
  }

  nextRound() {
    _timerRest.cancel();
    reInitializeTime();
    setState(() {
      _round++;
    });
  }

  _startTimerRest() {
    if (_minutesRest > 0) {
      _secondsRest = _secondsRest + _minutesRest * 60;
    }
    if (_secondsRest > 0) {
      _minutesRest = (_secondsRest / 60).floor();
      _secondsRest = _secondsRest - (_minutesRest * 60);
    }
    _timerRest = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRest == 4 && _minutesRest == 0) {
          audioCache.load('sounds/count_down2.wav');
          audioCache.play('sounds/count_down2.wav', volume: 5);
        }
        if (_secondsRest > 0) {
          _secondsRest--;
        } else {
          if (_minutesRest > 0) {
            _secondsRest = 59;
            _minutesRest--;
          } else {
            _timerRest.cancel();
            nextRound();
            jumpToItem(_round, context);
            if (_round != (_exercice.serie! * 2)) {
              _startTimerExercice();
            }
          }
        }
      });
    });
  }

  _startTimerExercice() {
    if (_minutesExercice > 0) {
      _secondsExercice = _secondsExercice + _minutesExercice * 60;
    }
    if (_secondsExercice > 0) {
      _minutesExercice = (_secondsExercice / 60).floor();
      _secondsExercice = _secondsExercice - (_minutesExercice * 60);
    }

    _timerExercice = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsExercice == 4 && _minutesExercice == 0) {
          audioCache.load('sounds/count_down2.wav');
          audioCache.play('sounds/count_down2.wav');
        }
        if (_secondsExercice > 0) {
          _secondsExercice--;
        } else {
          if (_minutesExercice > 0) {
            _secondsExercice = 59;
            _minutesExercice--;
          } else {
            serieDone++;
            _timerExercice.cancel();
            nextRound();
            jumpToItem(_round, context);
            _startTimerRest();
          }
        }
      });
    });
  }

  //Dialog if sure to exit workout
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
        _timerRest.cancel();
        _timerExercice.cancel();
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

  //Scroll automatically when touch card
  jumpToItem(int index, context) {
    double width = 140;

    scrollController.animateTo(width * index - 140,
        duration: Duration(seconds: 1), curve: Curves.easeIn);
  }

  String formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes;
    final seconds = totalSeconds % 60;

    final minutesString = '$minutes'.padLeft(1, '0');
    final secondsString = '$seconds'.padLeft(2, '0');
    return '$minutesString m $secondsString s';
  }

  //Serie display at the top
  String actualSerie() {
    if ((_round + 2) ~/ 2 > _exercice.serie!) {
      return _exercice.serie.toString() + "/" + _exercice.serie.toString();
    } else {
      return ((_round + 2) ~/ 2).toString() + "/" + _exercice.serie.toString();
    }
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
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Card(
                color: Colors.white,
                elevation: 2.0,
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.white)),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 10,
                    top: 10,
                    bottom: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          flex: 8,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    MyFlutterApp.noun_workout,
                                    color: Color(_exercice.color!),
                                    size: 30,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          _exercice.name.toString(),
                                          overflow: TextOverflow.fade,
                                          maxLines: 1,
                                          softWrap: false,
                                          style: TextStyle(
                                            fontSize: 25,
                                            fontFamily: 'BalooBhai',
                                            color:
                                                AppTheme.colors.secondaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                          )),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                    actualSerie(),
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontFamily: 'BalooBhai',
                                      color: AppTheme.colors.secondaryColor,
                                    ),
                                  ),
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
                          )),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 50),
            Stack(
              alignment: Alignment.center,
              children: [
                //Text(currentRepetition.toString()),
                GestureDetector(
                  onTap: () => {
                    HapticFeedback.mediumImpact(),
                    // on exercice Card
                    if (_round % 2 == 0 && _round < (_exercice.serie! * 2))
                      {
                        if (!_timerExercice.isActive)
                          {
                            _startTimerExercice(),
                          }
                        else
                          {_timerExercice.cancel()}
                      },
                    //End card
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
                    //on rest card
                    else if (_round % 2 == 1 && _round < (_exercice.serie! * 2))
                      {
                        if (!_timerRest.isActive)
                          {_startTimerRest()}
                        else
                          {_timerRest.cancel()}
                      }
                  },
                  child: SizedBox(
                      width: 300,
                      height: 300,
                      child: LiquidCircularProgressIndicator(
                        value: _round % 2 == 0
                            ? (_secondsExercice + _minutesExercice * 60) /
                                _exercice.exercicetime!
                            : (_secondsRest + _minutesRest * 60) /
                                _exercice.resttime!, // Defaults to 0.5.
                        valueColor: AlwaysStoppedAnimation(Color(_exercice
                            .color!)), // Defaults to the current Theme's accentColor.
                        backgroundColor: Colors
                            .white, // Defaults to the current Theme's backgroundColor.
                        borderColor: Colors.transparent,
                        borderWidth: 5.0,
                        direction: Axis
                            .vertical, // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.vertical.
                        center: textCercle(),
                      )),
                ),
              ],
            ),
            SizedBox(height: 50),
            Row(children: [
              Expanded(
                child: Container(
                  height: 140.0,
                  color: AppTheme.colors.secondaryColor,
                  child: ListView.builder(
                      controller: scrollController,
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
        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: SizedBox(
          width: 120,
          child: GestureDetector(
            onTap: () async {
              HapticFeedback.mediumImpact();
              jumpToItem(index, context);
              setState(() {
                _timerRest.cancel();
                _timerExercice.cancel();

                reInitializeTime();
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
                    Text("End",
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
            ? EdgeInsets.fromLTRB(5, 10, 1, 10)
            : EdgeInsets.fromLTRB(2, 10, 20, 10),
        child: SizedBox(
          width: 120,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              jumpToItem(index, context);
              setState(() {
                _timerRest.cancel();
                _timerExercice.cancel();
                reInitializeTime();
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
                            ? formatDuration(_exercice.exercicetime!)
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
        "${f.format(_minutesRest)}:${f.format(_secondsRest)}",
        style: TextStyle(
          fontSize: 80,
          fontFamily: 'BalooBhai',
          color: AppTheme.colors.secondaryColor,
        ),
      );
    } else {
      return Text("${f.format(_minutesExercice)}:${f.format(_secondsExercice)}",
          style: TextStyle(
              fontSize: 80,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Exercice",
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'BalooBhai2',
                              color: AppTheme.colors.secondaryColor,
                              fontWeight: FontWeight.w700),
                        ),
                        Text("Repetition made",
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
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(_exercice.name.toString(),
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'BalooBhai2',
                                color: AppTheme.colors.secondaryColor,
                                fontWeight: FontWeight.w700)),
                        Text(
                            serieDone.toString() +
                                " x " +
                                formatDuration(_exercice.exercicetime!),
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'BalooBhai2',
                                color: AppTheme.colors.secondaryColor,
                                fontWeight: FontWeight.w700)),
                        Text(formatDuration(totalSecond),
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'BalooBhai2',
                                color: AppTheme.colors.secondaryColor,
                                fontWeight: FontWeight.w700))
                      ],
                    ),
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
                onPressed: () async {
                  final _event = Event();
                  _event.name = _exercice.name;
                  _event.totaltime = totalSecond;
                  _event.resttime = _exercice.resttime;
                  _event.exercicetime = _exercice.exercicetime;
                  _event.arrayrepetition = "";
                  _event.serie = serieDone;
                  _event.mode = "timer";
                  _event.description = commentControler.text;
                  _event.datetime = nowDate.millisecondsSinceEpoch;

                  await _eventService.saveEvent(_event);

                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
