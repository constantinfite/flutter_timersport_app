import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sport_timer/models/exercice.dart';
import 'package:sport_timer/presentation/app_theme.dart';
import 'package:sport_timer/services/exercice_service.dart';
import 'package:sport_timer/widget/my_color_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sport_timer/utils.dart';

class ExerciceTimeScreen extends StatefulWidget {
  const ExerciceTimeScreen(
      {Key? key,
      required this.mode,
      required this.creation,
      required this.exercice})
      : super(key: key);
  final String mode;
  final bool creation;
  final Exercice exercice;
  @override
  State<ExerciceTimeScreen> createState() => _ExerciceTimeScreenState();
}

class _ExerciceTimeScreenState extends State<ExerciceTimeScreen> {
  int id = 0;
  final _exerciceNameController = TextEditingController();
  int _serieNumber = 0;
  int _repNumber = 0;
  int _restTime = 0;
  int _exerciceTime = 0;
  int _preparationTime = 0;
  Color _color = Colors.blue;

  late FToast fToast;
  final listNumber = List<String>.generate(21, (i) => "$i");
  final _formKey = GlobalKey<FormState>();

  Duration durationRestTime = Duration(minutes: 0, seconds: 0);
  Duration durationExerciceTime = Duration(minutes: 0, seconds: 0);
  Duration durationPreparationTime = Duration(minutes: 0, seconds: 0);

