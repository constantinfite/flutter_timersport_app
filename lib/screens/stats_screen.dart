import 'dart:collection';
import 'dart:convert';
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

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<Event>> _events = LinkedHashMap(
    equals: isSameDay,
  );

  List<Event> _getEventsFromDay(DateTime date) {
    return _events[date] ?? [];
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    getTask1().then((val) => setState(() {
          _events = val;
          print(_events);
          var _correctDate = DateTime.utc(
              _selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
          print(_correctDate);

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
        eventModel.id = event['id'];
        eventModel.name = event['name'];
        eventModel.description = event['description'];
        eventModel.mode = event['mode'];
        eventModel.resttime = event['resttime'];
        eventModel.arrayrepetition = event['arrayrepetition'];
        eventModel.serie = event['serie'];
        eventModel.exercicetime = event['exercicetime'];
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
      var createTime = DateTime.utc(date.year, date.month, date.day);

      var original = mapFetch[createTime];

      if (original == null) {
        //print("null");
        mapFetch[createTime] = [event[i]];
      } else {
        //print(event[i]);
        mapFetch[createTime] = List.from(original)..addAll([event[i]]);
      }
    }
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

String decodeJsonToText(event) {
  var serie = jsonDecode(event);
  String text = "";
  for (var i = 0; i < serie.length; i++) {
    if (i < serie.length) {
      text = text + serie[i].toString() + "-";
    } else {
      text = text + serie[i].toString();
    }
  }
  return text;
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
        event.mode == "timer"
            ? MyFlutterApp.noun_time
            : MyFlutterApp.noun_workout,
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
            datesecondToMinuteHour(event.datetime),
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
                    event.mode == "timer"
                        ? event.serie.toString() +
                            " x " +
                            formatDuration(event.exercicetime)
                        : decodeJsonToText(event.arrayrepetition),
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
                    formatDuration(event.totaltime),
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
              event.description,
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
