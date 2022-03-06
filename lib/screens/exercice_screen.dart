import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sport_timer/models/exercice.dart';
import 'package:sport_timer/services/exercice_service.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:sport_timer/widget/my_color_picker.dart';

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
  Color _color = Colors.blue;

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

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    return "$twoDigitMinutes min $twoDigitSeconds s";
  }

  convert_duration_time(Duration duration) {
    var minute = duration.inMinutes.remainder(60);
    var second = duration.inSeconds.remainder(60);
    _restTime = minute * 60 + second;
  }

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
              iconSize: 50,
              onPressed: () async {
                convert_duration_time(duration_resttime);
                final _exercice = Exercice();
                _exercice.name = _exerciceNameController.text;
                _exercice.repetition = _repNumber;
                _exercice.serie = _serieNumber;
                _exercice.resttime = _restTime;
                _exercice.exercicetime = _exerciceTime;
                _exercice.mode = widget.mode;
                _exercice.color = _color.value;

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
                ExpansionTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Number of serie",
                        style: TextStyle(
                          color: secondaryColor,
                          fontSize: 20,
                          fontFamily: 'BalooBhai',
                        ),
                      ),
                      Text(
                        _serieNumber.toString(),
                        style: TextStyle(
                            color: cyanColor,
                            fontSize: 25,
                            fontFamily: 'BalooBhai2',
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  children: [
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
                  ],
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
                ExpansionTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Number of repetition",
                        style: TextStyle(
                          color: secondaryColor,
                          fontSize: 20,
                          fontFamily: 'BalooBhai',
                        ),
                      ),
                      Text(
                        _repNumber.toString(),
                        style: TextStyle(
                            color: redColor,
                            fontSize: 25,
                            fontFamily: 'BalooBhai2',
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  children: [
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
                          onChanged: (value) =>
                              setState(() => _repNumber = value),
                        ),
                      ),
                    ),
                  ],
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
                ExpansionTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rest time",
                        style: TextStyle(
                          color: secondaryColor,
                          fontSize: 20,
                          fontFamily: 'BalooBhai',
                        ),
                      ),
                      Text(
                        _printDuration(duration_resttime),
                        style: TextStyle(
                            color: orangeColor,
                            fontSize: 25,
                            fontFamily: 'BalooBhai2',
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  children: [
                    SizedBox(
                      height: 200,
                      child: ListTile(
                        title: CupertinoTimerPicker(
                          initialTimerDuration: duration_resttime,
                          mode: CupertinoTimerPickerMode.ms,
                          onTimerDurationChanged: (duration) => setState(() {
                            duration_resttime = duration;
                          }),
                        ),
                      ),
                    ),
                  ],
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
                ExpansionTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Select color",
                        style: TextStyle(
                          color: secondaryColor,
                          fontSize: 20,
                          fontFamily: 'BalooBhai',
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: _color),
                      )
                    ],
                  ),
                  children: [
                    SizedBox(
                      height: 80,
                      child: ListTile(
                          title: MyColorPicker(
                              onSelectColor: (value) {
                                setState(() {
                                  _color = value;
                                });
                              },
                              availableColors: [
                                redColor,
                                cyanColor,
                                orangeColor,
                                blueColor
                              ],
                              initialColor: Colors.blue)),
                    ),
                  ],
                ),
              ]),
              shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.transparent)),
              elevation: 2,
            ),
          ]),
        ),
      ),
    );
  }
}
