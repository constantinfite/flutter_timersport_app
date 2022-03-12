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
  List<Event> _selectedEvents = <Event>[];

  final List<Event> _eventList = <Event>[];
  final _eventService = EventService();

  CalendarFormat format = CalendarFormat.month;

  DateTime _focusedDay = DateTime.now().toUtc();
  DateTime? _selectedDay;

  Map<DateTime, List<Event>> _events = LinkedHashMap(
    equals: isSameDay,
  );

  List<Event> _getEventsFromDay(DateTime date) {
    if (date == _selectedDay) {
      print(_events[date]);
    }
    return _events[date] ?? [];
  }

  @override
  void initState() {
    /*_events[DateTime.utc(2022, 3, 12)] = [Event(name: 'Do Tasks',)];
    _events[DateTime.utc(2022, 3, 12)] = [Event(name: 'Do Tasks 1')];*/

    super.initState();

    _selectedDay = _focusedDay;

    getTask1().then((val) => setState(() {
          _events = val;

          var _correctDate = DateTime.utc(
              _selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
          _selectedEvents = _getEventsFromDay(_correctDate);
        }));
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<Event>> getAllEvents() async {
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

    return _eventList;
  }

  Future<Map<DateTime, List<Event>>> getTask1() async {
    Map<DateTime, List<Event>> mapFetch = {};
    List<Event> event = await getAllEvents();
    for (int i = 0; i < event.length; i++) {
      var date = DateTime.fromMillisecondsSinceEpoch(event[i].datetime!);
      var createTime = DateTime(date.year, date.month, date.day).toUtc();

      var original = mapFetch[createTime];

      if (original == null) {
        //print("null");
        mapFetch[createTime] = [event[i]];
      } else {
        //print(event[i]);
        mapFetch[createTime] = List.from(original)..addAll([event[i]]);
      }
    }
    //print(mapFetch);
    return mapFetch;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedEvents = _getEventsFromDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _selectedDay!,
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
            onDaySelected: _onDaySelected,
            selectedDayPredicate: (DateTime date) {
              return isSameDay(_selectedDay, date);
            },

            eventLoader: (day) {
              return _getEventsFromDay(day);
            },

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
                  itemCount: _selectedEvents.length,
                  itemBuilder: (context, index) {
                    return cardExercice(_selectedEvents[index]);
                  }))
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
