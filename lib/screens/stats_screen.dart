import 'dart:collection';

import 'package:sport_timer/models/events.dart';
import 'package:flutter/material.dart';
import 'package:sport_timer/presentation/app_theme.dart';
import 'package:sport_timer/presentation/icons.dart';
import 'package:sport_timer/services/event_service.dart';
import 'package:table_calendar/table_calendar.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<Event> _eventList = <Event>[];
  final _eventService = EventService();

  late Map<DateTime, List<Event>> selectedEvents;
  CalendarFormat format = CalendarFormat.month;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  final Map<DateTime, List<Event>> _events = LinkedHashMap(
    equals: isSameDay,
  );

  List<Event> _getEventsFromDay(DateTime date) {
    return _events[date] ?? [];
  }

  void addEvent(DateTime day, Event newEvent) {
    if (_events[day] != null) {
      _events[day]?.add(newEvent);
    } else {
      _events[day] = [newEvent];
    }
  }

  @override
  void initState() {
    /*_events[DateTime.utc(2022, 3, 12)] = [Event(name: 'Do Tasks',)];
    _events[DateTime.utc(2022, 3, 12)] = [Event(name: 'Do Tasks 1')];*/

    super.initState();
    getAllEvents();
    selectedDay = focusedDay;
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

        var date = DateTime.fromMillisecondsSinceEpoch(eventModel.datetime!);
        var goodformat = new DateTime(date.year, date.month, date.day);

        addEvent(goodformat, eventModel);

        //_eventList.add(eventModel);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TableCalendar(
            focusedDay: selectedDay,
            firstDay: DateTime(1990),
            lastDay: DateTime(2050),
            calendarFormat: format,
            onFormatChanged: (CalendarFormat _format) {
              setState(() {
                format = _format;
              });
            },
            startingDayOfWeek: StartingDayOfWeek.sunday,
            daysOfWeekVisible: true,
            onPageChanged: (focusedDay) {
              focusedDay = focusedDay;
            },

            //Day Changed
            onDaySelected: (DateTime selectDay, DateTime focusDay) {
              setState(() {
                selectedDay = selectDay;
                focusedDay = focusDay;
              });
            },
            selectedDayPredicate: (DateTime date) {
              return isSameDay(selectedDay, date);
            },

            eventLoader: _getEventsFromDay,

            //To style the Calendar
            calendarStyle: CalendarStyle(
              isTodayHighlighted: true,
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
              selectedTextStyle: TextStyle(color: Colors.white),
              todayDecoration: BoxDecoration(
                color: Colors.purpleAccent,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
              defaultDecoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
              weekendDecoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(5.0),
              ),
              formatButtonTextStyle: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          /* ..._getEventsFromDay(selectedDay)
              .map((Event event) => cardExercice(event)),*/
          Expanded(
            child: ListView.builder(
                itemCount: _getEventsFromDay(selectedDay).length,
                itemBuilder: (context, index) {
                  return cardExercice(_getEventsFromDay(selectedDay)[index]);
                }),
          )
        ],
      ),
    );
  }
}

String formatDuration(int totalSeconds) {
  final duration = Duration(seconds: totalSeconds);
  final minutes = duration.inMinutes;
  final seconds = totalSeconds % 60;

  final minutesString = '$minutes'.padLeft(1, '0');
  final secondsString = '$seconds'.padLeft(2, '0');
  return '$minutesString m $secondsString s';
}

String datesecondToMinuteHour(int dateSecond) {
  var date = DateTime.fromMillisecondsSinceEpoch(dateSecond).toLocal();
  var hour = date.hour;
  var minute = date.minute;

  return '$hour h $minute m';
}

Widget cardExercice(event) {
  return Card(
    margin: EdgeInsets.fromLTRB(30, 20, 30, 0),
    color: AppTheme.colors.redColor,
    elevation: 2.0,
    shape: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.transparent)),
    child: ExpansionTile(
      leading: Icon(
        MyFlutterApp.noun_time,
        color: Colors.white,
        size: 20,
      ),
      title: Row(
        children: [
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
          SizedBox(
            width: 50,
          ),
          Text(
            "rr",
            //datesecondToMinuteHour(event.datetime),
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
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "gf",
                    //formatDuration(event.totaltime),
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
