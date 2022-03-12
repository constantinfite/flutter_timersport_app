class Event {
  int? id;
  String? name;
  String? description;
  String? arrayrepetition;
  String? mode;
  int? totaltime;
  int? serie;
  int? exercicetime;
  int? resttime;
  int? datetime;

  Event({this.name});

  eventMap() {
    var mapping = Map<String, dynamic>();
    mapping['id'] = id;
    mapping['name'] = name;
    mapping['description'] = description;
    mapping['arrayrepetition'] = arrayrepetition;
    mapping['mode'] = mode;
    mapping['resttime'] = resttime;
    mapping['serie'] = serie;
    mapping['exercicetime'] = exercicetime;
    mapping['totaltime'] = totaltime;
    mapping['datetime'] = datetime;

    return mapping;
  }
}
