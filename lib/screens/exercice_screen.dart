import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sport_timer/models/exercice.dart';
import 'package:sport_timer/services/exercice_service.dart';
import 'package:numberpicker/numberpicker.dart';

class ExerciceTimeScreen extends StatefulWidget {
  const ExerciceTimeScreen({Key? key, required this.mode}) : super(key: key);
  final String mode;
  @override
  State<ExerciceTimeScreen> createState() => _ExerciceTimeScreenState();
}

class _ExerciceTimeScreenState extends State<ExerciceTimeScreen> {
  final _exerciceNameController = TextEditingController();
  int _serieNumber = 0;
  int _repNumber = 0;
  int _restTime = 0;
  int _exerciceTime = 0;

  Duration duration_resttime = Duration(minutes: 0, seconds: 0);

  final primaryColor = Color.fromARGB(255, 255, 95, 77);
  final secondaryColor = Color.fromARGB(255, 60, 60, 60);
  final backgroundColor = Color.fromARGB(255, 241, 241, 241);
  final blueColor = Color.fromARGB(255, 173, 200, 243);
  final cyanColor = Color.fromARGB(255, 87, 203, 214);
  final orangeColor = Color.fromARGB(255, 254, 143, 63);
  final redColor = Color.fromARGB(255, 251, 80, 97);

