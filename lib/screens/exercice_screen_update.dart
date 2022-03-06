import 'package:flutter/material.dart';
import 'package:sport_timer/models/exercice.dart';
import 'package:sport_timer/services/exercice_service.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:flutter_conditional_rendering/flutter_conditional_rendering.dart';

class ExerciceTimeScreenUpdate extends StatefulWidget {
  const ExerciceTimeScreenUpdate({Key? key, required this.exercice})
      : super(key: key);

  // Declare a field that holds the Todo.
  final Exercice exercice;

  @override
  State<ExerciceTimeScreenUpdate> createState() =>
      ExerciceTimeScreenUpdateState();
}

class ExerciceTimeScreenUpdateState extends State<ExerciceTimeScreenUpdate> {
  final _exerciceNameController = TextEditingController();
  int _serieNumber = 0;
  int _repNumber = 0;
  int _restTime = 0;
  int _exerciceTime = 0;
  int id = 0;

  final primaryColor = Color.fromARGB(255, 255, 95, 77);
  final secondaryColor = Color.fromARGB(255, 60, 60, 60);
  final backgroundColor = Color.fromARGB(255, 241, 241, 241);

  final exercice = Exercice();
  final _exerciceService = ExerciceService();

  @override
  void initState() {
    super.initState();
    editValue();
    print(widget.exercice.mode);
  }

  editValue() async {
    setState(() {
      id = widget.exercice.id!;
      _exerciceNameController.text = widget.exercice.name!;
      _serieNumber = widget.exercice.serie!;
      _repNumber = widget.exercice.repetition!;
      _restTime = widget.exercice.resttime!;
      _exerciceTime = widget.exercice.exercicetime!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            color: primaryColor,
            onPressed: () => Navigator.pop(context)
            // 2
            ),
        backgroundColor: Colors.transparent,
        title: Text(
          'Edit exercice',
          style: TextStyle(color: secondaryColor),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.check),
              color: primaryColor,
              onPressed: () async {
                final _exercice = Exercice();
                _exercice.id = id;
                _exercice.name = _exerciceNameController.text;
                _exercice.repetition = _repNumber;
                _exercice.serie = _serieNumber;
                _exercice.resttime = _restTime;
                _exercice.exercicetime = _exerciceTime;

                await _exerciceService.updateExercice(_exercice);
                Navigator.pop(context);
              }
              // 2
              ),
          IconButton(
            icon: const Icon(Icons.clear),
            color: secondaryColor,
            onPressed: () => Navigator.pop(context),

            // 2
          ),
        ],
        actionsIconTheme: IconThemeData(color: primaryColor, size: 36),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 250,
                  child: TextField(
                    style: TextStyle(color: secondaryColor),
                    controller: _exerciceNameController,
                    decoration: InputDecoration(
                      hintText: 'Planche',
                      helperText: 'Enter exercice name',
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: secondaryColor,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                  ),
                ),
                SizedBox(height: 50),
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
                        widget.exercice.mode == "rep",
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
              ]),
        ),
      ),
    );
  }
}
