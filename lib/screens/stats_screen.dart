import 'dart:collection';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:sport_timer/main.dart';
import 'package:sport_timer/models/events.dart';
import 'package:sport_timer/presentation/app_theme.dart';
import 'package:sport_timer/presentation/icons.dart';
import 'package:sport_timer/services/event_service.dart';
import 'package:sport_timer/src/app.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:developer';

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
      var createDate = DateTime.utc(date.year, date.month, date.day);
      /*print("createDate");
      print(createDate);*/

      var original = mapFetch[createDate];

      if (original == null) {
        //print("null");
        mapFetch[createDate] = [event[i]];
      } else {
        //print(event[i]);
        mapFetch[createDate] = List.from(original)..addAll([event[i]]);
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
      backgroundColor: AppTheme.colors.backgroundColor,
      body: Column(
        children: [
          //Text(createDate),
          Container(
            margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              /*gradient: LinearGradient(colors: [
                  AppTheme.colors.blueColor,
                  AppTheme.colors.redColor
                ]),*/
              /*boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: new Offset(0.0, 5))
                ]*/
            ),
            child: TableCalendar(
              focusedDay: _selectedDay!,
              firstDay: DateTime(1990),
              lastDay: DateTime(2050),
              calendarFormat: format,
              onFormatChanged: (CalendarFormat _format) {
                setState(() {
                  format = _format;
                });
              },
              calendarBuilders: CalendarBuilders(
                singleMarkerBuilder: (context, date, event) {
                  (event as Event);
                  return Container(
                    height: 8.0,
                    width: 8.0,
                    margin: const EdgeInsets.all(0.5),
                    decoration: BoxDecoration(
                      // provide your own condition here
                      color: event.mode == "rep" ? Colors.red : Colors.black,
                      shape: BoxShape.circle,
                    ),
                  );
                },
                dowBuilder: (context, day) {
                  if (day.weekday == DateTime.sunday) {
                    final text = DateFormat.E().format(day);

                    return Center(
                      child: Text(
                        text,
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }
                },
              ),
              startingDayOfWeek: StartingDayOfWeek.monday,
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
                  color: AppTheme.colors.redColor,
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
                  color: AppTheme.colors.redColor,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                formatButtonTextStyle: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          /* ..._getEventsFromDay(selectedDay)
              .map((Event event) => cardExercice(event)),*/
          SizedBox(
            height: 20,
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: _selectedEvents.length,
                  itemBuilder: (context, index) {
                    return cardExercice(_selectedEvents[index]);
                  }))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: () => _create(context),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void _addEvent(String event) async {
    final _event = Event();

    await _eventService.saveEvent(_event);

    getTask1().then((val) => setState(() {
          _events = val;

          var _correctDate = DateTime.utc(
              _selectedDay!.year, _selectedDay!.month, _selectedDay!.day);

          _selectedEvents = _getEventsFromDay(_correctDate);
        }));

    Navigator.pop(context);
  }

  void _create(BuildContext context) {
    String _name = "";
    var content = TextField(
      autofocus: true,
      decoration: InputDecoration(
        labelText: 'Workout Name',
      ),
      onChanged: (value) {
        _name = value;
      },
    );
    var btn = FlatButton(
      child: Text(
        'Save',
      ),
      onPressed: () => _addEvent(_name),
    );
    var cancelButton = ElevatedButton(
        child: Text(
          'Cancel',
        ),
        onPressed: () => Navigator.of(context).pop(false));
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: const Offset(0.0, 10.0),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // To make the card compact
                children: <Widget>[
                  SizedBox(height: 16.0),
                  Text(
                    "Add Event",
                  ),
                  Container(padding: EdgeInsets.all(20), child: content),
                  Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[btn, cancelButton]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cardExercice(event) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          constraints: BoxConstraints(),
          builder: (BuildContext context) {
            return bottomSheet(event);
          },
        );
      },
      child: Card(
          margin: EdgeInsets.fromLTRB(30, 10, 30, 0),
          color: Colors.white,
          shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.transparent)),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: ListTile(
              title: SizedBox(
                width: 50,
                child: Text(
                  event.name,
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'BalooBhai',
                    color: AppTheme.colors.newBlueColor,
                  ),
                ),
              ),
              subtitle: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      datesecondToMinuteHour(event.datetime),
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'BalooBhai2',
                        color: AppTheme.colors.newBlueColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Widget bottomSheet(event) {
    return SingleChildScrollView(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        padding: EdgeInsets.all(30),
        width: MediaQuery.of(context).size.width * 0.85,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(children: [
                    Icon(
                      event.mode == "timer"
                          ? MyFlutterApp.noun_number
                          : MyFlutterApp.noun_timer,
                      color: AppTheme.colors.secondaryColor,
                      size: 50,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Text(
                        event.name,
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'BalooBhai',
                          color: AppTheme.colors.secondaryColor,
                        ),
                      ),
                    ),
                  ]),
                  Row(
                    children: [
                      Icon(
                        MyFlutterApp.noun_time,
                        color: AppTheme.colors.secondaryColor,
                        size: 30,
                      ),
                      Text(
                        datesecondToMinuteHour(event.datetime),
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'BalooBhai',
                          color: AppTheme.colors.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        event.mode == "timer"
                            ? event.serie.toString() +
                                " x " +
                                formatDuration(event.exercicetime)
                            : decodeJsonToText(event.arrayrepetition),
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'BalooBhai',
                          color: AppTheme.colors.secondaryColor,
                        ),
                      ),
                      Text(
                        "Exercice",
                        style: TextStyle(
                            fontSize: 15,
                            color: AppTheme.colors.secondaryColor,
                            fontFamily: 'Roboto',
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        formatDuration(event.resttime),
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'BalooBhai',
                          color: AppTheme.colors.secondaryColor,
                        ),
                      ),
                      Text(
                        "Rest time",
                        style: TextStyle(
                            fontSize: 15,
                            color: AppTheme.colors.secondaryColor,
                            fontFamily: 'Roboto',
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        formatDuration(event.totaltime),
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'BalooBhai',
                          color: AppTheme.colors.secondaryColor,
                        ),
                      ),
                      Text(
                        "Total time",
                        style: TextStyle(
                            fontSize: 15,
                            color: AppTheme.colors.secondaryColor,
                            fontFamily: 'Roboto',
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w400),
                      )
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Container(
                      height: 150,
                      padding: const EdgeInsets.all(15),
                      margin: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        border: Border.all(
                          width: 1,
                          color: AppTheme.colors.secondaryColor,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Text(
                        event.description,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'BalooBhai2',
                          color: AppTheme.colors.secondaryColor,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String decodeJsonToText(event) {
  var serie = jsonDecode(event);
  String text = "";
  for (var i = 0; i < serie.length; i++) {
    if (i < serie.length - 1) {
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

  return '$hour h $minute';
}
