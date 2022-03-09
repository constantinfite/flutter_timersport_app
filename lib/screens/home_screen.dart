import 'package:flutter/material.dart';
import 'package:sport_timer/presentation/icons.dart';
import 'package:sport_timer/models/exercice.dart';
import 'package:sport_timer/services/exercice_service.dart';
import 'package:sport_timer/screens/list_exercice_screen.dart';
import 'package:sport_timer/screens/stats_screen.dart';
import 'package:sport_timer/presentation/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> screens = [ListExerciceScreen(), StatsScreen()];

  List<Exercice> _exerciceList = <Exercice>[];
  final _exerciceService = ExerciceService();

  String _title = "EXERCICES";

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        {
          _title = 'EXERCICES';
        }
        break;
      case 1:
        {
          _title = 'STATS';
        }
        break;
    }
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
      backgroundColor: AppTheme.colors.redColor,
      appBar: AppBar(
        toolbarHeight: 100,
        elevation: 0,
        backgroundColor: AppTheme.colors.backgroundColor,
        title: Text(
          _title,
          style: TextStyle(
            color: AppTheme.colors.secondaryColor,
            fontSize: 35,
            fontFamily: 'BalooBhai',
          ),
        ),
        centerTitle: true,
        actions: [
          Icon(Icons.more_vert),
        ],
        actionsIconTheme: IconThemeData(
          color: AppTheme.colors.secondaryColor,
          size: 36,
        ),
      ),
      body: screens[_selectedIndex],
      //drawer: const DrawerNavigation(),

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
        currentIndex: _selectedIndex,
        selectedItemColor: AppTheme.colors.redColor,
        onTap: (int index) {
          _onItemTapped(index);
        },
      ),
    );
  }
}