  final exercice = Exercice();
  final _exerciceService = ExerciceService();

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);

    if (!widget.creation) {
      editValue();
    }
  }

  editValue() async {
    setState(() {
      id = widget.exercice.id!;
      _exerciceNameController.text = widget.exercice.name!;
      _serieNumber = widget.exercice.serie!;
      _repNumber = widget.exercice.repetition!;
      _color = Color(widget.exercice.color!);

      durationRestTime = Duration(
          minutes: widget.exercice.resttime! ~/ 60,
          seconds: widget.exercice.resttime! % 60);
      durationExerciceTime = Duration(
          minutes: widget.exercice.exercicetime! ~/ 60,
          seconds: widget.exercice.exercicetime! % 60);
      durationPreparationTime = Duration(
          minutes: widget.exercice.exercicetime! ~/ 60,
          seconds: widget.exercice.exercicetime! % 60);
    });
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(1, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    return "$twoDigitMinutes min $twoDigitSeconds s";
  }

  convertDurationToTime(Duration durationRest, Duration durationExercice,
      Duration durationPreparation) {
    var minuteRest = durationRest.inMinutes.remainder(60);
    var secondRest = durationRest.inSeconds.remainder(60);
    var minuteExercice = durationExercice.inMinutes.remainder(60);
    var secondExercice = durationExercice.inSeconds.remainder(60);
    var minutePreparation = durationPreparation.inMinutes.remainder(60);
    var secondPreparation = durationPreparation.inSeconds.remainder(60);

    _exerciceTime = minuteExercice * 60 + secondExercice;
    _restTime = minuteRest * 60 + secondRest;
    _preparationTime = minutePreparation * 60 + secondPreparation;
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

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return '$minutes:$seconds';
  }

  choiceAction(String choice) async {
    if (choice == "delete") {
      await _exerciceService.deleteExercice(id);
      Navigator.pop(context);
      _showToast("Exercice delete");
    }
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
                // creation of exercice
                if (widget.creation) {
                  convertDurationToTime(durationRestTime, durationExerciceTime,
                      durationPreparationTime);
                  if (widget.mode == "rep") {
                    _exerciceTime = 1;
                    _preparationTime = 1;
                  } else {
                    _repNumber = 1;
                  }

                  if (_formKey.currentState!.validate() &&
                          _serieNumber != 0 &&
                          _repNumber != 0 &&
                          _restTime != 0 &&
                          _exerciceTime != 0
                      //&& _preparationTime != 0
                      ) {
                    final _exercice = Exercice();
                    _exercice.name = _exerciceNameController.text;
                    _exercice.repetition = _repNumber;
                    _exercice.serie = _serieNumber;
                    _exercice.resttime = _restTime;
                    _exercice.exercicetime = _exerciceTime;
                    _exercice.preparationtime = _preparationTime;
                    _exercice.mode = widget.mode;
                    _exercice.color = _color.value;

                    await _exerciceService.saveExercice(_exercice);
                    _showToast("Exercice created");
                    Navigator.pop(context);
                  } else {
                    fToast.removeQueuedCustomToasts();
                    _showToast("Empty value");
                  }
                  // modification of exercice
                } else {
                  convertDurationToTime(durationRestTime, durationExerciceTime,
                      durationPreparationTime);

                  if (_formKey.currentState!.validate() &&
                          _serieNumber != 0 &&
                          _repNumber != 0 &&
                          _restTime != 0 &&
                          _exerciceTime != 0
                      //&& _preparationTime != 0
                      ) {
                    final _exercice = Exercice();
                    _exercice.id = id;
                    _exercice.name = _exerciceNameController.text;
                    _exercice.repetition = _repNumber;
                    _exercice.serie = _serieNumber;
                    _exercice.resttime = _restTime;
                    _exercice.exercicetime = _exerciceTime;
                    _exercice.color = _color.value;
                    _exercice.preparationtime = _preparationTime;
                    _exercice.mode = widget.exercice.mode;

                    await _exerciceService.updateExercice(_exercice);
                    Navigator.pop(context);
                    _showToast("Exercice modified");
                  } else {
                    _showToast("Empty value");
                  }
                }
              }
              // 2
              ),
          Visibility(
            visible: !widget.creation,
            child: PopupMenuButton(
                icon: Icon(
                  Icons.more_vert,
                  size: 40,
                  color: AppTheme.colors.secondaryColor,
                ),
                itemBuilder: (_) => const <PopupMenuItem<String>>[
                      PopupMenuItem<String>(
                          child: Text('Delete'), value: 'delete'),
                    ],
                onSelected: choiceAction),
          )
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
                GestureDetector(
                  onTap: () {
                    Utils.showSheet(context,
                        child: buildSeriePicker(),
                        onClicked: () => {Navigator.pop(context)});
                  },
                  child: Card(
                    color: Colors.white,
                    child: Column(children: [
                      ListTile(
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
                      ),
                    ]),
                    shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.transparent)),
                    elevation: 2,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                    onTap: () {
                      Utils.showSheet(context,
                          child: widget.mode == "rep"
                              ? buildRepPicker()
                              : buildExerciceTimePicker(),
                          onClicked: () => {Navigator.pop(context)});
                    },
                    child: Card(
                      color: Colors.white,
                      child: ListTile(
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
                                  : _printDuration(durationExerciceTime),
                              style: TextStyle(
                                  color: AppTheme.colors.redColor,
                                  fontSize: 25,
                                  fontFamily: 'BalooBhai2',
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      shape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.transparent)),
                      elevation: 2,
                    )),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                    onTap: () {
                      Utils.showSheet(context,
                          child: buildRestTimePicker(),
                          onClicked: () => {Navigator.pop(context)});
                    },
                    child: Card(
                      color: Colors.white,
                      child: ListTile(
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
                              _printDuration(durationRestTime),
                              style: TextStyle(
                                  color: AppTheme.colors.orangeColor,
                                  fontSize: 25,
                                  fontFamily: 'BalooBhai2',
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      shape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.transparent)),
                      elevation: 2,
                    )),
                SizedBox(
                  height: 20,
                ),
                /*
                Visibility(
                  visible: widget.mode == "timer",
                  child: Column(
                    children: [
                      GestureDetector(
                          onTap: () {
                            Utils.showSheet(context,
                                child: buildPreparationTimePicker(),
                                onClicked: () => {Navigator.pop(context)});
                          },
                          child: Card(
                            color: Colors.white,
                            child: ListTile(
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Preparation time",
                                    style: TextStyle(
                                      color: AppTheme.colors.secondaryColor,
                                      fontSize: 20,
                                      fontFamily: 'BalooBhai',
                                    ),
                                  ),
                                  Text(
                                    _printDuration(durationPreparationTime),
                                    style: TextStyle(
                                        color: AppTheme.colors.blueColor,
                                        fontSize: 25,
                                        fontFamily: 'BalooBhai2',
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                            shape: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide:
                                    BorderSide(color: Colors.transparent)),
                            elevation: 2,
                          )),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),*/
                Card(
                  color: Colors.white,
                  child: Column(children: [
                    ListTile(
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
                        ],
                      ),
                    ),
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
                              initialColor: _color)),
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

  Widget buildSeriePicker() => SizedBox(
        height: 300,
        child: CupertinoPicker(
          scrollController:
              FixedExtentScrollController(initialItem: _serieNumber),
          itemExtent: 64,
          diameterRatio: 0.7,
          looping: true,
          onSelectedItemChanged: (index) =>
              setState(() => _serieNumber = index),
          // selectionOverlay: Container(),
          selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
            background: AppTheme.colors.cyanColor.withOpacity(0.12),
          ),
          children: Utils.modelBuilder<String>(
            listNumber,
            (index, value) {
              final isSelected = index == index;
              final color =
                  isSelected ? AppTheme.colors.cyanColor : Colors.black;

              return Center(
                child: Text(
                  value,
                  style: TextStyle(color: color, fontSize: 24),
                ),
              );
            },
          ),
        ),
      );

  Widget buildRepPicker() => SizedBox(
        height: 300,
        child: CupertinoPicker(
          scrollController:
              FixedExtentScrollController(initialItem: _repNumber),
          itemExtent: 64,
          diameterRatio: 0.7,
          looping: true,
          onSelectedItemChanged: (index) => setState(() => _repNumber = index),
          // selectionOverlay: Container(),
          selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
            background: AppTheme.colors.redColor.withOpacity(0.12),
          ),
          children: Utils.modelBuilder<String>(
            listNumber,
            (index, value) {
              final isSelected = index == index;
              final color =
                  isSelected ? AppTheme.colors.redColor : Colors.black;

              return Center(
                child: Text(
                  value,
                  style: TextStyle(color: color, fontSize: 24),
                ),
              );
            },
          ),
        ),
      );

  Widget buildExerciceTimePicker() => SizedBox(
        height: 180,
        child: CupertinoTimerPicker(
          initialTimerDuration: durationExerciceTime,
          mode: CupertinoTimerPickerMode.ms,
          minuteInterval: 1,
          secondInterval: 1,
          onTimerDurationChanged: (duration) =>
              setState(() => durationExerciceTime = duration),
        ),
      );

  Widget buildRestTimePicker() => SizedBox(
        height: 180,
        child: CupertinoTimerPicker(
          initialTimerDuration: durationRestTime,
          mode: CupertinoTimerPickerMode.ms,
          minuteInterval: 1,
          secondInterval: 1,
          onTimerDurationChanged: (duration) =>
              setState(() => durationRestTime = duration),
        ),
      );

  Widget buildPreparationTimePicker() => SizedBox(
        height: 180,
        child: CupertinoTimerPicker(
          initialTimerDuration: durationPreparationTime,
          mode: CupertinoTimerPickerMode.ms,
          minuteInterval: 1,
          secondInterval: 1,
          onTimerDurationChanged: (duration) =>
              setState(() => durationPreparationTime = duration),
        ),
      );
}