  final exercice = Exercice();
  final _exerciceService = ExerciceService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 100,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
            ),
            color: secondaryColor,
            iconSize: 40,
            onPressed: () => Navigator.pop(context)
            // 2
            ),
        backgroundColor: Colors.transparent,
        title: Text(
          'Add exercice',
          style: TextStyle(
            color: secondaryColor,
            fontSize: 30,
            fontFamily: 'BalooBhai',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.check),
              color: primaryColor,
              onPressed: () async {
                final _exercice = Exercice();
                _exercice.name = _exerciceNameController.text;
                _exercice.repetition = _repNumber;
                _exercice.serie = _serieNumber;
                _exercice.resttime = _restTime;
                _exercice.exercicetime = _exerciceTime;
                _exercice.mode = widget.mode;

                await _exerciceService.saveExercice(_exercice);
                Navigator.pop(context);
              }
              // 2
              ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            color: secondaryColor,
            onPressed: () => Navigator.pop(context),

            // 2
          ),
        ],
        actionsIconTheme: IconThemeData(color: primaryColor, size: 36),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(children: <Widget>[
            TextField(
              style: TextStyle(
                color: secondaryColor,
                fontSize: 20,
                fontFamily: 'BalooBhai',
              ),
              controller: _exerciceNameController,
              decoration: InputDecoration(
                hintText: 'Enter exercice name',
                filled: true,
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 0.0,
                    ),
                    borderRadius: BorderRadius.circular(20.0)),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Card(
              color: Colors.white,
              child: Column(children: [
                ListTile(
                  title: Row(
                    children: <Widget>[
                      Text(
                        "Number of serie",
                        style: TextStyle(
                          color: secondaryColor,
                          fontSize: 20,
                          fontFamily: 'BalooBhai',
                        ),
                      ),
                    ],
                  ),
                  /*
                  trailing: Text(
                    _serieNumber.toString(),
                    style: TextStyle(
                        color: cyanColor,
                        fontSize: 25,
                        fontFamily: 'BalooBhai2',
                        fontWeight: FontWeight.bold),
                  ),*/
                ),
                SizedBox(
                  height: 70,
                  child: ListTile(
                    title: NumberPicker(
                      selectedTextStyle: TextStyle(
                          color: cyanColor,
                          fontSize: 30,
                          fontFamily: "BalooBhai2",
                          fontWeight: FontWeight.w600),
                      axis: Axis.horizontal,
                      value: _serieNumber,
                      minValue: 0,
                      maxValue: 20,
                      onChanged: (value) =>
                          setState(() => _serieNumber = value),
                    ),
                  ),
                ),
              ]),
              shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.transparent)),
              elevation: 2,
            ),
            SizedBox(
              height: 20,
            ),
            Card(
              color: Colors.white,
              child: Column(children: [
                ListTile(
                  title: Row(
                    children: <Widget>[
                      Text(
                        "Number of repetition",
                        style: TextStyle(
                          color: secondaryColor,
                          fontSize: 20,
                          fontFamily: 'BalooBhai',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 70,
                  child: ListTile(
                    title: NumberPicker(
                      selectedTextStyle: TextStyle(
                          color: redColor,
                          fontSize: 30,
                          fontFamily: "BalooBhai2",
                          fontWeight: FontWeight.w600),
                      axis: Axis.horizontal,
                      value: _repNumber,
                      minValue: 0,
                      maxValue: 20,
                      onChanged: (value) => setState(() => _repNumber = value),
                    ),
                  ),
                ),
              ]),
              shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.transparent)),
              elevation: 2,
            ),
            SizedBox(
              height: 20,
            ),
            Card(
              color: Colors.white,
              child: Column(children: [
                ListTile(
                  title: Row(
                    children: <Widget>[
                      Text(
                        "Rest time",
                        style: TextStyle(
                          color: secondaryColor,
                          fontSize: 20,
                          fontFamily: 'BalooBhai',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: ListTile(
                    title: CupertinoTheme(
                      data: CupertinoThemeData(
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle: TextStyle(
                              fontFamily: 'BalooBhai',
                              fontSize: 16,
                              color: redColor,
                              decorationColor: redColor),
                        ),
                      ),
                      child: CupertinoTimerPicker(
                        initialTimerDuration: duration_resttime,
                        mode: CupertinoTimerPickerMode.ms,
                        onTimerDurationChanged: (duration) => setState(() {
                          duration_resttime = duration;
                        }),
                      ),
                    ),
                  ),
                ),
              ]),
              shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.transparent)),
              elevation: 2,
            ),

            /*
                Text("Number of serie"),
                SizedBox(height: 10),
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: SfSlider(
                            min: 0,
                            max: 10,
                            value: _serieNumber,
                            interval: 2,
                            showTicks: true,
                            showLabels: true,
                            activeColor: primaryColor,
                            inactiveColor: secondaryColor,
                            enableTooltip: true,
                            stepSize: 1,
                            showDividers: true,
                            tooltipShape: SfPaddleTooltipShape(),
                            onChanged: (value) {
                              setState(() {
                                _serieNumber = value;
                              });
                            },
                          ),
                        ),
                      ],
                    )),
                SizedBox(height: 50),
                Conditional.single(
                    context: context,
                    conditionBuilder: (BuildContext context) =>
                        widget.mode == "rep",
                    widgetBuilder: (BuildContext context) {
                      return Column(
                        children: <Widget>[
                          Text("Number of repetition"),
                          SizedBox(height: 10),
                          Container(
                              margin: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SfSlider(
                                      min: 0,
                                      max: 20,
                                      value: _repNumber,
                                      interval: 4,
                                      showTicks: true,
                                      showLabels: true,
                                      activeColor: primaryColor,
                                      inactiveColor: secondaryColor,
                                      enableTooltip: true,
                                      stepSize: 1,
                                      showDividers: true,
                                      tooltipShape: SfPaddleTooltipShape(),
                                      onChanged: (value) {
                                        setState(() {
                                          _repNumber = value;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              )),
                        ],
                      );
                    },
                    fallbackBuilder: (BuildContext context) {
                      return Column(
                        children: <Widget>[
                          Text("Time of Exercice"),
                          SizedBox(height: 10),
                          Container(
                              margin: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SfSlider(
                                      min: 0,
                                      max: 120,
                                      value: _exerciceTime,
                                      interval: 30,
                                      showTicks: true,
                                      showLabels: true,
                                      activeColor: primaryColor,
                                      inactiveColor: secondaryColor,
                                      enableTooltip: true,
                                      stepSize: 10,
                                      showDividers: true,
                                      tooltipShape: SfPaddleTooltipShape(),
                                      onChanged: (value) {
                                        setState(() {
                                          _exerciceTime = value;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              )),
                        ],
                      );
                    }),
                SizedBox(height: 50),
                Text("Rest time"),
                SizedBox(height: 10),
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: SfSlider(
                            min: 0,
                            max: 120,
                            value: _restTime,
                            interval: 30,
                            showTicks: true,
                            showLabels: true,
                            activeColor: primaryColor,
                            inactiveColor: secondaryColor,
                            enableTooltip: true,
                            stepSize: 10,
                            showDividers: true,
                            tooltipShape: SfPaddleTooltipShape(),
                            onChanged: (value) {
                              setState(() {
                                _restTime = value;
                              });
                            },
                          ),
                        ),
                      ],
                    )),
                    */
          ]),
        ),
      ),
    );
  }
}
