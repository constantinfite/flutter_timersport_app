import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sport_timer/screens/exercice_time_screen.dart';
import 'package:sport_timer/models/exercice.dart';
import 'package:sport_timer/services/exercice_service.dart';
import 'package:sport_timer/screens/exercice_time_screen_update.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final primaryColor = Color.fromARGB(255, 255, 95, 77);
  final secondaryColor = Color.fromARGB(255, 60, 60, 60);
  final backgroundColor = Color.fromARGB(255, 241, 241, 241);

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
        print("empty");
        exerciceModel.name = exercice['name'];
        exerciceModel.id = exercice['id'];
        exerciceModel.repetition = exercice['repetition'];
        exerciceModel.resttime = exercice['resttime'];
        exerciceModel.serie = exercice['serie'];
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Exercice's list",
          style: TextStyle(color: secondaryColor),
        ),
        centerTitle: true,
        actions: [
          Icon(Icons.more_vert),
        ],
        actionsIconTheme: IconThemeData(color: primaryColor, size: 36),
      ),
      body: ListView.builder(
          itemCount: _exerciceList.length,
          itemBuilder: (context, index) {
            return Card(
              child: Column(
                children: [
                  ListTile(
                    leading: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.timer_sharp),
                      color: primaryColor,
                      iconSize: 35,
                    ),
                    title: Row(
                      children: <Widget>[
                        Text(_exerciceList[index].name!),
                      ],
                    ),
                    subtitle: Text(_exerciceList[index].repetition.toString() +
                        " rep * " +
                        _exerciceList[index].serie.toString() +
                        " series "),
                    trailing: Wrap(
                      spacing: 8,
                      children: <Widget>[
                        IconButton(
                          onPressed: () async {
                            var result = await _exerciceService
                                .deleteExercice(_exerciceList[index].id);

                            if (result > 0) {
                              //await Future.delayed(Duration(seconds: 1));
                              getAllExercices();
                            }
                          },
                          //Icons.play_circle_outline_rounded
                          icon: Icon(Icons.delete_outline),
                          color: primaryColor,
                          iconSize: 30,
                        ),
                        IconButton(
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
                          icon: Icon(Icons.mode_edit_outline_outlined),
                          color: primaryColor,
                          iconSize: 30,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              margin: EdgeInsets.fromLTRB(30, 20, 30, 0),
              shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: BorderSide(color: Colors.white)),
              elevation: 2,
            );
          }),
      //drawer: const DrawerNavigation(),
      floatingActionButton: FloatingActionButton(
          onPressed: () => {
                setState(() {
                  _exercice.name = "";
                  _exercice.repetition = 0;
                  _exercice.serie = 0;
                  _exercice.resttime = 0;
                }),
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) => ExerciceTimeScreen()))
                    .then((_) {
                  getAllExercices();
                })
              },
          child: Icon(
            Icons.add,
            size: 35,
            color: backgroundColor,
          ),
          backgroundColor: primaryColor),
    );
  }
}