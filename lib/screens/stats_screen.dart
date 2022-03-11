import 'package:sport_timer/models/events.dart';
import 'package:flutter/material.dart';
import 'package:sport_timer/presentation/app_theme.dart';
import 'package:sport_timer/presentation/icons.dart';
import 'package:sport_timer/services/event_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  TextEditingController _eventController = TextEditingController();

  List<Event> _eventList = <Event>[];
  final _eventService = EventService();

  @override
  void initState() {
    super.initState();
    getAllEvents();
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  getAllEvents() async {
    var events = await _eventService.readEvents();
    events.forEach((event) {
      setState(() {
        var eventModel = Event();
        eventModel.name = event['name'];
        eventModel.id = event['id'];
        eventModel.resttime = event['resttime'];
        eventModel.totaltime = event['totaltime'];
        eventModel.datetime = event['datetime'];

        _eventList.add(eventModel);
      });
    });
    if (events.isEmpty) {
      setState(() {
        print("nothing");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: _eventList.length,
                itemBuilder: (context, index) {
                  return cardExercice(_eventList[index], index);
                }),
          )
        ],
      ),
    );
  }
}

Widget cardExercice(event, index) {
  return Card(
    margin: EdgeInsets.fromLTRB(30, 20, 30, 0),
    color: AppTheme.colors.redColor,
    elevation: 2.0,
    shape: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white)),
    child: ExpansionTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    MyFlutterApp.noun_workout,
                    color: Colors.white,
                    size: 20,
                  ),
                  Text(
                    event.name,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'BalooBhai',
                      color: Colors.white,
                    ),
                  ),
                ],
              )),
          Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    MyFlutterApp.noun_repetition,
                    color: Colors.white,
                    size: 20,
                  ),
                  Text(
                    "10-10-10-10-10",
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'BalooBhai',
                      color: Colors.white,
                    ),
                  ),
                ],
              )),
          Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    MyFlutterApp.noun_time,
                    color: Colors.white,
                    size: 20,
                  ),
                  Text(
                    DateTime.fromMillisecondsSinceEpoch(event.datetime)
                        .toString(),
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'BalooBhai',
                      color: Colors.white,
                    ),
                  ),
                ],
              )),
        ],
      ),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              MyFlutterApp.noun_time,
              color: Colors.white,
              size: 40,
            ),
            Text(
              "J’ai fait une bonne séance malgré le fit ",
              overflow: TextOverflow.fade,
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'BalooBhai',
                color: Colors.white,
              ),
            ),
          ],
        )
      ],
    ),
  );
}
