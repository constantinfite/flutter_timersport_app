import 'package:flutter/material.dart';
import 'package:sport_timer/presentation/icons.dart';
import 'package:sport_timer/screens/input_exercice_screen.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:sport_timer/models/exercice.dart';
import 'package:sport_timer/services/exercice_service.dart';
import 'package:sport_timer/screens/input_exercice_screen_update.dart';
import 'package:sport_timer/screens/serie_workout_screen.dart';
import 'package:sport_timer/presentation/app_theme.dart';

class ListExerciceScreen extends StatefulWidget {
  const ListExerciceScreen({Key? key}) : super(key: key);

  @override
  State<ListExerciceScreen> createState() => _ListExerciceScreenState();
}

class _ListExerciceScreenState extends State<ListExerciceScreen> {
  int _selectedIndex = 0;

  List<Exercice> _exerciceList = <Exercice>[];
  final _exerciceService = ExerciceService();

  @override
  void initState() {
    super.initState();
    getAllExercices();
  }

  late var _exercice = Exercice();

  var exercice;

  getAllExercices() async {
    _exerciceList = <Exercice>[];
    var exercices = await _exerciceService.readExercices();
    exercices.forEach((exercice) {
      setState(() {
        var exerciceModel = Exercice();
        exerciceModel.name = exercice['name'];
        exerciceModel.id = exercice['id'];
        exerciceModel.repetition = exercice['repetition'];
        exerciceModel.resttime = exercice['resttime'];
        exerciceModel.serie = exercice['serie'];
        exerciceModel.exercicetime = exercice['exercicetime'];
        exerciceModel.mode = exercice['mode'];
        exerciceModel.color = exercice['color'];
        _exerciceList.add(exerciceModel);
      });
    });
    if (exercices.isEmpty) {
      setState(() {
        print("nothing");
      });
    }
  }

  editExercice(BuildContext context, exerciceId) async {
    exercice = await _exerciceService.readExerciceById(exerciceId);
    setState(() {
      _exercice.id = exercice[0]['id'];
      _exercice.name = exercice[0]['name'] ?? 'No name';
      _exercice.repetition = exercice[0]['repetition'] ?? 0;
      _exercice.serie = exercice[0]['serie'] ?? 0;
      _exercice.resttime = exercice[0]['resttime'] ?? 0;
      _exercice.exercicetime = exercice[0]['exercicetime'] ?? 0;
      _exercice.mode = exercice[0]['mode'] ?? "";
      _exercice.color = exercice[0]['color'] ?? 0;
    });
  }

  String formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes;
    final seconds = totalSeconds % 60;

    final minutesString = '$minutes'.padLeft(1, '0');
    final secondsString = '$seconds'.padLeft(2, '0');
    return '$minutesString min $secondsString s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.backgroundColor,
      body: ListView.builder(
          itemCount: _exerciceList.length,
          itemBuilder: (context, index) {
            // remove slider when expanded
            final theme = Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                unselectedWidgetColor: AppTheme.colors.secondaryColor,
                colorScheme: ColorScheme.fromSwatch()
                    .copyWith(secondary: AppTheme.colors.secondaryColor));
            return Card(
              color: Color(_exerciceList[index].color!),
              child: Column(children: [
                Theme(
                  data: theme,
                  child: ExpansionTile(
                    title: Text(
                      _exerciceList[index].name.toString(),
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "BalooBhai",
                          fontSize: 25),
                    ),
                    leading: Icon(
                      _exerciceList[index].mode == "timer"
                          ? MyFlutterApp.noun_time
                          : MyFlutterApp.noun_number,
                      size: 50,
                      color: Colors.white,
                    ),
                    children: <Widget>[
                      SizedBox(
                        height: 30,
                        child: ListTile(
                          trailing: Text(
                            _exerciceList[index].serie!.toInt().toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: "BalooBhai2",
                                fontSize: 20),
                          ),
                          title: Text(
                            "Number of serie",
                            style: TextStyle(
                                fontFamily: "BalooBhai2",
                                fontSize: 20,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        child: ListTile(
                          trailing: Text(
                            _exerciceList[index].mode == "timer"
                                ? formatDuration(
                                    _exerciceList[index].exercicetime!)
                                : _exerciceList[index]
                                    .repetition!
                                    .toInt()
                                    .toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: "BalooBhai2",
                                fontSize: 20),
                          ),
                          title: Text(
                            _exerciceList[index].mode == "timer"
                                ? "Exercice time"
                                : "Number of repetition",
                            style: TextStyle(
                                fontFamily: "BalooBhai2",
                                fontSize: 20,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        child: ListTile(
                          trailing: Text(
                            formatDuration(_exerciceList[index].resttime!),
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: "BalooBhai2",
                                fontSize: 20),
                          ),
                          title: Text(
                            "Rest time ",
                            style: TextStyle(
                                fontFamily: "BalooBhai2",
                                fontSize: 20,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        height: 70,
                        child: ListTile(
                          leading: SizedBox(
                            width: 130,
                            child: ElevatedButton(
                              child: Text('Start'),
                              style: ElevatedButton.styleFrom(
                                elevation: 2,
                                primary: AppTheme.colors.secondaryColor,
                                textStyle: TextStyle(
                                    fontFamily: "BalooBhai", fontSize: 30),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side:
                                        BorderSide(color: Colors.transparent)),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => SerieWorkoutScreen(
                                        id: _exerciceList[index].id!)));
                              },
                            ),
                          ),
                          trailing: SizedBox(
                            width: 130,
                            child: ElevatedButton(
                              child: Text('Edit'),
                              style: ElevatedButton.styleFrom(
                                elevation: 2,
                                onPrimary: Color(_exerciceList[index].color!),
                                primary: Colors.white,
                                textStyle: TextStyle(
                                    fontFamily: "BalooBhai", fontSize: 30),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side:
                                        BorderSide(color: Colors.transparent)),
                              ),
                              onPressed: () {
                                editExercice(context, _exerciceList[index].id);
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (context) =>
                                            ExerciceTimeScreenUpdate(
                                                exercice: _exercice)))
                                    .then((_) {
                                  getAllExercices();
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ]),
              margin: EdgeInsets.fromLTRB(30, 20, 30, 0),
              shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.transparent)),
              elevation: 2,
            );
          }),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: AppTheme.colors.redColor,
        spacing: 15,
        spaceBetweenChildren: 10,
        children: [
          SpeedDialChild(
            child: Icon(MyFlutterApp.noun_number),
            backgroundColor: AppTheme.colors.redColor,
            label: 'Repetition',
            foregroundColor: Colors.white,
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (context) => ExerciceTimeScreen(mode: "rep")))
                .then((_) {
              getAllExercices();
            }),
          ),
          SpeedDialChild(
            child: Icon(MyFlutterApp.noun_time),
            backgroundColor: AppTheme.colors.redColor,
            label: 'Timer',
            foregroundColor: Colors.white,
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (context) => ExerciceTimeScreen(mode: "timer")))
                .then((_) {
              getAllExercices();
            }),
          )
        ],
      ),
    );
  }
}
