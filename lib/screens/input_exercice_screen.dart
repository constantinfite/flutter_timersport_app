import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sport_timer/models/exercice.dart';
import 'package:sport_timer/presentation/app_theme.dart';
import 'package:sport_timer/services/exercice_service.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:sport_timer/widget/my_color_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ExerciceTimeScreen extends StatefulWidget {
  const ExerciceTimeScreen({Key? key, required this.mode, }) : super(key: key);
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

  late FToast fToast;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  final _formKey = GlobalKey<FormState>();

  Duration duration_resttime = Duration(minutes: 0, seconds: 0);
  Duration duration_exercicetime = Duration(minutes: 0, seconds: 0);

  final exercice = Exercice();
  final _exerciceService = ExerciceService();

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(1, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    return "$twoDigitMinutes min $twoDigitSeconds s";
  }

  convert_duration_time(Duration durationRest, Duration durationExercice) {
    var minuteRest = durationRest.inMinutes.remainder(60);
    var secondRest = durationRest.inSeconds.remainder(60);
    var minuteExercice = durationExercice.inMinutes.remainder(60);
    var secondExercice = durationExercice.inSeconds.remainder(60);

    _exerciceTime = minuteExercice * 60 + secondExercice;
    _restTime = minuteRest * 60 + secondRest;
  }

  _showToast(_text) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: AppTheme.colors.secondaryColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'BalooBhai2',
            ),
          ),
        ],
      ),
    );
    // Custom Toast Position
    fToast.showToast(
        child: toast,
        toastDuration: Duration(seconds: 2),
        positionedToastBuilder: (context, child) {
          return Stack(alignment: Alignment.centerRight, children: <Widget>[
            Positioned.fill(
                top: MediaQuery.of(context).size.height * 0.75, child: child)
          ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        unselectedWidgetColor: AppTheme.colors.secondaryColor,
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(secondary: AppTheme.colors.secondaryColor));

    return Scaffold(
      backgroundColor: AppTheme.colors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 100,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
            ),
            color: AppTheme.colors.secondaryColor,
            iconSize: 40,
            onPressed: () => Navigator.pop(context)
            // 2
            ),
        backgroundColor: Colors.transparent,
        title: Text(
          'Add exercice',
          style: TextStyle(
            color: AppTheme.colors.secondaryColor,
            fontSize: 30,
            fontFamily: 'BalooBhai',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.check),
              color: AppTheme.colors.primaryColor,
              iconSize: 50,
              onPressed: () async {
                convert_duration_time(duration_resttime, duration_exercicetime);
                if (widget.mode == "rep") {
                  _exerciceTime = 1;
                } else {
                  _repNumber = 1;
                }

                if (_formKey.currentState!.validate() &&
                    _serieNumber != 0 &&
                    _repNumber != 0 &&
                    _restTime != 0 &&
                    _exerciceTime != 0) {
                  final _exercice = Exercice();
                  _exercice.name = _exerciceNameController.text;
                  _exercice.repetition = _repNumber;
                  _exercice.serie = _serieNumber;
                  _exercice.resttime = _restTime;
                  _exercice.exercicetime = _exerciceTime;
                  _exercice.mode = widget.mode;
                  _exercice.color = _color.value;

                  await _exerciceService.saveExercice(_exercice);
                  _showToast("Exercice created");
                  Navigator.pop(context);
                } else {
                  fToast.removeQueuedCustomToasts();
                  _showToast("Empty value");
                }
              }
              // 2
              ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Form(
              key: _formKey,
              child: Column(children: <Widget>[
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '';
                    }
                    return null;
                  },
                  style: TextStyle(
                    color: AppTheme.colors.secondaryColor,
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
                    Theme(
                      data: theme,
                      child: ExpansionTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Number of serie",
                              style: TextStyle(
                                color: AppTheme.colors.secondaryColor,
                                fontSize: 20,
                                fontFamily: 'BalooBhai',
                              ),
                            ),
                            Text(
                              _serieNumber.toString(),
                              style: TextStyle(
                                  color: AppTheme.colors.cyanColor,
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
                                    color: AppTheme.colors.cyanColor,
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
                    Theme(
                      data: theme,
                      child: ExpansionTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.mode == "rep"
                                  ? "Number of repetition"
                                  : "Exercice time",
                              style: TextStyle(
                                color: AppTheme.colors.secondaryColor,
                                fontSize: 20,
                                fontFamily: 'BalooBhai',
                              ),
                            ),
                            Text(
                              widget.mode == "rep"
                                  ? _repNumber.toString()
                                  : _printDuration(duration_exercicetime),
                              style: TextStyle(
                                  color: AppTheme.colors.redColor,
                                  fontSize: 25,
                                  fontFamily: 'BalooBhai2',
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        children: [
                          SizedBox(
                            height: widget.mode == "rep" ? 70 : 200,
                            child: ListTile(
                              title: widget.mode == "rep"
                                  ? NumberPicker(
                                      selectedTextStyle: TextStyle(
                                          color: AppTheme.colors.redColor,
                                          fontSize: 30,
                                          fontFamily: "BalooBhai2",
                                          fontWeight: FontWeight.w600),
                                      axis: Axis.horizontal,
                                      value: _repNumber,
                                      minValue: 0,
                                      maxValue: 20,
                                      onChanged: (value) =>
                                          setState(() => _repNumber = value),
                                    )
                                  : CupertinoTimerPicker(
                                      initialTimerDuration:
                                          duration_exercicetime,
                                      mode: CupertinoTimerPickerMode.ms,
                                      onTimerDurationChanged: (duration) =>
                                          setState(() {
                                        duration_exercicetime = duration;
                                      }),
                                    ),
                            ),
                          ),
                        ],
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
                    Theme(
                      data: theme,
                      child: ExpansionTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Rest time",
                              style: TextStyle(
                                color: AppTheme.colors.secondaryColor,
                                fontSize: 20,
                                fontFamily: 'BalooBhai',
                              ),
                            ),
                            Text(
                              _printDuration(duration_resttime),
                              style: TextStyle(
                                  color: AppTheme.colors.orangeColor,
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
                                onTimerDurationChanged: (duration) =>
                                    setState(() {
                                  duration_resttime = duration;
                                }),
                              ),
                            ),
                          ),
                        ],
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
                    Theme(
                      data: theme,
                      child: ExpansionTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Select color",
                              style: TextStyle(
                                color: AppTheme.colors.secondaryColor,
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
                                      AppTheme.colors.redColor,
                                      AppTheme.colors.cyanColor,
                                      AppTheme.colors.orangeColor,
                                      AppTheme.colors.blueColor,
                                      Colors.blue
                                    ],
                                    initialColor: Colors.blue)),
                          ),
                        ],
                      ),
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
        ),
      ),
    );
  }
}
