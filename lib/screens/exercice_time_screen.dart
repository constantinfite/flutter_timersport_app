import 'package:flutter/material.dart';
import 'package:sport_timer/screens/home_screen.dart';
import 'package:sport_timer/models/exercice.dart';
import 'package:sport_timer/services/exercice_service.dart';

class ExerciceTimeScreen extends StatefulWidget {
  const ExerciceTimeScreen({Key? key}) : super(key: key);

  @override
  State<ExerciceTimeScreen> createState() => _ExerciceTimeScreenState();
}

class _ExerciceTimeScreenState extends State<ExerciceTimeScreen> {
  double value = 0;
  final double min = 0;
  final double max = 20;
  final primaryColor = Color.fromARGB(255, 255, 95, 77);
  final secondaryColor = Color.fromARGB(255, 60, 60, 60);
  final backgroundColor = Color.fromARGB(255, 241, 241, 241);

  final _exerciceNameController = TextEditingController();

  final _exercice = Exercice();
  final _exerciceService = ExerciceService();

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
          'Add exercice',
          style: TextStyle(color: secondaryColor),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.check),
              color: primaryColor,
              onPressed: () async {
                _exercice.name = _exerciceNameController.text;

                var result = await _exerciceService.saveExercice(_exercice);
                print(result);
              }
              // 2
              ),
          IconButton(
              icon: const Icon(Icons.clear),
              color: secondaryColor,
              onPressed: () => Navigator.pop(context)
              // 2
              ),
        ],
        actionsIconTheme: IconThemeData(color: primaryColor, size: 36),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 250,
                child: TextField(
                  controller: _exerciceNameController,
                  decoration: InputDecoration(
                    hintText: 'Planche',
                    helperText: 'Enter exercice name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 50),
              Text("Choice number of serie"),
              SizedBox(height: 10),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      buildSideLabel(min),
                      Expanded(
                          child: Slider(
                              value: value,
                              min: 0,
                              max: 20,
                              divisions: 20,
                              activeColor: primaryColor,
                              inactiveColor: Colors.grey,
                              label: value.round().toString(),
                              onChanged: (value) => setState(() {
                                    this.value = value;
                                  }))),
                      buildSideLabel(max),
                    ],
                  )),
            ]),
      ),
    );
  }

  Widget buildSideLabel(double value) => Text(value.round().toString(),
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
}
