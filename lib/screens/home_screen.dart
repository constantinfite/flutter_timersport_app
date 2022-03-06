import 'package:flutter/material.dart';
import 'package:sport_timer/presentation/icons.dart';
import 'package:sport_timer/screens/exercice_screen.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:sport_timer/models/exercice.dart';
import 'package:sport_timer/services/exercice_service.dart';
import 'package:sport_timer/screens/exercice_screen_update.dart';
import 'package:sport_timer/screens/serie_workout_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final primaryColor = Color.fromARGB(255, 255, 95, 77);
  final secondaryColor = Color.fromARGB(255, 60, 60, 60);
  final backgroundColor = Color.fromARGB(255, 241, 241, 241);
  final blueColor = Color.fromARGB(255, 173, 200, 243);
  final cyanColor = Color.fromARGB(255, 87, 203, 214);
  final orangeColor = Color.fromARGB(255, 254, 143, 63);
  final redColor = Color.fromARGB(255, 251, 80, 97);

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
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        toolbarHeight: 100,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "EXERCICES",
          style: TextStyle(
            color: secondaryColor,
            fontSize: 40,
            fontFamily: 'BalooBhai',
          ),
        ),
        centerTitle: true,
        actions: [
          Icon(Icons.more_vert),
        ],
        actionsIconTheme: IconThemeData(
          color: secondaryColor,
          size: 36,
        ),
      ),
      body: ListView.builder(
          itemCount: _exerciceList.length,
          itemBuilder: (context, index) {
            // remove slider when expanded
            final theme = Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                unselectedWidgetColor: secondaryColor,
                colorScheme: ColorScheme.fromSwatch()
                    .copyWith(secondary: secondaryColor));
            return Card(
              color: blueColor,
              child: Column(children: [
                Theme(
                  data: theme,
                  child: ExpansionTile(
                    title: Text(
                      _exerciceList[index].name.toString(),
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "BalooBhai",
                          fontSize: 30),
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
                                ? _exerciceList[index]
                                    .exercicetime!
                                    .toInt()
                                    .toString()
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
                            _exerciceList[index].resttime!.toInt().toString(),
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
                                primary: secondaryColor,
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
                                onPrimary: blueColor,
                                primary: Colors.white,
                                textStyle: TextStyle(
                                    color: blueColor,
                                    fontFamily: "BalooBhai",
                                    fontSize: 30),
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
      //drawer: const DrawerNavigation(),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: redColor,
        spacing: 15,
        spaceBetweenChildren: 10,
        children: [
          SpeedDialChild(
            child: Icon(MyFlutterApp.noun_number),
            backgroundColor: redColor,
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
            backgroundColor: redColor,
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(MyFlutterApp.noun_list),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(MyFlutterApp.noun_stat),
            label: 'Stats',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
