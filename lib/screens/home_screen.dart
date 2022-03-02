import 'package:flutter/material.dart';
import 'package:sport_timer/screens/exercice_time_screen.dart';
import 'package:sport_timer/models/exercice.dart';
import 'package:sport_timer/services/exercice_service.dart';

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
    getAllExercice();
  }

  getAllExercice() async {
    _exerciceList = <Exercice>[];
    var exercices = await _exerciceService.readExercices();
    exercices.forEach((exercice) {
      setState(() {
        var exerciceModel = Exercice();
        exerciceModel.name = exercice['name'];
        exerciceModel.id = exercice['id'];
        _exerciceList.add(exerciceModel);
      });
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
                        color: primaryColor),
                    title: Row(
                      children: <Widget>[
                        Text(_exerciceList[index].name!),
                      ],
                    ),
                    subtitle: Text('2*10 Rest 01:30'),
                    trailing: Wrap(
                      spacing: 8,
                      children: <Widget>[
                        IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.play_circle),
                            color: primaryColor),
                        IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.edit),
                            color: primaryColor)
                      ],
                    ),
                  )
                ],
              ),
              margin: EdgeInsets.fromLTRB(30, 20, 30, 0),
              shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: BorderSide(color: Colors.white)),
            );
          }),
      //drawer: const DrawerNavigation(),
      floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ExerciceTimeScreen())),
          child: const Icon(Icons.add),
          backgroundColor: primaryColor),
    );
  }
}
