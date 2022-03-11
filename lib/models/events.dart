class Event {
  int? id;
  String? name;
  int? totaltime;
  int? resttime;
  int? datetime;

  Event({this.name});

  eventMap() {
    var mapping = Map<String, dynamic>();
    mapping['id'] = id;
    mapping['name'] = name;
    mapping['resttime'] = resttime;
    mapping['totaltime'] = totaltime;
    mapping['datetime'] = datetime;



    return mapping;
  }
}
